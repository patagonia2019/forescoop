//
//  SavedMapLocation.swift
//  Forescoop
//

import CoreLocation
import Foundation

public struct SavedMapLocation: Codable, Identifiable {
    public let id: UUID
    public var name: String
    public let latitude: Double
    public let longitude: Double
    public let spotID: String?

    public init(name: String, coordinate: CLLocationCoordinate2D, spotID: String? = nil) {
        id = UUID()
        self.name = name
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        self.spotID = spotID
    }

    public var coordinate: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    public var coordinateText: String { "\(latitude.formatted(.number.precision(.fractionLength(4)))), \(longitude.formatted(.number.precision(.fractionLength(4))))" }
}

public enum SavedMapLocationStore {
    private static let key = "savedMapLocations"

    public static func load() -> [SavedMapLocation] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([SavedMapLocation].self, from: data)) ?? []
    }

    public static func save(_ locations: [SavedMapLocation]) {
        UserDefaults.standard.set(try? JSONEncoder().encode(locations), forKey: key)
    }

    /// Removes locations associated with the current Windguru session.
    public static func removeAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
