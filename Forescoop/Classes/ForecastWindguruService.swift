//
//  ForecastWindguruService.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation


/*
 *  ForecastWindguruService
 *
 *  Discussion:
 *    Query forecasts and spots, it query weather conditions from any place 
 *    in the world using http://windguru.cz json rest api.
 */


public class ForecastWindguruService {

    public typealias FailureType = (_ error: WGError?) -> Void

    public struct Definition {
        static let defaultModel = "3"
        
        
        struct service {
            // https://www.windguru.cz/int/jsonapi.php?client=wgapp
            // scheme://server
            static let scheme = "https"
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
                return "\(service.scheme)://\(service.server)/\(service.uri)?\(service.client.key)=\(service.client.value)"
            }

            
            // https://www.windguru.cz/int/jsonapi.php?client=wgapp&app_version=1.1.10
            // {"return":"error","error_id":5,"error_message":"Missing query [q]"}
            
            struct api {

                let query : String
                let errorCode: Int
                let parameters : [String]?
                
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

                struct routine {
                    static let c_spots = "c_spots"
                    static let set_spots = "set_spots"
                    static let sets = "sets"
                    
                    static let user = "user"
                    
                    static let f_spots = "f_spots"
                    static let add_f_spot = "add_f_spot"
                    static let remove_f_spot = "remove_f_spot"
                    
                    static let forecast = "forecast"
                    static let model_info = "model_info"
                    static let models_latlon = "models_latlon"
                    
                    static let geo_regions = "geo_regions"
                    static let countries = "countries"
                    static let regions = "regions"
                    static let spots = "spots"
                    static let spot = "spot"
                    static let search_spots = "search_spots"
                    
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
                    static let no_wave = "no_wave"      // no_wave = 1 (optional)
                    static let opt = "opt"              // opt=simple (optional)
                    static let q = "q"
                    static let password = "password"
                    static let search = "search"
                    static let username = "username"
                    static let with_spots = "with_spots"
                }

                
                /* Definition.parameter.xid */

                static let user = api(query: routine.user,
                                       errorCode: err.user.rawValue,
                                       parameters: [parameter.username,
                                                    parameter.password]) // not user/pass (anonymous)
                
                static let searchSpots = api(query: routine.search_spots,
                                             errorCode: err.search_spots.rawValue,
                                             parameters: [parameter.search,
                                                          parameter.opt])
                
                static let favoriteSpots = api(query: routine.f_spots,
                                               errorCode: err.f_spots.rawValue,
                                               parameters: [parameter.username,
                                                            parameter.password,
                                                            parameter.opt]) // opt=simple (optional)
                
                static let addFavoriteSpot = api(query: routine.add_f_spot,
                                                 errorCode: err.add_f_spot.rawValue,
                                                 parameters: [parameter.username,
                                                              parameter.password,
                                                              parameter.id_spot])
                
                static let remove_f_spot = api(query: routine.remove_f_spot,
                                               errorCode: err.remove_f_spot.rawValue,
                                               parameters: [parameter.username,
                                                            parameter.password,
                                                            parameter.id_spot])
                
                static let setSpots = api(query: routine.sets,
                                          errorCode: err.sets.rawValue,
                                          parameters: [parameter.username,
                                                       parameter.password])
                
                static let addSetSpots = api(query: routine.set_spots,
                                             errorCode: err.set_spots.rawValue,
                                             parameters: [parameter.username,
                                                          parameter.password,
                                                          parameter.id_set,
                                                          parameter.opt])
                
                static let customSpots = api(query: routine.c_spots,
                                             errorCode: err.c_spots.rawValue,
                                             parameters: [parameter.username,
                                                          parameter.password,
                                                          parameter.opt])

                static let spotInfo = api(query: routine.spot,
                                          errorCode: err.spot.rawValue,
                                          parameters: [parameter.id_spot])
                
                static let modelInfo = api(query: routine.model_info,
                                           errorCode: err.model_info.rawValue,
                                           parameters: [parameter.id_model])    // id_model (optional)
                
