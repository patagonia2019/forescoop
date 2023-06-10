//
//  ForecastWindguruProtocol.swift
//  Forescoop
//
//  Created by fox on 07/06/2023.
//

import Foundation

public protocol ForecastWindguruProtocol {
    
    init()

    // user = api(query: routine.user,
    //        errorCode: err.user.rawValue,
    //       parameters: [parameter.username,
    //                   parameter.password]) // not user/pass (anonymous)
    
    typealias FailureType = (_ error: WGError?) -> Void
    
    // MARK - async / throws
    
    // searchSpots = api(query: routine.search_spots,
    //               errorCode: err.search_spots.rawValue,
    //              parameters: [parameter.search,
    //                           parameter.opt])
    func searchSpots(byLocation location: String) async throws -> SpotResult?
    
    // forecast = api(query: routine.forecast,
    //            errorCode: err.forecast.rawValue,
    //           parameters: [parameter.id_spot,
    //                        parameter.id_model,
    //                        parameter.no_wave])
    func forecast(bySpotId spotId: String,
                  model modelId: String?) async throws -> SpotForecast?
    
    // Mark - Closure
    
    // user = api(query: routine.user,
    //        errorCode: err.user.rawValue,
    //       parameters: [parameter.username,
    //                   parameter.password]) // not user/pass (anonymous)
    func login(withUsername username: String?,
               password: String?,
               failure: @escaping FailureType,
               success: @escaping (_ user: User?) -> Void)
    
    // forecast = api(query: routine.forecast,
    //            errorCode: err.forecast.rawValue,
    //           parameters: [parameter.id_spot,
    //                        parameter.id_model,
    //                        parameter.no_wave])
    func forecast(bySpotId spotId: String,
                  model modelId: String?,
                  failure: @escaping FailureType,
                  success: @escaping (_ spotForecast: SpotForecast?) -> Void)
    
    //  wforecast = api(query: routine.wforecast,
    //              errorCode: err.wforecast.rawValue,
    //             parameters: [parameter.username,  // pro users
    //                          parameter.password,   // pro users
    //                          parameter.id_spot,
    //                          parameter.id_model,
    //                          parameter.no_wave])
    func wforecast(bySpotId spotId: String,
                   model modelId: String?,
                   username: String?,
                   password: String?,
                   failure: @escaping FailureType,
                   success: @escaping (_ spotForecast: WSpotForecast?) -> Void)
    
    // spotInfo = api(query: routine.spot,
    //            errorCode: err.spot.rawValue,
    //           parameters: [parameter.id_spot])
    func spotInfo(bySpotId spotId: String,
                  failure: @escaping FailureType,
                  success: @escaping (_ spotInfo: SpotInfo?) -> Void)
    
    // customSpots = api(query: routine.c_spots,
    //               errorCode: err.c_spots.rawValue,
    //              parameters: [parameter.username,
    //                           parameter.password,
    //                           parameter.opt])  // opt=simple (optional)
    func customSpots(withUsername username: String?,
                     password: String?,
                     failure: @escaping FailureType,
                     success: @escaping (_ spots: SpotResult?) -> Void)
    
    // favoriteSpots = api(query: routine.f_spots,
    //                 errorCode: err.f_spots.rawValue,
    //                parameters: [parameter.username,
    //                             parameter.password,
    //                             parameter.opt]) // opt=simple (optional)
    func favoriteSpots(withUsername username: String?,
                       password: String?,
                       failure: @escaping FailureType,
                       success: @escaping (_ spots: SpotResult?) -> Void)
    
    // setSpots = api(query: routine.sets,
    //            errorCode: err.sets.rawValue,
    //           parameters: [parameter.username,
    //                        parameter.password])
    //
    func setSpots(withUsername username: String?,
                  password: String?,
                  failure: @escaping FailureType,
                  success: @escaping (_ sets: SetResult?) -> Void)
    
