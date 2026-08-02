//
//  SavedMapLocation.swift
//  Forescoop
//

import CoreLocation
import Foundation
import SwiftData

@Model private final class SavedMapLocationRecord {
    @Attribute(.unique) var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var spotID: String?
    var placeDescription: String?

    init(_ location: SavedMapLocation) {
        id = location.id; name = location.name; latitude = location.latitude; longitude = location.longitude
        spotID = location.spotID; placeDescription = location.placeDescription
    }

    var location: SavedMapLocation { SavedMapLocation(id: id, name: name, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), spotID: spotID, placeDescription: placeDescription) }
}

@Model private final class VentusPreferenceRecord {
    @Attribute(.unique) var key: String
    var value: String
    init(key: String, value: String) { self.key = key; self.value = value }
}

public struct SavedMapLocation: Codable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public let latitude: Double
    public let longitude: Double
    public let spotID: String?
    public let placeDescription: String?

    public init(
        id: UUID = UUID(),
        name: String,
        coordinate: CLLocationCoordinate2D,
        spotID: String? = nil,
        placeDescription: String? = nil
    ) {
        self.id = id
        self.name = name
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        self.spotID = spotID
        self.placeDescription = placeDescription
    }

    public var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    public var coordinateText: String { "\(latitude.formatted(.number.precision(.fractionLength(4)))), \(longitude.formatted(.number.precision(.fractionLength(4))))" }
    public var displayName: String {
        guard let spotID, spotID != "0" else { return name }
        return "\(name) #\(spotID)"
    }
    public var detailText: String {
        guard let spotID, spotID != "0" else { return coordinateText }
        return placeDescription?.isEmpty == false ? placeDescription! : coordinateText
    }
    public var isPrimaryLocation: Bool { spotID == SavedMapLocationStore.primarySpotID }
}

public enum SavedMapLocationStore {
    fileprivate static let container = try! ModelContainer(for: SavedMapLocationRecord.self, VentusPreferenceRecord.self)
    public static let primarySpotID = "64141"
    private static let primaryLocation = SavedMapLocation(
        id: UUID(uuidString: "64141000-0000-4000-8000-000000000000")!,
        name: "Bariloche",
        coordinate: CLLocationCoordinate2D(latitude: -41.1281, longitude: -71.3480),
        spotID: primarySpotID,
        placeDescription: "Argentina"
    )

    public static func load() -> [SavedMapLocation] {
        let context = ModelContext(container)
        let locations = (try? context.fetch(FetchDescriptor<SavedMapLocationRecord>()))?.map(\.location) ?? []
        return normalized(locations)
    }

    public static func save(_ locations: [SavedMapLocation]) {
        let context = ModelContext(container)
        (try? context.fetch(FetchDescriptor<SavedMapLocationRecord>()))?.forEach { context.delete($0) }
        normalized(locations).forEach { context.insert(SavedMapLocationRecord($0)) }
        try? context.save()
    }

    /// Removes locations associated with the current Windguru session.
    public static func removeAll() {
        save([primaryLocation])
    }

    /// Clears persisted Windguru session data while keeping the required
    /// default map location and app-wide preferences intact.
    public static func clearSessionData() -> [SavedMapLocation] {
        removeAll()
        SelectedWindguruSpotStore.clear()
        return load()
    }

    private static func normalized(_ locations: [SavedMapLocation]) -> [SavedMapLocation] {
        let primary = locations.first(where: \.isPrimaryLocation) ?? primaryLocation
        return locations
            .filter { !$0.isPrimaryLocation }
            .reduce(into: [primary]) { unique, location in
                guard !unique.contains(where: { isSameLocation($0, location) }) else { return }
                unique.append(location)
            }
    }

    public static func isSameLocation(_ lhs: SavedMapLocation, _ rhs: SavedMapLocation) -> Bool {
        if let leftSpotID = lhs.spotID, let rightSpotID = rhs.spotID, leftSpotID == rightSpotID {
            return true
        }
        return abs(lhs.latitude - rhs.latitude) < 0.0001
            && abs(lhs.longitude - rhs.longitude) < 0.0001
    }
}

public enum SelectedWindguruSpotStore {
    private static let key = "selectedWindguruSpotID"
    public static func load() -> String {
        let context = ModelContext(SavedMapLocationStore.container)
        return (try? context.fetch(FetchDescriptor<VentusPreferenceRecord>()))?.first(where: { $0.key == key })?.value ?? SavedMapLocationStore.primarySpotID
    }
    public static func save(_ spotID: String) {
        let context = ModelContext(SavedMapLocationStore.container)
        if let record = (try? context.fetch(FetchDescriptor<VentusPreferenceRecord>()))?.first(where: { $0.key == key }) { record.value = spotID } else { context.insert(VentusPreferenceRecord(key: key, value: spotID)) }
        try? context.save()
    }

