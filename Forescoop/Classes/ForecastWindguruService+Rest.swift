//
//  ForecastWindguruService+AsyncAwait.swift
//  Forescoop
//
//  Created by fox on 01/06/2023.
//

import Foundation

public extension ForecastWindguruService {

    // user = api(query: routine.user,
    //        errorCode: err.user.rawValue,
    //       parameters: [parameter.username,
    //                   parameter.password]) // not user/pass (anonymous)
    
    func login(withUsername username: String?,
               password: String?) async throws -> User? {
        try await request(tokens: [Definition.service.api.parameter.username: username,
                                   Definition.service.api.parameter.password: password],
                          api: .user)
    }
    
    // searchSpots = api(query: routine.search_spots,
    //               errorCode: err.search_spots.rawValue,
    //              parameters: [parameter.search,
    //                           parameter.opt])
    func searchSpots(byLocation location: String) async throws -> SpotResult? {
        try await request(tokens: [Definition.service.api.parameter.search:
                                    location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)],
                          api: .searchSpots)
    }

    // forecast = api(query: routine.forecast,
    //            errorCode: err.forecast.rawValue,
    //           parameters: [parameter.id_spot,
    //                        parameter.id_model,
    //                        parameter.no_wave])
    
    func forecast(bySpotId spotId: String,
                  model modelId: String? = nil) async throws -> SpotForecast? {
        try await request(tokens: [Definition.service.api.parameter.id_model: modelId ?? Definition.defaultModel,
                                   Definition.service.api.parameter.id_spot: spotId],
                          api: .forecast)
    }

    //  wforecast = api(query: routine.wforecast,
    //              errorCode: err.wforecast.rawValue,
    //             parameters: [parameter.username,  // pro users
    //                          parameter.password,   // pro users
    //                          parameter.id_spot,
    //                          parameter.id_model,
    //                          parameter.no_wave])
    
    func wforecast(bySpotId spotId: String,
                   model modelId: String? = nil,
                   username: String? = nil,
                   password: String? = nil) async throws -> WSpotForecast? {

        return try await request(tokens: [Definition.service.api.parameter.id_model: modelId ?? Definition.defaultModel,
                                          Definition.service.api.parameter.id_spot: spotId,
                                          Definition.service.api.parameter.username: username,
                                          Definition.service.api.parameter.password: password],
                                 api: .wforecast)
    }
    
    // spotInfo = api(query: routine.spot,
    //            errorCode: err.spot.rawValue,
    //           parameters: [parameter.id_spot])
    func spotInfo(bySpotId spotId: String) async throws -> SpotInfo? {
        try await request(tokens: [Definition.service.api.parameter.id_spot : spotId],
                          api: .spotInfo)
    }
    
    // customSpots = api(query: routine.c_spots,
    //               errorCode: err.c_spots.rawValue,
    //              parameters: [parameter.username,
    //                           parameter.password,
    //                           parameter.opt])  // opt=simple (optional)
    func customSpots(withUsername username: String?,
                     password: String?) async throws -> SpotResult? {
        try await request(tokens: [Definition.service.api.parameter.username: username,
                                   Definition.service.api.parameter.password: password],
                          api: .customSpots)
    }
    
    
    
    // favoriteSpots = api(query: routine.f_spots,
    //                 errorCode: err.f_spots.rawValue,
    //                parameters: [parameter.username,
    //                             parameter.password,
    //                             parameter.opt]) // opt=simple (optional)
    func favoriteSpots(withUsername username: String?,
                       password: String?) async throws -> SpotResult? {
        try await request(tokens: [Definition.service.api.parameter.username: username,
                                   Definition.service.api.parameter.password: password],
                          api: .favoriteSpots)
    }
    
    // setSpots = api(query: routine.sets,
    //            errorCode: err.sets.rawValue,
    //           parameters: [parameter.username,
    //                        parameter.password])
    //
    func setSpots(withUsername username: String?,
                  password: String?) async throws -> SetResult? {
        try await request(tokens: [Definition.service.api.parameter.username: username,
                                   Definition.service.api.parameter.password: password],
                          api: .setSpots)
    }
    
    // addSetSpots = api(query: routine.set_spots,
    //               errorCode: err.set_spots.rawValue,
    //              parameters: [parameter.username,
    //                           parameter.password,
    //                           parameter.id_set,
    //                           parameter.opt])
    func addSetSpots(withSetId setId: String?,
                     username: String?,
                     password: String?) async throws -> SpotResult? {
        try await request(tokens: [Definition.service.api.parameter.id_set: setId,
                                   Definition.service.api.parameter.username: username,
                                   Definition.service.api.parameter.password: password],
                          api: .addSetSpots)
    }

    // addFavoriteSpot = api(query: routine.add_f_spot,
    //                   errorCode: err.add_f_spot.rawValue,
    //                  parameters: [parameter.username,
    //                               parameter.password,
    //                               parameter.id_spot])
    func addFavoriteSpot(withSpotId spotId: String?,
                         username: String?,
                         password: String?) async throws -> WGSuccess? {
        try await request(tokens: [Definition.service.api.parameter.id_spot: spotId,
                                   Definition.service.api.parameter.username: username,
                                   Definition.service.api.parameter.password: password],
                          api: .addFavoriteSpot)
    }
    
    // remove_f_spot = api(query: routine.remove_f_spot,
    //                 errorCode: err.remove_f_spot.rawValue,
    //                parameters: [parameter.username,
    //                             parameter.password,
    //                             parameter.id_spot])
    func removeFavoriteSpot(withSpotId spotId: String?,
                            username: String?,
                            password: String?) async throws -> WGSuccess? {
        try await request(tokens: [Definition.service.api.parameter.id_spot: spotId,
                                   Definition.service.api.parameter.username: username,
                                   Definition.service.api.parameter.password: password],
                          api: .remove_f_spot)
    }
    
    // spots = api(query: routine.spots,
    //         errorCode: err.spots.rawValue,
    //        parameters: [parameter.with_spots,       // with_spots = 1 (optional)
    //                     parameter.id_country,       // "id_country" (optional)
    //                     parameter.id_region,        // "id_region" (optional)
    //                     parameter.opt])             // opt=simple (optional)
    func spots(withCountryId countryId: String?,
               regionId: String?) async throws -> SpotResult? {
        try await request(tokens: [Definition.service.api.parameter.with_spots: "1",
                                   Definition.service.api.parameter.id_country: countryId,
                                   Definition.service.api.parameter.id_region: regionId],
                          api: .spots)
    }
    
    // modelInfo = api(query: routine.model_info,
    //             errorCode: err.model_info.rawValue,
    //            parameters: [parameter.id_model])    // id_model (optional)
    func modelInfo(onlyModelId modelId: String?) async throws -> Models? {
        try await request(tokens: [Definition.service.api.parameter.id_model: modelId],
                          api: .modelInfo)
    }
    
    
    // modelsLatLon = api(query: routine.models_latlon,
    //                errorCode: err.models_latlon.rawValue,
    //               parameters: [parameter.lat, parameter.lon])
    func models(bylat lat: String?,
                lon: String?) async throws -> String? {
        try await request(tokens: [Definition.service.api.parameter.lat: lat,
                                   Definition.service.api.parameter.lon: lon],
                          api: .modelsLatLon)
    }
    
    // geoRegions = api(query: routine.geo_regions,
    //              errorCode: err.geo_regions.rawValue,
    //             parameters: nil)
    func geoRegions() async throws -> GeoRegions? {
        try await request(tokens: [:], api: .geoRegions)
    }
    
    // countries = api(query: routine.countries,
    //             errorCode: err.countries.rawValue,
    //            parameters: [parameter.with_spots,        // with_spots = 1 (optional)
    //                         parameter.id_georegion])     // "id_georegion" (optional)

    func countries(byRegionId regionId: String?) async throws -> Countries? {
        try await request(tokens: [Definition.service.api.parameter.id_georegion: regionId],
                          api: .countries)
    }
    
    // regions = api(query: routine.regions,
    //           errorCode: err.regions.rawValue,
    //          parameters: [parameter.with_spots,     // with_spots = 1 (optional)
    //                       parameter.id_country])    // "id_country" (optional)
    
    func regions(byCountryId countryId: String?) async throws -> Regions? {
        try await request(tokens: [Definition.service.api.parameter.id_country: countryId],
                          api: .regions)
    }
}

private extension ForecastWindguruService {
    
    func request(tokens: [String: String?],
                 api: ForecastWindguruService.Definition.service.api) async throws -> String? {
        let url = Definition.service.url(api: api, tokens: tokens)
        let (data, _) = try await URLSession.shared.data(from: URL.init(string: url)!)
        if let string = String.init(data: data, encoding: .utf8) {
            print("SUCCESS url = \(url) - response.result.value \(string)")
            return string
        } else {
            print("FAILURE url = \(url)")
            throw CustomError.invalidParsing
        }
    }

    func request<T: Mappable>(tokens: [String: String?],
                              api: ForecastWindguruService.Definition.service.api) async throws -> T? {
        let url = Definition.service.url(api: api, tokens: tokens)
        let (data, _) = try await URLSession.shared.data(from: URL.init(string: url)!)
        let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String : Any]
        let object = try T.init(map: json)
        print("SUCCESS url = \(url) - response.result.value \(String(describing: json))")
        return object
    }
}