    // addSetSpots = api(query: routine.set_spots,
    //               errorCode: err.set_spots.rawValue,
    //              parameters: [parameter.username,
    //                           parameter.password,
    //                           parameter.id_set,
    //                           parameter.opt])
    func addSetSpots(withSetId setId: String?,
                     username: String?,
                     password: String?,
                     failure: @escaping FailureType,
                     success: @escaping (_ spots: SpotResult?) -> Void)
    
    // addFavoriteSpot = api(query: routine.add_f_spot,
    //                   errorCode: err.add_f_spot.rawValue,
    //                  parameters: [parameter.username,
    //                               parameter.password,
    //                               parameter.id_spot])
    func addFavoriteSpot(withSpotId spotId: String?,
                         username: String?,
                         password: String?,
                         failure: @escaping FailureType,
                         success: @escaping (_ response: WGSuccess?) -> Void)
    
    // remove_f_spot = api(query: routine.remove_f_spot,
    //                 errorCode: err.remove_f_spot.rawValue,
    //                parameters: [parameter.username,
    //                             parameter.password,
    //                             parameter.id_spot])
    func removeFavoriteSpot(withSpotId spotId: String?,
                            username: String?,
                            password: String?,
                            failure: @escaping FailureType,
                            success: @escaping (_ response: WGSuccess?) -> Void)
    
    // searchSpots = api(query: routine.search_spots,
    //               errorCode: err.search_spots.rawValue,
    //              parameters: [parameter.search,
    //                           parameter.opt])
    func searchSpots(byLocation location: String,
                     failure: @escaping FailureType,
                     success: @escaping (_ spotResult: SpotResult?) -> Void)
    
    // spots = api(query: routine.spots,
    //         errorCode: err.spots.rawValue,
    //        parameters: [parameter.with_spots,       // with_spots = 1 (optional)
    //                     parameter.id_country,       // "id_country" (optional)
    //                     parameter.id_region,        // "id_region" (optional)
    //                     parameter.opt])             // opt=simple (optional)
    func spots(withCountryId countryId: String?,
               regionId: String?,
               failure: @escaping FailureType,
               success: @escaping (_ spotResult: SpotResult?) -> Void)
    
    // modelInfo = api(query: routine.model_info,
    //             errorCode: err.model_info.rawValue,
    //            parameters: [parameter.id_model])    // id_model (optional)
    func modelInfo(onlyModelId modelId: String?,
                   failure: @escaping FailureType,
                   success: @escaping (_ model: Models?) -> Void)
    
    // modelsLatLon = api(query: routine.models_latlon,
    //                errorCode: err.models_latlon.rawValue,
    //               parameters: [parameter.lat, parameter.lon])
    func models(bylat lat: String?,
                lon: String?,
                failure: @escaping FailureType,
                success: @escaping (_ models: [String]?) -> Void)
    
    // geoRegions = api(query: routine.geo_regions,
    //              errorCode: err.geo_regions.rawValue,
    //             parameters: nil)
    func geoRegions(withFailure failure: @escaping FailureType,
                    success: @escaping (_ model: GeoRegions?) -> Void)
    
    // countries = api(query: routine.countries,
    //             errorCode: err.countries.rawValue,
    //            parameters: [parameter.with_spots,        // with_spots = 1 (optional)
    //                         parameter.id_georegion])     // "id_georegion" (optional)
    func countries(byRegionId regionId: String?,
                   failure: @escaping FailureType,
                   success: @escaping (_ countries: Countries?) -> Void)
    
    // regions = api(query: routine.regions,
    //           errorCode: err.regions.rawValue,
    //          parameters: [parameter.with_spots,     // with_spots = 1 (optional)
    //                       parameter.id_country])    // "id_country" (optional)
    func regions(byCountryId countryId: String?,
                 failure: @escaping FailureType,
                 success: @escaping (_ regions: Regions?) -> Void)
}
