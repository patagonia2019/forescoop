//
//  ForecastWindguruService.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import JFCore

/*
 *  ForecastWindguruService
 *
 *  Discussion:
 *    Query forecasts and spots, it query weather conditions from any place 
 *    in the world using http://windguru.cz json rest api.
 */


public class ForecastWindguruService: NSObject {

    struct Constants {
        static let defaultModel = "3"
        
        struct service {
            // https://www.windguru.cz/int/jsonapi.php?client=wgapp
            // scheme://server
            static let scheme = "http"
            static let server = "www.windguru.cz"
            static let uri = "int/jsonapi.php"
            struct client {
                static let key = "client"
                static let value = "wgapp"
            }
            // Not mandatory
            struct version {
                static let key = "app_version"
                static let value = "1.1.10"
            }
            static func baseUrl() -> String {
                return "\(service.scheme)://\(service.server)\(service.uri)?\(service.client.key)=\(service.client.value)"
            }

            
            // https://www.windguru.cz/int/jsonapi.php?client=wgapp&app_version=1.1.10
            // {"return":"error","error_id":5,"error_message":"Missing query [q]"}
            
            struct api {

                let query : String
                let parameters : [String]?
                
                struct routine {
                    static let add_f_spot = "add_f_spot"
                    static let c_spots = "c_spots"
                    static let countries = "countries"
                    static let f_spots = "f_spots"
                    static let forecast = "forecast"
                    static let geo_regions = "geo_regions"
                    static let model_info = "model_info"
                    static let models_latlon = "models_latlon"
                    static let regions = "regions"
                    static let search_spots = "search_spots"
                    static let set_spots = "set_spots"
                    static let sets = "sets"
                    static let spot = "spot"
                    static let spots = "spots"
                    static let user = "user"
                    static let wforecast = "wforecast"
                    static let wforecast_latlon = "wforecast_latlon"
                }

                struct parameter {
                    static let id_country = "id_country"
                    static let id_georegion = "id_georegion"
                    static let id_model = "id_model"
                    static let id_region = "id_region"
                    static let id_set = "id_set"
                    static let id_spot = "id_spot"
                    static let lat = "lat"
                    static let lon = "lon"
                    static let no_wave = "no_wave" // no_wave = 1 (optional)
                    static let opt = "opt" // opt=simple (optional)
                    static let q = "q"
                    static let password = "password"
                    static let search = "search"
                    static let username = "username"
                    static let with_spots = "with_spots"
                }
                
                /* Constants.parameter.xid */

                static let login = api(query: routine.user,
                                       parameters: [parameter.username,
                                                    parameter.password]) // not user/pass (anonymous)
                
                static let searchSpots = api(query: routine.search_spots,
                                             parameters: [parameter.search,
                                                          parameter.opt])
                
                static let favoriteSpots = api(query: routine.f_spots,
                                               parameters: [parameter.username,
                                                            parameter.password,
                                                            parameter.opt])
                                                // opt=simple (optional)
                
                static let addFavoriteSpot = api(query: routine.add_f_spot,
                                                 parameters: [parameter.username,
                                                              parameter.password,
                                                              parameter.id_spot])
                
                static let forecastSets = api(query: routine.sets,
                                              parameters: [parameter.username,
                                                           parameter.password,
                                                           parameter.id_spot])
                
                static let forecastSetSpots = api(query: routine.set_spots,
                                                  parameters: [parameter.username,
                                                               parameter.password,
                                                               parameter.id_set,
                                                               parameter.opt])

                static let forecastCustomSpots = api(query: routine.c_spots,
                                                     parameters: [parameter.username,
                                                                  parameter.password,
                                                                  parameter.id_set,
                                                                  parameter.opt])

                static let spotInfo = api(query: routine.spot,
                                          parameters: [parameter.id_spot])
                
                static let modelInfo = api(query: routine.model_info,
                                           parameters: [parameter.id_model]) // id_model (optional)
                
                static let modelsLatLon = api(query: routine.models_latlon,
                                              parameters: [parameter.lat, parameter.lon])
                
