//
//  ForecastWindguruService+Rest.swift
//  Pods
//
//  Created by javierfuchs on 7/12/17.
//
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
    import Alamofire
    import AlamofireObjectMapper
#endif


extension ForecastWindguruService {
    
    
    // user = api(query: routine.user,
    //        errorCode: err.user.rawValue,
    //       parameters: [parameter.username,
    //                   parameter.password]) // not user/pass (anonymous)

    public func login(withUsername username: String?,
                                   password: String?,
                                    failure: @escaping FailureType,
                                    success: @escaping (_ user: User?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let username = username,
            let password = password {
            tokens = [Definition.service.api.parameter.username : username,
                      Definition.service.api.parameter.password : password]
        }
        let api = Definition.service.api.user
        let url = Definition.service.url(api: api, tokens: tokens)
        Communication.request(url) {
            [weak self]
            (object) in
            self?.mapAndResponse(object,
                             url: url, api: api,
                             context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    
    // forecast = api(query: routine.forecast,
    //            errorCode: err.forecast.rawValue,
    //           parameters: [parameter.id_spot,
    //                        parameter.id_model,
    //                        parameter.no_wave])

    public func forecast(bySpotId spotId: String,
                           model modelId: String = Definition.defaultModel,
                                 failure: @escaping FailureType,
                                 success: @escaping (_ spotForecast: SpotForecast?) -> Void)
    {
        let tokens = [Definition.service.api.parameter.id_model : modelId,
                      Definition.service.api.parameter.id_spot : spotId]
        let api = Definition.service.api.forecast
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    
    //  wforecast = api(query: routine.wforecast,
    //              errorCode: err.wforecast.rawValue,
    //             parameters: [parameter.username,  // pro users
    //                          parameter.password,   // pro users
    //                          parameter.id_spot,
    //                          parameter.id_model,
    //                          parameter.no_wave])
    
    public func wforecast(bySpotId spotId: String,
                            model modelId: String = Definition.defaultModel,
                                 username: String? = nil,
                                 password: String? = nil,
                                  failure: @escaping FailureType,
                                  success: @escaping (_ spotForecast: WSpotForecast?) -> Void)
    {
        var tokens = [Definition.service.api.parameter.id_model : modelId,
                      Definition.service.api.parameter.id_spot : spotId]
        if let username = username, username.characters.count > 0,
            let password = password, password.characters.count > 0 {
            tokens = [Definition.service.api.parameter.username : username,
                      Definition.service.api.parameter.password : password]
        }
        let api = Definition.service.api.wforecast
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    
    // spotInfo = api(query: routine.spot,
    //            errorCode: err.spot.rawValue,
    //           parameters: [parameter.id_spot])
    public func spotInfo(bySpotId spotId: String,
                                 failure: @escaping FailureType,
                                 success: @escaping (_ spotInfo: SpotInfo?) -> Void)
    {
        let tokens = [Definition.service.api.parameter.id_spot : spotId]
        let api = Definition.service.api.spotInfo
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }

    // customSpots = api(query: routine.c_spots,
    //               errorCode: err.c_spots.rawValue,
    //              parameters: [parameter.username,
    //                           parameter.password,
    //                           parameter.opt])  // opt=simple (optional)
    public func customSpots(withUsername username: String?,
                                         password: String?,
                                          failure: @escaping FailureType,
                                          success: @escaping (_ spots: SpotResult?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let username = username, username.characters.count > 0,
            let password = password, password.characters.count > 0 {
            tokens = [Definition.service.api.parameter.username : username,
                      Definition.service.api.parameter.password : password]
        }
        let api = Definition.service.api.customSpots
        let url = Definition.service.url(api: api, tokens: tokens)
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    

    
    // favoriteSpots = api(query: routine.f_spots,
    //                 errorCode: err.f_spots.rawValue,
    //                parameters: [parameter.username,
    //                             parameter.password,
    //                             parameter.opt]) // opt=simple (optional)
    public func favoriteSpots(withUsername username: String?,
                                           password: String?,
                                            failure: @escaping FailureType,
                                            success: @escaping (_ spots: SpotResult?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let username = username,
            let password = password {
            tokens = [Definition.service.api.parameter.username : username,
                      Definition.service.api.parameter.password : password]
        }
        let api = Definition.service.api.favoriteSpots
        let url = Definition.service.url(api: api, tokens: tokens)
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    
    // setSpots = api(query: routine.sets,
    //            errorCode: err.sets.rawValue,
    //           parameters: [parameter.username,
    //                        parameter.password])
    //    
    public func setSpots(withUsername username: String?,
                                      password: String?,
                                       failure: @escaping FailureType,
                                       success: @escaping (_ sets: SetResult?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let username = username,
            let password = password {
            tokens = [Definition.service.api.parameter.username : username,
                      Definition.service.api.parameter.password : password]
        }
        let api = Definition.service.api.setSpots
        let url = Definition.service.url(api: api, tokens: tokens)
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    
    // addSetSpots = api(query: routine.set_spots,
    //               errorCode: err.set_spots.rawValue,
    //              parameters: [parameter.username,
    //                           parameter.password,
    //                           parameter.id_set,
    //                           parameter.opt])
    public func addSetSpots(withSetId setId: String?,
                                   username: String?,
                                   password: String?,
                                    failure: @escaping FailureType,
                                    success: @escaping (_ spots: SpotResult?) -> Void)
    {
        var tokens : [String: String?] = [:]
        if let username = username,
            let password = password,
            let id = setId {
            tokens = [Definition.service.api.parameter.id_set : id,
                      Definition.service.api.parameter.username : username,
                      Definition.service.api.parameter.password : password]
        }
        let api = Definition.service.api.addSetSpots
        let url = Definition.service.url(api: api, tokens: tokens)
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    

    
    // addFavoriteSpot = api(query: routine.add_f_spot,
    //                   errorCode: err.add_f_spot.rawValue,
    //                  parameters: [parameter.username,
    //                               parameter.password,
    //                               parameter.id_spot])
    public func addFavoriteSpot(withSpotId spotId: String?,
                                         username: String?,
                                         password: String?,
                                          failure: @escaping FailureType,
                                          success: @escaping (_ response: WGSuccess?) -> Void) {
        
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
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    
    // remove_f_spot = api(query: routine.remove_f_spot,
    //                 errorCode: err.remove_f_spot.rawValue,
    //                parameters: [parameter.username,
    //                             parameter.password,
    //                             parameter.id_spot])
    public func removeFavoriteSpot(withSpotId spotId: String?,
                                            username: String?,
                                            password: String?,
                                             failure: @escaping FailureType,
                                             success: @escaping (_ response: WGSuccess?) -> Void) {
        
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
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }

    
    // searchSpots = api(query: routine.search_spots,
    //               errorCode: err.search_spots.rawValue,
    //              parameters: [parameter.search,
    //                           parameter.opt])
    public func searchSpots(byLocation location: String,
                                        failure: @escaping FailureType,
                                        success: @escaping (_ spotResult: SpotResult?) -> Void) {
        
        let escapedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let tokens = [Definition.service.api.parameter.search : escapedLocation]
        let api = Definition.service.api.searchSpots
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }

    // spots = api(query: routine.spots,
    //         errorCode: err.spots.rawValue,
    //        parameters: [parameter.with_spots,       // with_spots = 1 (optional)
    //                     parameter.id_country,       // "id_country" (optional)
    //                     parameter.id_region,        // "id_region" (optional)
    //                     parameter.opt])             // opt=simple (optional)
    
    
    public func spots(withCountryId countryId: String?,
                                     regionId: String?,
                                      failure: @escaping FailureType,
                                      success: @escaping (_ spotResult: SpotResult?) -> Void) {
        
        var tokens = [Definition.service.api.parameter.with_spots : "1"]
        if let countryId = countryId {
            tokens[Definition.service.api.parameter.id_country] = countryId
        }
        if let regionId = regionId {
              tokens[Definition.service.api.parameter.id_region] = regionId
        }
        let api = Definition.service.api.spots
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }

    
    // modelInfo = api(query: routine.model_info,
    //             errorCode: err.model_info.rawValue,
    //            parameters: [parameter.id_model])    // id_model (optional)
    
    public func modelInfo(onlyModelId modelId: String?,
                                      failure: @escaping FailureType,
                                      success: @escaping (_ model: Models?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let modelId = modelId {
            tokens[Definition.service.api.parameter.id_model] = modelId
        }
        let api = Definition.service.api.modelInfo
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }

    // modelsLatLon = api(query: routine.models_latlon,
    //                errorCode: err.models_latlon.rawValue,
    //               parameters: [parameter.lat, parameter.lon])
    public func models(bylat lat: String?,
                             lon: String?,
                         failure: @escaping FailureType,
                         success: @escaping (_ models: [String]?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let lat = lat, lat.characters.count > 0,
           let lon = lon, lon.characters.count > 0 {
            tokens[Definition.service.api.parameter.lat] = lat
            tokens[Definition.service.api.parameter.lon] = lon
        }
        let api = Definition.service.api.modelsLatLon
        let url = Definition.service.url(api: api, tokens: tokens)

        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponseWithString(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }

    
    // geoRegions = api(query: routine.geo_regions,
    //              errorCode: err.geo_regions.rawValue,
    //             parameters: nil)
    
    public func geoRegions(withFailure failure: @escaping FailureType,
                                       success: @escaping (_ model: GeoRegions?) -> Void) {
        
        let api = Definition.service.api.geoRegions
        let url = Definition.service.url(api: api, tokens: [:])
        
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    
    // countries = api(query: routine.countries,
    //             errorCode: err.countries.rawValue,
    //            parameters: [parameter.with_spots,        // with_spots = 1 (optional)
    //                         parameter.id_georegion])     // "id_georegion" (optional)

    
    public func countries(byRegionId regionId: String?,
                                      failure: @escaping FailureType,
                                      success: @escaping (_ countries: Countries?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let regionId = regionId {
            tokens[Definition.service.api.parameter.id_georegion] = regionId
        }
        let api = Definition.service.api.countries
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }
    
    // regions = api(query: routine.regions,
    //           errorCode: err.regions.rawValue,
    //          parameters: [parameter.with_spots,     // with_spots = 1 (optional)
    //                       parameter.id_country])    // "id_country" (optional)

    
    public func regions(byCountryId countryId: String?,
                                      failure: @escaping FailureType,
                                      success: @escaping (_ regions: Regions?) -> Void) {
        
        var tokens : [String: String?] = [:]
        if let countryId = countryId {
            tokens[Definition.service.api.parameter.id_country] = countryId
        }
        let api = Definition.service.api.regions
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Communication.request(url) {
            [weak self]
            (response) in
            self?.mapAndResponse(response,
                                 url: url, api: api,
                                 context: "\(#file):\(#line):\(#column):\(#function)",
                failure: failure, success: success)
        }
    }

    /*
     * Privates part
     */
#if USE_EXT_FWK
    func mapAndResponse<T: BaseMappable>(_ response: Response?,
        url: String,
        api: ForecastWindguruService.Definition.service.api,
        context: String,
        failure:@escaping (_ error: WGError?) -> Void,
        success:@escaping (_ result: T?) -> Void)
    {
        var error : Error? = nil
        var data : Data? = nil
        if let response = response {
            data = response.data
            error = response.error
        }

        if  let response = response,
            response.error == nil,
            let responseData = response.data,
            let jsonString = String(data: responseData, encoding: .utf8),
            let responseResultValue = Mapper<T>(shouldIncludeNilValues: true).map(JSONString: jsonString),
            let error = Mapper<WGError>().map(JSONString: jsonString),
            (error.toJSON().count == 0 || error.returnString == "OK")
        {
            print("SUCCESS url = \(url) - response.result.value \(jsonString)")
            success(responseResultValue)
        }
        else {
            print("FAILURE url = \(url) - response.result.error \(String(describing: error))")
            failure(WGError.init(code: api.errorCode,
                                 desc: "failed using=\(url).",
                reason: "\(api.query) failed",
                suggestion: "\(#file):\(#line):\(#column):\(#function)",
                underError: error as NSError?,
                wgdata: data))
        }

    }

    func mapAndResponseWithString(_ response: Response?,
                            url: String,
                              api: ForecastWindguruService.Definition.service.api,
                              context: String,
                              failure:@escaping (_ error: WGError?) -> Void,
                              success:@escaping (_ result: [String]) -> Void)
    {
        var error : Error? = nil
        var data : Data? = nil
        if let response = response {
            data = response.data
            error = response.error
        }
        
        if  let response = response,
            response.error == nil,
            let responseData = response.data,
            let jsonString = String(data: responseData, encoding: .utf8),
            Mapper<WGError>().map(JSONString: jsonString) == nil
        {
            let array = Array(Set(jsonString.localizedLowercase.replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "\"", with: "").components(separatedBy: ","))).sorted()
            
            print("SUCCESS url = \(url) - response.result.value \(String(describing: jsonString))")
            success(array)
        }
        else {
            print("FAILURE url = \(url) - response.result.error \(String(describing: error))")
            failure(WGError.init(code: api.errorCode,
                                 desc: "failed using=\(url).",
                reason: "\(api.query) failed",
                suggestion: context,
                underError: error as NSError?,
                wgdata: data))
        }
    }
    
#else
    
    func mapAndResponse<T: BaseMappable>(_ response: Response?,
                        url: String,
                        api: ForecastWindguruService.Definition.service.api,
                        context: String,
                        failure:@escaping (_ error: WGError?) -> Void,
                        success:@escaping (_ result: T?) -> Void)
    {
        var error : Error? = nil
        var data : Data? = nil
        var json : [String:Any]? = nil
        if let response = response {
            data = response.data
            error = response.error
            do {
                if let data = data {
                    json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String : Any]
                }
            }
            catch {
                
            }
        }

        if  let response = response,
            let json = json,
            response.error == nil,
            let klass = T.self as? Mappable.Type, // Check if object is Mappable
            let object = klass.init(map: json) as? T
        {
            print("SUCCESS url = \(url) - response.result.value \(String(describing: json))")
            DispatchQueue.main.async(execute: {
                success(object)
            })
        }
        else {
            print("FAILURE url = \(url) - response.result.error \(String(describing: error))")
            DispatchQueue.main.async(execute: {
                failure(WGError.init(code: api.errorCode,
                                     desc: "failed using=\(url).",
                    reason: "\(api.query) failed",
                    suggestion: "\(#file):\(#line):\(#column):\(#function)",
                    underError: error as NSError?,
                    wgdata: data))
            })
        }
        
    }

    func mapAndResponseWithString(_ response: Response?,
                                  url: String,
                                  api: ForecastWindguruService.Definition.service.api,
                                  context: String,
                                  failure:@escaping (_ error: WGError?) -> Void,
                                  success:@escaping (_ result: [String]) -> Void)
    {
        var error : Error? = nil
        var data : Data? = nil
        if let response = response {
            data = response.data
            error = response.error
        }
        
        if  let response = response,
            response.error == nil,
            let responseData = response.data,
            let jsonString = String(data: responseData, encoding: .utf8)
        {
            let array = Array(Set(jsonString.localizedLowercase.replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "\"", with: "").components(separatedBy: ","))).sorted()
            
            print("SUCCESS url = \(url) - response.result.value \(String(describing: jsonString))")
            DispatchQueue.main.async(execute: {
                success(array)
            })
        }
        else {
            print("FAILURE url = \(url) - response.result.error \(String(describing: error))")
            DispatchQueue.main.async(execute: {
                failure(WGError.init(code: api.errorCode,
                                 desc: "failed using=\(url).",
                reason: "\(api.query) failed",
                suggestion: context,
                underError: error as NSError?,
                wgdata: data))
            })
        }
    }
#endif
}
