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
 *    Query forecasts and spots, it query weather conditions from any place in the world using http://windguru.cz json rest api.
 */


public class ForecastWindguruService: NSObject {

    struct Constants {
        static let defaultModel = "3"

        // &username=\(user)&password=\(password)
        static let windGuruApiUrl = "https://www.windguru.cz/int/jsonapi.php?client=wgapp"

        static let searchSpotsUrl = "&q=search_spots&search="
        
        static let searchForecastUrl = "&q=forecast"
        
        

    }
    
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
        static func url() -> String {
            return "\(service.scheme)://\(service.server)\(service.uri)?\(service.client.key)=\(service.client.value)"
        }
        
        // https://www.windguru.cz/int/jsonapi.php?client=wgapp&app_version=1.1.10
        // {"return":"error","error_id":5,"error_message":"Missing query [q]"}
        
        struct api {
            let query : String
            let parameters : [String]?

            static let login = api(query: "user",
                                   parameters: ["username", "password"]) // not user/pass (anonymous)
            
            static let searchSpots = api(query: "search_spots",
                                         parameters: ["search", "opt"])
                                            // opt=simple (optional)
            
            static let favoriteSpots = api(query: "f_spots",
                                           parameters: ["username", "password", "opt"])
                                            // opt=simple (optional)
            
            static let addFavoriteSpot = api(query: "add_f_spot",
                                             parameters: ["username", "password", "id_spot"])
            
            static let forecastSets = api(query: "sets",
                                          parameters: ["username", "password", "id_spot"])
            
            static let forecastSetSpots = api(query: "set_spots",
                                              parameters: ["username", "password", "id_set", "opt"])
                                                // opt=simple (optional)

            static let forecastCustomSpots = api(query: "c_spots",
                                                 parameters: ["username", "password", "id_set", "opt"])
                                                    // opt=simple (optional)

            static let spotInfo = api(query: "spot",
                                      parameters: ["id_spot"])
            
            static let modelInfo = api(query: "model_info",
                                       parameters: ["id_model"]) // id_model (optional)
            
            static let modelsLatLon = api(query: "models_latlon",
                                          parameters: ["lat", "lon"])
            
            static let geoRegions = api(query: "geo_regions",
                                        parameters: nil)
            
            static let countries = api(query: "countries",
                                       parameters: ["with_spots", "id_georegion"])
                                        // with_spots = 1 (optional)
                                        // "id_georegion" (optional)
            
            static let regions = api(query: "regions",
                                     parameters: ["with_spots", "id_country"])
                                        // with_spots = 1 (optional)
                                        // "id_country" (optional)

            static let spots = api(query: "spots",
                                   parameters: ["with_spots", "id_country", "id_region", "opt"])
                                    // with_spots = 1 (optional)
                                    // "id_country" (optional)
                                    // "id_region" (optional)
                                    // opt=simple (optional)

            static let forecast = api(query: "forecast",
                                      parameters: ["id_spot", "id_model", "no_wave"])
                                        // no_wave = 1 (optional)

            static let wforecast = api(query: "wforecast",
                                       parameters: ["id_spot", "id_model", "no_wave"])
                                        // no_wave = 1 (optional)
            
            static let wforecastLatlon = api(query: "wforecast_latlon",
                                       parameters: ["id_model", "username", "password", "lat", "lon", "no_wave"])
                                        // no_wave = 1 (optional)

            // ?q=(query)
            static func createQuery(api: String) -> String {
                return "q=\(api)"
            }
        }
        
    }
    

    
    public static let instance = ForecastWindguruService()

    //
    // Attributes only modified by this class
    //
    private var currentSpotResult: SpotResult!
    
    //
    // query location
    //
    public func queryLocation(location: String,
                                       updateSpotDidFailWithError:@escaping (_ error: JFError) -> Void,
                                       didUpdateSpotResult:@escaping (_ spotResult: SpotResult) -> Void) {
        
        let escapedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)

        let url = Constants.searchSpotsUrl + escapedLocation!
        print("URL = \(url)")

        Alamofire.request(url, method:.get).validate().responseObject { (response: DataResponse<SpotResult>) in
            if let spotResult = response.result.value {
                didUpdateSpotResult(spotResult)
            }
            else if let error = response.result.error {
                let myerror = JFError.init(code: ErrorCode.WGSearchSpot.rawValue, desc: "failed to get location=\(location)",
                    reason: "something get wrong on Alamofire.request \(url)", suggestion: "\(#file):\(#line):\(#column):\(#function)",
                    underError: error as NSError)
                updateSpotDidFailWithError(myerror)
            }
        }
    }

    //
    // query weather info
    //
    public func queryWeatherSpot(spot spotId: String, model modelId:String,
                                      updateForecastDidFailWithError:@escaping (_ error: JFError) -> Void,
                                      didUpdateForecastResult:@escaping (_ forecastResult: ForecastResult) -> Void)
    {
        let url = Constants.searchForecastUrl + "&id_model=" + modelId + "&id_spot=" + spotId;
        print("URL = \(url)")

        
        Alamofire.request(url, method:.get).validate().responseObject { (response: DataResponse<ForecastResult>) in
            if let forecastResult = response.result.value {
                didUpdateForecastResult(forecastResult)
            }
            else if let error = response.result.error {
                let myerror = JFError.init(code: ErrorCode.WGQueryForecastBySpotModel.rawValue,
                    desc: "failed to get id_model=\(modelId) and id_spot=\(spotId)",
                    reason: "something get wrong on Alamofire.request \(url)()", suggestion: "\(#file):\(#line):\(#column):\(#function)",
                    underError: error as NSError)
                updateForecastDidFailWithError(myerror)
            }
        }
    }
    
    public func queryWeatherSpot(spot spotId: String,
                                      updateForecastDidFailWithError:@escaping (_ error: JFError) -> Void,
                                      didUpdateForecastResult:@escaping (_ forecastResult: ForecastResult) -> Void)
    {
        return queryWeatherSpot(spot: spotId, model: Constants.defaultModel, updateForecastDidFailWithError: updateForecastDidFailWithError, didUpdateForecastResult: didUpdateForecastResult)
    }

}
