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

    // MARK - Async / Wait
    public func searchSpots(byLocation location: String) async throws -> SpotResult? {
        DispatchQueue.main.sync {
            return SpotResult.init(map: definition.json(jsonFile: "SpotResult"))
        }
    }
    
    public func forecast(bySpotId spotId: String,
                         model modelId: String? = nil) async throws -> SpotForecast? {
        DispatchQueue.main.sync {
            return SpotForecast.init(map: definition.json(jsonFile: "SpotForecast"))
        }
    }

    // MARK - Closures
    
    public func forecast(bySpotId spotId: String, model modelId: String?, failure: @escaping FailureType, success: @escaping (SpotForecast?) -> Void) {
        success(SpotForecast.init(map: nil))
    }
    
    public func wforecast(bySpotId spotId: String, model modelId: String? = nil, username: String? = nil, password: String?, failure: @escaping FailureType, success: @escaping (WSpotForecast?) -> Void) {
        success(WSpotForecast.init(map: nil))
    }
    
    public func spotInfo(bySpotId spotId: String, failure: @escaping FailureType, success: @escaping (SpotInfo?) -> Void) {
        success(SpotInfo())
    }
    
    public func customSpots(withUsername username: String?, password: String?, failure: @escaping FailureType, success: @escaping (SpotResult?) -> Void) {
        success(SpotResult())
    }
    
    public func favoriteSpots(withUsername username: String?, password: String?, failure: @escaping FailureType, success: @escaping (SpotResult?) -> Void) {
        success(SpotResult())
    }
    
    public func setSpots(withUsername username: String?, password: String?, failure: @escaping FailureType, success: @escaping (SetResult?) -> Void) {
        success(SetResult())
    }
    
    public func addSetSpots(withSetId setId: String?, username: String?, password: String?, failure: @escaping FailureType, success: @escaping (SpotResult?) -> Void) {
        success(SpotResult())
    }
    
    public func addFavoriteSpot(withSpotId spotId: String?, username: String?, password: String?, failure: @escaping FailureType, success: @escaping (WGSuccess?) -> Void) {
        success(WGSuccess(map: nil))
    }
    
    public func removeFavoriteSpot(withSpotId spotId: String?, username: String?, password: String?, failure: @escaping FailureType, success: @escaping (WGSuccess?) -> Void) {
        success(WGSuccess(map: nil))
    }
    
    public func searchSpots(byLocation location: String, failure: @escaping FailureType, success: @escaping (SpotResult?) -> Void) {
        success(SpotResult())
    }
    
    public func spots(withCountryId countryId: String?, regionId: String?, failure: @escaping FailureType, success: @escaping (SpotResult?) -> Void) {
        success(SpotResult())
    }
    
    public func modelInfo(onlyModelId modelId: String?, failure: @escaping FailureType, success: @escaping (Models?) -> Void) {
        success(Models())
    }
    
    public func models(bylat lat: String?, lon: String?, failure: @escaping FailureType, success: @escaping ([String]?) -> Void) {
        success([String()])
    }
    
    public func geoRegions(withFailure failure: @escaping FailureType, success: @escaping (GeoRegions?) -> Void) {
        success(GeoRegions())
    }
    
    public func countries(byRegionId regionId: String?, failure: @escaping FailureType, success: @escaping (Countries?) -> Void) {
        success(Countries())
    }
    
    public func regions(byCountryId countryId: String?, failure: @escaping FailureType, success: @escaping (Regions?) -> Void) {
        success(Regions())
    }
    
    public func login(withUsername username: String?, password: String?, failure: @escaping FailureType, success: @escaping (User?) -> Void) {
        success(User())
    }
}

