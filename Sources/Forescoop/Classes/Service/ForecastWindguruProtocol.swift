//
//  ForecastWindguruProtocol.swift
//  Forescoop
//
//  Created by fox on 07/06/2023.
//

import Foundation

public protocol ForecastWindguruProtocol {
    
    init()
    
    func forecast(bySpotId spotId: String, model modelId: String?) async throws -> SpotForecast?
    func wforecast(bySpotId spotId: String, model modelId: String?, username: String?, password: String?) async throws -> WSpotForecast?
    func spotInfo(bySpotId spotId: String) async throws -> SpotInfo?
    func customSpots(withUsername username: String?, password: String?) async throws -> SpotResult?
    func favoriteSpots(withUsername username: String?, password: String?) async throws -> SpotResult?
    func setSpots(withUsername username: String?, password: String?) async throws -> SetResult?
    func addSetSpots(withSetId setId: String?, username: String?, password: String?) async throws -> SpotResult?
    func addFavoriteSpot(withSpotId spotId: String?, username: String?, password: String?) async throws -> WGSuccess?
    func removeFavoriteSpot(withSpotId spotId: String?, username: String?, password: String?) async throws -> WGSuccess?
    func searchSpots(byLocation location: String) async throws -> SpotResult?
    func spots(withCountryId countryId: String?, regionId: String?) async throws -> SpotResult?
    func modelInfo(onlyModelId modelId: String?) async throws -> Models?
    func models(bylat lat: String?, lon: String?) async throws -> String?
    func geoRegions() async throws -> GeoRegions?
    func countries(byRegionId regionId: String?) async throws -> Countries?
    func regions(byCountryId countryId: String?) async throws -> Regions?
    func login(withUsername username: String?, password: String?) async throws -> User?
}
