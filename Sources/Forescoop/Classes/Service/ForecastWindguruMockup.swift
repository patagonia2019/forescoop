//
//  ForecastWindguruMockup.swift
//  Forescoop
//
//  Created by fox on 07/06/2023.
//

import Foundation

public class ForecastWindguruMockup: ForecastWindguruProtocol {

    required public init() {}

    let definition = Definition()

    /// A synchronous, bundled forecast for SwiftUI previews. It never reaches
    /// Windguru, the credential store, or the network.
    public var dashboardPreviewForecast: SpotForecast? {
        try? SpotForecast(map: previewForecastMap())
    }
    
    public func forecast(bySpotId spotId: String,
                         model modelId: String? = nil) async throws -> SpotForecast? {
        dashboardPreviewForecast
    }

    /// Keeps SwiftUI previews visibly representative of cold, snowy weather.
    private func snowForecastMap() -> [String: Any]? {
        guard var response = definition.json(jsonFile: "SpotForecast"),
              var forecasts = response["forecast"] as? [String: Any] else {
            return nil
        }

        for identifier in forecasts.keys {
            guard var model = forecasts[identifier] as? [String: Any] else { continue }
            for key in ["TMP", "TMPE"] {
                guard var temperatures = model[key] as? [String: Any] else { continue }
                for hour in 0...24 { temperatures["\(hour)"] = -2.0 }
                model[key] = temperatures
            }
            for key in ["APCP", "APCP1"] {
                guard var precipitation = model[key] as? [String: Any] else { continue }
                for hour in 0...24 { precipitation["\(hour)"] = 1.5 }
                model[key] = precipitation
            }
            forecasts[identifier] = model
        }

        response["forecast"] = forecasts
        return response
    }

    /// Kept in code rather than loaded from a package resource because the
    /// Xcode preview agent does not consistently mount SwiftPM resource bundles.
    private func previewForecastMap() -> [String: Any] {
        let hours = Array(0...72)
        func values(_ transform: (Int) -> Any) -> [String: Any] {
            Dictionary(uniqueKeysWithValues: hours.map { (String($0), transform($0)) })
        }

        let model: [String: Any] = [
            "initstamp": 1_786_000_000,
            "initdate": "2026-08-02 00:00:00",
            "model_name": "GFS 13 km",
            // Forecast's wind accessors expose `Double` values. Keep the
            // inline preview map faithful to decoded API data so charts and
            // detail views receive the same non-zero values as the grid.
            "WINDSPD": values { Double(8 + ($0 % 6)) },
            "GUST": values { Double(13 + ($0 % 8)) },
            "WINDDIR": values { Double(240 + ($0 % 5) * 12) },
            "WINDIRNAME": values { _ in "WSW" },
            "TMP": values { -3 + Double($0 % 8) * 0.8 },
            "TMPE": values { -4 + Double($0 % 8) * 0.8 },
            "TCDC": values { 72 + ($0 % 4) * 7 },
            "HCDC": values { 45 + ($0 % 5) * 5 },
            "MCDC": values { 55 + ($0 % 4) * 6 },
            "LCDC": values { 68 + ($0 % 3) * 8 },
            "RH": values { 78 + ($0 % 5) * 3 },
            "APCP": values { $0 % 5 == 0 ? 1.4 : 0.0 },
            "APCP1": values { $0 % 5 == 0 ? 0.7 : 0.0 },
            "SLP": values { 1_012 + Double($0 % 7) },
            "FLHGT": values { Double(900 + ($0 % 6) * 80) },
            "HTSGW": values { 0.8 + Double($0 % 4) * 0.2 },
            "WVPER": values { Double(6 + ($0 % 3)) },
            "WVDIR": values { Double(220 + ($0 % 5) * 10) }
        ]

        return [
            "id_spot": "64141",
            "spotname": "Bariloche",
            "country": "Argentina",
            "id_country": 32,
            "lat": -41.1281,
            "lon": -71.348,
            "alt": 770,
            "tz": "America/Argentina/Mendoza",
            "gmt_hour_offset": -3,
            "sunrise": "08:30",
            "sunset": "18:45",
            "models": [3],
            "tides": "0",
            "forecast": ["3": model]
        ]
    }

    public func wforecast(bySpotId spotId: String,
                          model modelId: String? = nil,
                          username: String? = nil,
                          password: String?) async throws -> WSpotForecast? {
        try WSpotForecast(map: definition.json(jsonFile: "WSpotForecast"))
    }

    public func wforecast(byLatitude latitude: Double,
                          longitude: Double,
                          model modelId: String? = nil,
                          username: String,
                          password: String) async throws -> WSpotForecast? {
        try WSpotForecast(map: definition.json(jsonFile: "WSpotForecast"))
    }
    
    public func spotInfo(bySpotId spotId: String) async throws -> SpotInfo? {
        try SpotInfo(map: definition.json(jsonFile: "SpotInfo"))
    }
    
    public func customSpots(withUsername username: String?, password: String?) async throws -> SpotResult? {
        try SpotResult(map: definition.json(jsonFile: "SpotResult"))
    }
    
    public func favoriteSpots(withUsername username: String?, password: String?) async throws -> SpotResult? {
        try SpotResult(map: definition.json(jsonFile: "SpotResult"))
    }
    
    public func setSpots(withUsername username: String?, password: String?) async throws -> SetResult? {
        try SetResult(map: definition.json(jsonFile: "SetResult"))
    }
    
    public func addSetSpots(withSetId setId: String?, username: String?, password: String?) async throws -> SpotResult? {
        try SpotResult(map: definition.json(jsonFile: "SpotResult"))
    }
    
    public func addFavoriteSpot(withSpotId spotId: String?, username: String?, password: String?) async throws -> WGSuccess? {
        try WGSuccess(map: definition.json(jsonFile: "WGSuccess"))
    }
    
    public func removeFavoriteSpot(withSpotId spotId: String?, username: String?, password: String?) async throws -> WGSuccess? {
        try WGSuccess(map: definition.json(jsonFile: "WGSuccess"))
    }
    
    public func searchSpots(byLocation location: String) async throws -> SpotResult? {
        try SpotResult(map: definition.json(jsonFile: "SpotResult"))
    }
    
    public func spots(withCountryId countryId: String?, regionId: String?) async throws -> SpotResult? {
        try SpotResult(map: definition.json(jsonFile: "SpotResult"))
    }
    
    public func modelInfo(onlyModelId modelId: String?) async throws -> Models? {
        try Models(map: definition.json(jsonFile: "Models"))
    }
    
    public func models(bylat lat: String?, lon: String?) async throws -> String? {
        "[3]"
    }
    
    public func geoRegions() async throws -> GeoRegions? {
        try GeoRegions(map: definition.json(jsonFile: "GeoRegions"))
    }
    
    public func countries(byRegionId regionId: String?) async throws -> Countries? {
        try Countries(map: definition.json(jsonFile: "Countries"))
    }
    
    public func regions(byCountryId countryId: String?) async throws -> Regions? {
        try Regions(map: definition.json(jsonFile: "Regions"))
    }
    
    public func login(withUsername username: String?, password: String?) async throws -> User? {
        try User(map: definition.json(jsonFile: "User"))
    }
}
