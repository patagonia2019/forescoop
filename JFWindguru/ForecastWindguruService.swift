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

/*
 *  ForecastWindguruService
 *
 *  Discussion:
 *    Query forecasts and spots, it query weather conditions from any place in the world using http://windguru.cz json rest api.
 */


public class ForecastWindguruService: NSObject {

    struct Constants {
        static let defaultModel = "3"
        static let user = "windgurufuchs"
        static let password = "eWo-C2B-z5K-E37"

        
        // https://stations.windguru.cz/json_api_stations.html
        
        static let searchSpotsUrl = "https://www.windguru.cz/int/jsonapi.php?client=wgapp&q=search_spots&username=\(user)&password=\(password)&search="
        
        // https://www.windguru.cz/int/jsonapi.php?client=wgapp&q=forecast&username=windgurufuchs&password=eWo-C2B-z5K-E37&id_model=3&id_spot=64141
        static let searchForecastUrl = "https://www.windguru.cz/int/jsonapi.php?client=wgapp&q=forecast&username=\(user)&password=\(password)"
        

    }
    //
    // Attributes only modified by this class
    //
    private var currentSpotResult: SpotResult!
    
    //
    // query location
    //
    public func queryLocation(location location: String,
                                       updateSpotDidFailWithError:(error: NSError) -> Void,
                                       didUpdateSpotResult:(spotResult: SpotResult) -> Void) {
        
        let escapedLocation = location.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())

        let URL = Constants.searchSpotsUrl + escapedLocation!
        print("URL = \(URL)")
        
        Alamofire.request(.GET, URL).responseObject(completionHandler: {
            [weak self] (response: Response<SpotResult, NSError>) in
            guard let strong = self else { return }
            if let spotResult = response.result.value {
                didUpdateSpotResult(spotResult: spotResult)
            }
            else if let error = response.result.error {
                let myerror = strong.buildError(withCode: ErrorCode.WGSearchSpot.rawValue,
                    desc: "failed to get location=\(location)",
                    reason: "something get wrong on Alamofire.request \(URL)", suggestion: "\(#file):\(#line):\(#column):\(#function)",
                    underError: error)
                updateSpotDidFailWithError(error: myerror)
            }
        })
    }

    //
    // query weather info
    //
    public func queryWeatherSpot(spot spotId: String, model modelId:String,
                                      updateForecastDidFailWithError:(error: NSError) -> Void,
                                      didUpdateForecastResult:(forecastResult: ForecastResult) -> Void)
    {
        let URL = Constants.searchForecastUrl + "&id_model=" + modelId + "&id_spot=" + spotId;
        print("URL = \(URL)")

        Alamofire.request(.GET, URL).responseObject(completionHandler: { [weak self] (response: Response<ForecastResult, NSError>) in
            guard let strong = self else { return }
            if let forecastResult = response.result.value {
                didUpdateForecastResult(forecastResult: forecastResult)
            }
            else if let error = response.result.error {
                let myerror = strong.buildError(withCode: ErrorCode.WGQueryForecastBySpotModel.rawValue,
                    desc: "failed to get id_model=\(modelId) and id_spot=\(spotId)",
                    reason: "something get wrong on Alamofire.request \(URL)", suggestion: "\(#file):\(#line):\(#column):\(#function)",
                    underError: error)
                updateForecastDidFailWithError(error: myerror)
            }
        })
    }
    
    public func queryWeatherSpot(spot spotId: String,
                                      updateForecastDidFailWithError:(error: NSError) -> Void,
                                      didUpdateForecastResult:(forecastResult: ForecastResult) -> Void)
    {
        return queryWeatherSpot(spot: spotId, model: Constants.defaultModel, updateForecastDidFailWithError: updateForecastDidFailWithError, didUpdateForecastResult: didUpdateForecastResult)
    }
    
    public func buildError(withCode code: Int, desc: String?, reason: String?, suggestion: String?,
                               underError error: NSError?) -> NSError {
        var dict = [String: AnyObject]()
        if let adesc = desc {
            dict[NSLocalizedDescriptionKey] = adesc
        }
        if let areason = reason {
            dict[NSLocalizedFailureReasonErrorKey] = areason
        }
        
        if let asuggestion = suggestion {
            dict[NSLocalizedRecoverySuggestionErrorKey] = asuggestion
        }
        if let aerror = error {
            dict[NSUnderlyingErrorKey] = aerror
        }
        let error = NSError(domain: NSBundle.mainBundle().bundleIdentifier!, code:code, userInfo: dict)
        return error
    }
    
}