                static let geoRegions = api(query: routine.geo_regions,
                                            parameters: nil)
                
                static let countries = api(query: routine.countries,
                                           parameters: [parameter.with_spots,       // with_spots = 1 (optional)
                                                        parameter.id_georegion])    // "id_georegion" (optional)

                static let regions = api(query: routine.regions,
                                         parameters: [parameter.with_spots,
                                                      parameter.id_country])
                                            // with_spots = 1 (optional)
                                            // "id_country" (optional)

                static let spots = api(query: routine.spots,
                                       parameters: [parameter.with_spots, // with_spots = 1 (optional)
                                                    parameter.id_country, // "id_country" (optional)
                                                    parameter.id_region,  // "id_region" (optional)
                                                    parameter.opt])       // opt=simple (optional)

                static let forecast = api(query: routine.forecast,
                                          parameters: [parameter.id_spot,
                                                       parameter.id_model,
                                                       parameter.no_wave])

                static let wforecast = api(query: routine.wforecast,
                                           parameters: [parameter.id_spot,
                                                        parameter.id_model,
                                                        parameter.no_wave])
                
                static let wforecastLatlon = api(query: routine.wforecast_latlon,
                                           parameters: [parameter.id_model,
                                                        parameter.username,
                                                        parameter.password,
                                                        parameter.lat,
                                                        parameter.lon,
                                                        parameter.no_wave])
                

            }
            
            static func url(api: api, tokens:[String: String?]) -> String {
                var strUrl = baseUrl()
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

    
    public static let instance = ForecastWindguruService()

    //
    // Attributes only modified by this class
    //
    private var currentSpotResult: SpotResult!
    

    //
    // searchSpots
    //
    public func searchSpots(location: String,
                              failure:@escaping (_ error: JFError) -> Void,
                              success:@escaping (_ spotResult: SpotResult) -> Void) {
        
        let escapedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let tokens = [Constants.service.api.parameter.search : escapedLocation]
        let url = Constants.service.url(api: Constants.service.api.searchSpots, tokens: tokens)
        
        Alamofire.request(url, method:.get).validate().responseObject {
            (response: DataResponse<SpotResult>) in
            if let value = response.result.value {
                print("SUCCESS url = \(url) - response.result.value \(value)")
                success(value)
            }
            else if let error = response.result.error {
                print("FAILURE url = \(url) - response.result.value \(error)")
                let myerror = JFError.init(code: ErrorCode.searchSpots.rawValue,
                                           desc: "failed to get location=\(location)",
                    reason: "\(Constants.service.api.searchSpots) failed",
                    suggestion: "\(#file):\(#line):\(#column):\(#function)",
                    underError: error as NSError)
                failure(myerror)
            }
        }
    }

    //
    // query weather info
    //
    public func forecast(spot spotId: String, model modelId:String,
                                      failure:@escaping (_ error: JFError) -> Void,
                                      success:@escaping (_ forecastResult: ForecastResult) -> Void)
    {
        let tokens = [Constants.service.api.parameter.id_model : modelId,
                      Constants.service.api.parameter.id_spot : spotId]
        let url = Constants.service.url(api: Constants.service.api.forecast, tokens: tokens)
        print("URL = \(url)")
        
        Alamofire.request(url, method:.get).validate().responseObject {
            (response: DataResponse<ForecastResult>) in
            if let forecastResult = response.result.value {
                success(forecastResult)
            }
            else if let error = response.result.error {
                let myerror = JFError.init(code: ErrorCode.forecast.rawValue,
                    desc: "failed to get id_model=\(modelId) and id_spot=\(spotId)",
                    reason: "something get wrong on request \(url)",
                    suggestion: "\(#file):\(#line):\(#column):\(#function)",
                    underError: error as NSError)
                failure(myerror)
            }
        }
    }
    
    public func forecast(spot spotId: String,
                         failure:@escaping (_ error: JFError) -> Void,
                         success:@escaping (_ forecastResult: ForecastResult) -> Void)
    {
        return forecast(spot: spotId, model: Constants.defaultModel, failure: failure, success: success)
    }

}