                static let modelsLatLon = api(query: routine.models_latlon,
                                              errorCode: err.models_latlon.rawValue,
                                              parameters: [parameter.lat, parameter.lon])
                
                static let geoRegions = api(query: routine.geo_regions,
                                            errorCode: err.geo_regions.rawValue,
                                            parameters: nil)
                
                static let countries = api(query: routine.countries,
                                           errorCode: err.countries.rawValue,
                                           parameters: [parameter.with_spots,   // with_spots = 1 (optional)
                                            parameter.id_georegion])            // "id_georegion" (optional)

                static let regions = api(query: routine.regions,
                                         errorCode: err.regions.rawValue,
                                         parameters: [parameter.with_spots,     // with_spots = 1 (optional)
                                                      parameter.id_country])    // "id_country" (optional)

                static let spots = api(query: routine.spots,
                                       errorCode: err.spots.rawValue,
                                       parameters: [parameter.with_spots,       // with_spots = 1 (optional)
                                                    parameter.id_country,       // "id_country" (optional)
                                                    parameter.id_region,        // "id_region" (optional)
                                        parameter.opt])                         // opt=simple (optional)
                
                static let forecast = api(query: routine.forecast,
                                          errorCode: err.forecast.rawValue,
                                          parameters: [parameter.id_spot,
                                                       parameter.id_model,
                                                       parameter.no_wave])

                static let wforecast = api(query: routine.wforecast,
                                           errorCode: err.wforecast.rawValue,
                                           parameters: [parameter.username,     // pro users
                                                        parameter.password,     // pro users
                                                        parameter.id_spot,
                                                        parameter.id_model,
                                                        parameter.no_wave])
                
                static let wforecastLatlon = api(query: routine.wforecast_latlon,
                                                 errorCode: err.wforecast_latlon.rawValue,
                                                 parameters: [parameter.username,   // pro users
                                                              parameter.password,   // pro users
                                                              parameter.id_model,
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
    
    /*
     * Private parts
     */
    
    private struct Constants {
        static let plist = "ForecastWindguruService"
        static let frameworkBundle = "Forescoop"
        static let bundleResource = "Forescoop"
    }
    
    private func bundleFromFramework() -> Bundle? {
        var fwkBundle : Bundle? = nil
        for bundle in Bundle.allFrameworks {
            if let bundleIdentifier = bundle.bundleIdentifier,
                bundleIdentifier.hasSuffix(Constants.frameworkBundle) == true {
                fwkBundle = bundle
                break
            }
        }
        if let fwkBundle = fwkBundle,
            let innerBundlePath = fwkBundle.path(forResource: Constants.bundleResource, ofType: "bundle")
        {
            return Bundle.init(path: innerBundlePath)
        }
        return Bundle.init(identifier: "org.cocoapods.\(Constants.bundleResource)")
    }
    
    
    private func fwkBundle() -> Bundle? {
        guard let bundle = bundleFromFramework() else {
            assert(false, "Check if \(Constants.frameworkBundle) is framework available in bundle:\(Constants.bundleResource)")
            return nil
        }
        return bundle
    }
    
    private lazy var info : [String : AnyObject]? = {
        guard let bundle = self.fwkBundle(),
            let path = bundle.path(forResource: Constants.plist, ofType: "plist"),
            let dict = NSDictionary.init(contentsOfFile: path) as? [String: AnyObject] else {
                return nil
        }
        return dict
    }()
    
    public func conversionDict() -> [String: Float?]? {
        guard let info = info else {
            return nil
        }
        return info["conversion"] as? [String: Float?]
    }
    
    public func beaufortArray() -> Array<[String: Any?]>? {
        guard let info = info,
            let bft = info["bft"] as? Array<[String: Any?]> else {
                return nil
        }
        return bft
    }
    
    public func definitionArray() -> Array<[String: Any?]>? {
        guard let info = info,
            let definition = info["definition"] as? Array<[String: Any?]> else {
                return nil
        }
        return definition
    }

  
}
