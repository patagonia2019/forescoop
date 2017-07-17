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
                         success:@escaping (_ spotForecast: SpotForecast?) -> Void)
    {
        let tokens = [Definition.service.api.parameter.id_model : modelId,
                      Definition.service.api.parameter.id_spot : spotId]
        let api = Definition.service.api.forecast
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<SpotForecast>) in
            self?.replicates(response, url: url, api: api,
                           context: "\(#file):\(#line):\(#column):\(#function)",
                           failure: failure, success: success)
        }
    }
    
    //    static let spotInfo = api(query: routine.spot,
    //                              errorCode: err.spot.rawValue,
    //                              parameters: [parameter.id_spot])
    public func spotInfo(bySpotId spotId: String,
                         failure:@escaping (_ error: WGError?) -> Void,
                         success:@escaping (_ spotInfo: SpotInfo?) -> Void)
    {
        let tokens = [Definition.service.api.parameter.id_spot : spotId]
        let api = Definition.service.api.spotInfo
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<SpotInfo>) in
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
                          success:@escaping (_ model: Models?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let modelId = modelId {
            tokens[Definition.service.api.parameter.id_model] = modelId
        }
        let api = Definition.service.api.modelInfo
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<Models>) in
            self?.replicates(response, url: url, api: api,
                             context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }

    //    static let modelsLatLon = api(query: routine.models_latlon,
    //                                  errorCode: err.models_latlon.rawValue,
    //                                  parameters: [parameter.lat, parameter.lon])
    public func models(bylat lat: String?, lon: String?,
                          failure:@escaping (_ error: WGError?) -> Void,
                          success:@escaping (_ models: [String]?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let lat = lat, lat.characters.count > 0,
           let lon = lon, lon.characters.count > 0 {
            tokens[Definition.service.api.parameter.lat] = lat
            tokens[Definition.service.api.parameter.lon] = lon
        }
        let api = Definition.service.api.modelsLatLon
        let url = Definition.service.url(api: api, tokens: tokens)
        
//        public func responseArray<T: Mappable>(keyPath: String, completionHandler: Response<[T], NSError> -> Void) -> Self

        Alamofire.request(url, method:.get).validate().responseString {
            [weak self]
            (response: DataResponse<String>) in
            self?.replicatesWithString(response, url: url, api: api,
                             context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    //    public func getTags(failure:@escaping (_ error: JFError) -> Void,
//                              success:@escaping (_ result: AnyObject?) -> Void) {
//        
//        guard let baseUrl = Global.service.amazonaws.url(),
//            let uri = UserDefaults.standard.string(forKey: Global.service.amazonaws.uri.key) else {
//                return
//        }
//        
//        let url = baseUrl + "/" + uri + "/" + Global.service.getTagList + "/100/0"
//        
//        Alamofire.request(url, method:.get).validate().responseString { (response: DataResponse<String>) in
//            if let result = response.result.value {
//                let array = Array(Set(result.localizedLowercase.replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "\" ", with: "").replacingOccurrences(of: "\"", with: "").components(separatedBy: ","))).sorted()
//                
//                success(array as AnyObject?)
//            }
//            else if let error = response.result.error {
//                let myerror = JFError(code: Global.ErrorCode.ServicePromotionListError.rawValue,
//                                      desc: "failed to get appId=\(Global.appId)",
//                    reason: "something get wrong on request \(url)", suggestion: "\(#file):\(#line):\(#column):\(#function)",
//                    underError: error as NSError?)
//                failure(myerror)
//            }
//        }
//    }


    
    //    static let geoRegions = api(query: routine.geo_regions,
    //                                errorCode: err.geo_regions.rawValue,
    //                                parameters: nil)
    
    public func geoRegions(failure:@escaping (_ error: WGError?) -> Void,
                      success:@escaping (_ model: GeoRegions?) -> Void) {
        
        let api = Definition.service.api.geoRegions
        let url = Definition.service.url(api: api, tokens: [:])
        
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<GeoRegions>) in
            self?.replicates(response, url: url, api: api,
                             context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    
    //    static let countries = api(query: routine.countries,
    //                               errorCode: err.countries.rawValue,
    //                               parameters: [parameter.with_spots,   // with_spots = 1 (optional)
    //                                parameter.id_georegion])            // "id_georegion" (optional)

    
    public func countries(byRegionId regionId: String?,
                          failure:@escaping (_ error: WGError?) -> Void,
                           success:@escaping (_ countries: Countries?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let regionId = regionId {
            tokens[Definition.service.api.parameter.id_georegion] = regionId
        }
        let api = Definition.service.api.countries
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<Countries>) in
            self?.replicates(response, url: url, api: api,
                             context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    
    //    static let regions = api(query: routine.regions,
    //                             errorCode: err.regions.rawValue,
    //                             parameters: [parameter.with_spots,     // with_spots = 1 (optional)
    //                                parameter.id_country])    // "id_country" (optional)

    
    public func regions(byCountryId countryId: String?,
                          failure:@escaping (_ error: WGError?) -> Void,
                          success:@escaping (_ regions: Regions?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let countryId = countryId {
            tokens[Definition.service.api.parameter.id_country] = countryId
        }
        let api = Definition.service.api.regions
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<Regions>) in
            self?.replicates(response, url: url, api: api,
                             context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    
}
