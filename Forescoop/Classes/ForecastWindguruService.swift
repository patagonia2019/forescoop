//
//  ForecastWindguruService.swift
//  Forescoop
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2023 Fuchs. All rights reserved.
//

import Foundation


/*
 *  ForecastWindguruService
 *
 *  Discussion:
 *    Query forecasts and spots, it query weather conditions from any place 
 *    in the world using http://windguru.cz json rest api.
 */

public class ForecastWindguruService: ForecastWindguruProtocol {
    required public init() {}
    
    public struct Http {
        static let defaultModel = "3"
        
        struct Service {
            // https://www.windguru.cz/int/jsonapi.php?client=wgapp
            // scheme://server
            static let scheme = "https"
            static let server = "www.windguru.cz"
            static let uri = "int/jsonapi.php"
            struct Client {
                static let key = "client"
                static let value = "wgapp"
            }
            // Not mandatory
            struct Version {
                static let key = "app_version"
                static let value = "1.1.10"
            }
            static var baseUrl: String {
                "\(scheme)://\(server)/\(uri)?\(Client.key)=\(Client.value)"
            }

            
            // https://www.windguru.cz/int/jsonapi.php?client=wgapp&app_version=1.1.10
            // {"return":"error","error_id":5,"error_message":"Missing query [q]"}
            
            struct Api {

                let query: Routine
                let errorCode: Int
                let parameters: [Parameter]?
                
                public enum err: Int {
                    case add_f_spot = 101
                    case c_spots
                    case countries
                    case f_spots
                    case forecast
                    case geo_regions
                    case model_info
                    case models_latlon
                    case regions
                    case remove_f_spot
                    case search_spots
                    case set_spots
                    case sets
                    case spot
                    case spots
                    case user
                    case wforecast
                    case wforecast_latlon
                }

                public enum Routine: String {
                    case c_spots = "c_spots"
                    case set_spots = "set_spots"
                    case sets = "sets"
                    case user = "user"
                    case f_spots = "f_spots"
                    case add_f_spot = "add_f_spot"
                    case remove_f_spot = "remove_f_spot"
                    case forecast = "forecast"
                    case model_info = "model_info"
                    case models_latlon = "models_latlon"
                    case geo_regions = "geo_regions"
                    case countries = "countries"
                    case regions = "regions"
                    case spots = "spots"
                    case spot = "spot"
                    case search_spots = "search_spots"
                    case wforecast = "wforecast"
                    case wforecast_latlon = "wforecast_latlon"
                }

                enum Parameter: String {
                    case id_country = "id_country"
                    case id_georegion = "id_georegion"
                    case id_model = "id_model"
                    case id_region = "id_region"
                    case id_set = "id_set"
                    case id_spot = "id_spot"
                    case lat = "lat"
                    case lon = "lon"
                    case no_wave = "no_wave"      // no_wave = 1 (optional)
                    case opt = "opt"              // opt=simple (optional)
                    case q = "q"
                    case password = "password"
                    case search = "search"
                    case username = "username"
                    case with_spots = "with_spots"
                }

                
                /* Definition.parameter.xid */

                static let user = Api(query: Routine.user,
                                       errorCode: err.user.rawValue,
                                       parameters: [.username,
                                                    .password]) // not user/pass (anonymous)
                
                static let searchSpots = Api(query: .search_spots,
                                             errorCode: err.search_spots.rawValue,
                                             parameters: [.search,
                                                          .opt])
                
                static let favoriteSpots = Api(query: .f_spots,
                                               errorCode: err.f_spots.rawValue,
                                               parameters: [.username,
                                                            .password,
                                                            .opt]) // opt=simple (optional)
                
                static let addFavoriteSpot = Api(query: .add_f_spot,
                                                 errorCode: err.add_f_spot.rawValue,
                                                 parameters: [.username,
                                                              .password,
                                                              .id_spot])
                
                static let remove_f_spot = Api(query: .remove_f_spot,
                                               errorCode: err.remove_f_spot.rawValue,
                                               parameters: [.username,
                                                            .password,
                                                            .id_spot])
                
                static let setSpots = Api(query: .sets,
                                          errorCode: err.sets.rawValue,
                                          parameters: [.username,
                                                       .password])
                
                static let addSetSpots = Api(query: .set_spots,
                                             errorCode: err.set_spots.rawValue,
                                             parameters: [.username,
                                                          .password,
                                                          .id_set,
                                                          .opt])
                
                static let customSpots = Api(query: .c_spots,
                                             errorCode: err.c_spots.rawValue,
                                             parameters: [.username,
                                                          .password,
                                                          .opt])

                static let spotInfo = Api(query: .spot,
                                          errorCode: err.spot.rawValue,
                                          parameters: [.id_spot])
                
                static let modelInfo = Api(query: .model_info,
                                           errorCode: err.model_info.rawValue,
                                           parameters: [.id_model])    // id_model (optional)
                
                static let modelsLatLon = Api(query: .models_latlon,
                                              errorCode: err.models_latlon.rawValue,
                                              parameters: [.lat, Parameter.lon])
                
                static let geoRegions = Api(query: .geo_regions,
                                            errorCode: err.geo_regions.rawValue,
                                            parameters: nil)
                
                static let countries = Api(query: .countries,
                                           errorCode: err.countries.rawValue,
                                           parameters: [.with_spots,   // with_spots = 1 (optional)
                                            Parameter.id_georegion])            // "id_georegion" (optional)

                static let regions = Api(query: .regions,
                                         errorCode: err.regions.rawValue,
                                         parameters: [.with_spots,     // with_spots = 1 (optional)
                                                      .id_country])    // "id_country" (optional)

                static let spots = Api(query: .spots,
                                       errorCode: err.spots.rawValue,
                                       parameters: [.with_spots,       // with_spots = 1 (optional)
                                                    .id_country,       // "id_country" (optional)
                                                    .id_region,        // "id_region" (optional)
                                        Parameter.opt])                         // opt=simple (optional)
                
                static let forecast = Api(query: .forecast,
                                          errorCode: err.forecast.rawValue,
                                          parameters: [.id_spot,
                                                       .id_model,
                                                       .no_wave])

                static let wforecast = Api(query: .wforecast,
                                           errorCode: err.wforecast.rawValue,
                                           parameters: [.username,     // pro users
                                                        .password,     // pro users
                                                        .id_spot,
                                                        .id_model,
                                                        .no_wave])
                
                static let wforecastLatlon = Api(query: .wforecast_latlon,
                                                 errorCode: err.wforecast_latlon.rawValue,
                                                 parameters: [.username,   // pro users
                                                              .password,   // pro users
                                                              .id_model,
                                                              .lat,
                                                              .lon,
                                                              .no_wave])
                

            }
            
            static func url(api: Api, tokens:[Http.Service.Api.Parameter: String?]) -> String {
                var strUrl = baseUrl
                strUrl += "&q=\(api.query)"
                for (k,v) in tokens {
                    if let parameters = api.parameters,
                       parameters.contains(k) {
                        if let v = v {
                            strUrl += "&\(k)=\(v)"
                        }
                    }
                }
                return strUrl
            }
        }
    }
}
