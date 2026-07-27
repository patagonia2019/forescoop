//
//  SavedMapLocation.swift
//  Forescoop
//

import CoreLocation
import Foundation

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
    private static let key = "savedMapLocations"
    public static let primarySpotID = "64141"
    private static let primaryLocation = SavedMapLocation(
        id: UUID(uuidString: "64141000-0000-4000-8000-000000000000")!,
        name: "Bariloche",
        coordinate: CLLocationCoordinate2D(latitude: -41.1281, longitude: -71.3480),
        spotID: primarySpotID,
        placeDescription: "Argentina"
    )

    public static func load() -> [SavedMapLocation] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let locations = try? JSONDecoder().decode([SavedMapLocation].self, from: data) else {
            return [primaryLocation]
        }
        return normalized(locations)
    }

    public static func save(_ locations: [SavedMapLocation]) {
        UserDefaults.standard.set(try? JSONEncoder().encode(normalized(locations)), forKey: key)
    }

    /// Removes locations associated with the current Windguru session.
    public static func removeAll() {
        save([primaryLocation])
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