    public static func clear() {
        let context = ModelContext(SavedMapLocationStore.container)
        guard let record = (try? context.fetch(FetchDescriptor<VentusPreferenceRecord>()))?.first(where: { $0.key == key }) else { return }
        context.delete(record)
        try? context.save()
    }
}

/// Persists the background treatment independently of any Windguru session.
public enum WeatherBackgroundStyleStore {
    private static let key = "weatherBackgroundStyle"

    public static func load() -> WeatherBackgroundStyle {
        let context = ModelContext(SavedMapLocationStore.container)
        let value = (try? context.fetch(FetchDescriptor<VentusPreferenceRecord>()))?
            .first(where: { $0.key == key })?
            .value
        if value == "lottie" { return .lottieAdriana }
        return value.flatMap(WeatherBackgroundStyle.init(rawValue:)) ?? .lottieAdriana
    }

    public static func save(_ style: WeatherBackgroundStyle) {
        let context = ModelContext(SavedMapLocationStore.container)
        if let record = (try? context.fetch(FetchDescriptor<VentusPreferenceRecord>()))?
            .first(where: { $0.key == key }) {
            record.value = style.rawValue
        } else {
            context.insert(VentusPreferenceRecord(key: key, value: style.rawValue))
        }
        try? context.save()
    }
}

/// Shared SwiftData-backed storage for device preferences that are not tied to
/// the current Windguru session.
enum VentusPreferenceStore {
    static func value(forKey key: String) -> String? {
        let context = ModelContext(SavedMapLocationStore.container)
        return (try? context.fetch(FetchDescriptor<VentusPreferenceRecord>()))?
            .first(where: { $0.key == key })?
            .value
    }

    static func save(_ value: String, forKey key: String) {
        let context = ModelContext(SavedMapLocationStore.container)
        if let record = (try? context.fetch(FetchDescriptor<VentusPreferenceRecord>()))?
            .first(where: { $0.key == key }) {
            record.value = value
        } else {
            context.insert(VentusPreferenceRecord(key: key, value: value))
        }
        try? context.save()
    }
}

/// Persists the movable split between the forecast grid and dashboard.
enum ForecastWorkspaceSplitStore {
    private static let wideKey = "forecastWorkspaceWideSplit"
    private static let tallKey = "forecastWorkspaceTallSplit"

    static func load(isWide: Bool) -> CGFloat {
        let key = isWide ? wideKey : tallKey
        let fallback: CGFloat = isWide ? 0.56 : 0.52
        guard let value = VentusPreferenceStore.value(forKey: key),
              let fraction = Double(value) else { return fallback }
        return min(max(CGFloat(fraction), 0.25), 0.75)
    }

    static func save(_ fraction: CGFloat, isWide: Bool) {
        VentusPreferenceStore.save(String(Double(fraction)), forKey: isWide ? wideKey : tallKey)
    }
}

/// The primary forecast presentation selected for this device.
public enum ForecastViewMode: String, CaseIterable, Identifiable, Sendable {
    case dashboard
    case grid
    case workspace
    case graph

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .dashboard: "Forecast Dashboard"
        case .grid: "Forecast Grid"
        case .workspace: "Grid and Dashboard"
        case .graph: "Forecast Graph"
        }
    }

    public var systemImage: String {
        switch self {
        case .dashboard: "rectangle.3.group"
        case .grid: "tablecells"
        case .workspace: "rectangle.split.2x1"
        case .graph: "chart.xyaxis.line"
        }
    }
}

/// Persists the selected primary forecast presentation independently of a
/// Windguru account session.
public enum ForecastViewModeStore {
    private static let key = "forecastViewMode"

    public static func load() -> ForecastViewMode {
        let context = ModelContext(SavedMapLocationStore.container)
        let value = (try? context.fetch(FetchDescriptor<VentusPreferenceRecord>()))?
            .first(where: { $0.key == key })?
            .value
        return value.flatMap(ForecastViewMode.init(rawValue:)) ?? .dashboard
    }

    public static func save(_ mode: ForecastViewMode) {
        let context = ModelContext(SavedMapLocationStore.container)
        if let record = (try? context.fetch(FetchDescriptor<VentusPreferenceRecord>()))?
            .first(where: { $0.key == key }) {
            record.value = mode.rawValue
        } else {
            context.insert(VentusPreferenceRecord(key: key, value: mode.rawValue))
        }
        try? context.save()
    }
}
