//
//  ForecastWindguruService+Constant.swift
//  Pods
//
//  Created by javierfuchs on 7/12/17.
//
//

import Foundation
import JFCore
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

extension ForecastWindguruService {
    
    
    
    //
    // user
    //
    public func login(with username: String?,
                      password: String?,
                      failure:@escaping (_ error: JFError?) -> Void,
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
            self?.checkData(response, url: url, api: api, context: "\(#file):\(#line):\(#column):\(#function)", failure: failure, success: success)
        }
    }
    
    //
    // searchSpots
    //
    public func searchSpots(by location: String,
                            failure:@escaping (_ error: JFError?) -> Void,
                            success:@escaping (_ spotResult: SpotResult?) -> Void) {
        
        let escapedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let tokens = [Definition.service.api.parameter.search : escapedLocation]
        let api = Definition.service.api.searchSpots
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<SpotResult>) in
            self?.checkData(response, url: url, api: api, context: "\(#file):\(#line):\(#column):\(#function)", failure: failure, success: success)
        }
    }
    
    //
    // forecast by spotId/model
    //
    public func forecast(by spotId: String,
                         model modelId:String = Definition.defaultModel,
                         failure:@escaping (_ error: JFError?) -> Void,
                         success:@escaping (_ forecastResult: ForecastResult?) -> Void)
    {
        let tokens = [Definition.service.api.parameter.id_model : modelId,
                      Definition.service.api.parameter.id_spot : spotId]
        let api = Definition.service.api.forecast
        let url = Definition.service.url(api: api, tokens: tokens)
        
        Alamofire.request(url, method:.get).validate().responseObject {
            [weak self]
            (response: DataResponse<ForecastResult>) in
            self?.checkData(response, url: url, api: api, context: "\(#file):\(#line):\(#column):\(#function)", failure: failure, success: success)
        }
    }
    
    //
    // favoriteSpots
    //
    public func favoriteSpots(with username: String?,
                      password: String?,
                      failure:@escaping (_ error: JFError?) -> Void,
                      success:@escaping (_ user: User?) -> Void) {
        
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
            (response: DataResponse<User>) in
            self?.checkData(response, url: url, api: api, context: "\(#file):\(#line):\(#column):\(#function)", failure: failure, success: success)
        }
    }


}
