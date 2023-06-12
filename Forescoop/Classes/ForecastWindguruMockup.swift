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
    
    public func forecast(bySpotId spotId: String,
                         model modelId: String? = nil) async throws -> SpotForecast? {
        SpotForecast(map: definition.json(jsonFile: "SpotForecast"))
    }

    public func wforecast(bySpotId spotId: String,
                          model modelId: String? = nil,
                          username: String? = nil,
                          password: String?) async throws -> WSpotForecast? {
        WSpotForecast(map: definition.json(jsonFile: "WSpotForecast"))
    }
    
    public func spotInfo(bySpotId spotId: String) async throws -> SpotInfo? {
        SpotInfo(map: definition.json(jsonFile: "SpotInfo"))
    }
    
    public func customSpots(withUsername username: String?, password: String?) async throws -> SpotResult? {
        SpotResult(map: definition.json(jsonFile: "SpotResult"))
    }
    
    public func favoriteSpots(withUsername username: String?, password: String?) async throws -> SpotResult? {
        SpotResult(map: definition.json(jsonFile: "SpotResult"))
    }
    
    public func setSpots(withUsername username: String?, password: String?) async throws -> SetResult? {
        SetResult(map: definition.json(jsonFile: "SetResult"))
    }
    
    public func addSetSpots(withSetId setId: String?, username: String?, password: String?) async throws -> SpotResult? {
        SpotResult(map: definition.json(jsonFile: "SpotResult"))
    }
    
    public func addFavoriteSpot(withSpotId spotId: String?, username: String?, password: String?) async throws -> WGSuccess? {
        WGSuccess(map: definition.json(jsonFile: "WGSuccess"))
    }
    
    public func removeFavoriteSpot(withSpotId spotId: String?, username: String?, password: String?) async throws -> WGSuccess? {
        WGSuccess(map: definition.json(jsonFile: "WGSuccess"))
    }
    
    public func searchSpots(byLocation location: String) async throws -> SpotResult? {
        SpotResult(map: definition.json(jsonFile: "SpotResult"))
    }
    
    public func spots(withCountryId countryId: String?, regionId: String?) async throws -> SpotResult? {
        SpotResult(map: definition.json(jsonFile: "SpotResult"))
    }
    
    public func modelInfo(onlyModelId modelId: String?) async throws -> Models? {
        Models(map: definition.json(jsonFile: "Models"))
    }
    
    public func models(bylat lat: String?, lon: String?) async throws -> String? {
        "[3]"
    }
    
    public func geoRegions() async throws -> GeoRegions? {
        GeoRegions(map: definition.json(jsonFile: "GeoRegions"))
    }
    
    public func countries(byRegionId regionId: String?) async throws -> Countries? {
        Countries(map: definition.json(jsonFile: "Countries"))
    }
    
    public func regions(byCountryId countryId: String?) async throws -> Regions? {
        Regions(map: definition.json(jsonFile: "Regions"))
    }
    
    public func login(withUsername username: String?, password: String?) async throws -> User? {
        User(map: definition.json(jsonFile: "User"))
    }
}

