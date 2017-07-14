//
//  ForecastWindguruService+Rest.swift
//  Pods
//
//  Created by javierfuchs on 7/12/17.
//
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

extension ForecastWindguruService {
    
    
    
    //
    //    static let user = api(query: routine.user,
    //                          errorCode: err.user.rawValue,
    //                          parameters: [parameter.username,
    //                                       parameter.password]) // not user/pass (anonymous)

    public func login(withUsername username: String?,
                      password: String?,
                      failure:@escaping (_ error: WGError?) -> Void,
                      success:@escaping (_ user: User?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let username = username,
            let password = password {
            tokens = [Definition.service.api.parameter.username : username,
                      Definition.service.api.parameter.password : password]
        }
        let api = Definition.service.api.user
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<User>) in
            self?.replicates(response, url: url, api: api,
                           context: "\(#file):\(#line):\(#column):\(#function)",
                           failure: failure, success: success)
        }
    }
    
    //    static let forecast = api(query: routine.forecast,
    //                              errorCode: err.forecast.rawValue,
    //                              parameters: [parameter.id_spot,
    //                                           parameter.id_model,
    //                                           parameter.no_wave])
    //    

    public func forecast(bySpotId spotId: String,
                         model modelId:String = Definition.defaultModel,
                         failure:@escaping (_ error: WGError?) -> Void,
                         success:@escaping (_ forecastResult: ForecastResult?) -> Void)
    {
        let tokens = [Definition.service.api.parameter.id_model : modelId,
                      Definition.service.api.parameter.id_spot : spotId]
        let api = Definition.service.api.forecast
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<ForecastResult>) in
            self?.replicates(response, url: url, api: api,
                           context: "\(#file):\(#line):\(#column):\(#function)",
                           failure: failure, success: success)
        }
    }
    
    //    static let favoriteSpots = api(query: routine.f_spots,
    //                                   errorCode: err.f_spots.rawValue,
    //                                   parameters: [parameter.username,
    //                                                parameter.password,
    //                                                parameter.opt]) // opt=simple (optional)
    public func favoriteSpots(withUsername username: String?,
                              password: String?,
                              failure:@escaping (_ error: WGError?) -> Void,
                              success:@escaping (_ spotFavorite: SpotFavorite?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let username = username,
            let password = password {
            tokens = [Definition.service.api.parameter.username : username,
                      Definition.service.api.parameter.password : password]
        }
        let api = Definition.service.api.favoriteSpots
        let url = Definition.service.url(api: api, tokens: tokens)
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<SpotFavorite>) in
            self?.replicates(response, url: url, api: api,
                           context: "\(#file):\(#line):\(#column):\(#function)",
                           failure: failure, success: success)
        }
    }
    
    //    static let addFavoriteSpot = api(query: routine.add_f_spot,
    //                                     errorCode: err.add_f_spot.rawValue,
    //                                     parameters: [parameter.username,
    //                                                  parameter.password,
    //                                                  parameter.id_spot])
    public func addFavoriteSpot(withSpotId spotId: String?,
                                username: String?,
                                password: String?,
                                failure:@escaping (_ error: WGError?) -> Void,
                                success:@escaping (_ response: WGSuccess?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let username = username,
            let password = password,
            let spotId = spotId {
            tokens = [Definition.service.api.parameter.username : username,
                      Definition.service.api.parameter.password : password,
                      Definition.service.api.parameter.id_spot : spotId]
        }
        let api = Definition.service.api.addFavoriteSpot
        let url = Definition.service.url(api: api, tokens: tokens)
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<WGSuccess>) in
            self?.replicates(response, url: url, api: api,
                           context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    
    //    static let remove_f_spot = api(query: routine.remove_f_spot,
    //                                   errorCode: err.remove_f_spot.rawValue,
    //                                   parameters: [parameter.username,
    //                                                parameter.password,
    //                                                parameter.id_spot])
    public func removeFavoriteSpot(withSpotId spotId: String?,
                                   username: String?,
                                   password: String?,
                                   failure:@escaping (_ error: WGError?) -> Void,
                                   success:@escaping (_ response: WGSuccess?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let username = username,
            let password = password,
            let spotId = spotId {
            tokens = [Definition.service.api.parameter.username : username,
                      Definition.service.api.parameter.password : password,
                      Definition.service.api.parameter.id_spot : spotId]
        }
        let api = Definition.service.api.remove_f_spot
        let url = Definition.service.url(api: api, tokens: tokens)
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<WGSuccess>) in
            self?.replicates(response, url: url, api: api,
                             context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }

    
    //    static let searchSpots = api(query: routine.search_spots,
    //                                 errorCode: err.search_spots.rawValue,
    //                                 parameters: [parameter.search,
    //                                              parameter.opt])
    public func searchSpots(byLocation location: String,
                            failure:@escaping (_ error: WGError?) -> Void,
                            success:@escaping (_ spotResult: SpotResult?) -> Void) {
        
        let escapedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let tokens = [Definition.service.api.parameter.search : escapedLocation]
        let api = Definition.service.api.searchSpots
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<SpotResult>) in
            self?.replicates(response, url: url, api: api,
                             context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }

    //  static let spots = api(query: routine.spots,
    //      errorCode: err.spots.rawValue,
    //      parameters: [parameter.with_spots,       // with_spots = 1 (optional)
    //                   parameter.id_country,       // "id_country" (optional)
    //                   parameter.id_region,        // "id_region" (optional)
    //                   parameter.opt])             // opt=simple (optional)
    
    
    public func spots(withCountryId countryId: String?,
                      regionId: String?,
                      failure:@escaping (_ error: WGError?) -> Void,
                      success:@escaping (_ spotResult: SpotResult?) -> Void) {
        
        var tokens = [Definition.service.api.parameter.with_spots : "1"]
        if let countryId = countryId {
            tokens[Definition.service.api.parameter.id_country] = countryId
        }
        if let regionId = regionId {
              tokens[Definition.service.api.parameter.id_region] = regionId
        }
        let api = Definition.service.api.spots
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<SpotResult>) in
            self?.replicates(response, url: url, api: api,
                             context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }


    //    static let modelInfo = api(query: routine.model_info,
    //          errorCode: err.model_info.rawValue,
    //          parameters: [parameter.id_model])    // id_model (optional)
    
    public func modelInfo(onlyModelId modelId: String?,
                      failure:@escaping (_ error: WGError?) -> Void,
                      success:@escaping (_ model: Model?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let modelId = modelId {
            tokens[Definition.service.api.parameter.id_model] = modelId
        }
        let api = Definition.service.api.modelInfo
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<Model>) in
            self?.replicates(response, url: url, api: api,
                             context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }

}
