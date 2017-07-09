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
        static let user = "windgurufuchs"
        static let password = "eWo-C2B-z5K-E37"

        
        // https://stations.windguru.cz/json_api_stations.html
        
        static let searchSpotsUrl = "https://www.windguru.cz/int/jsonapi.php?client=wgapp&q=search_spots&username=\(user)&password=\(password)&search="
        
        // https://www.windguru.cz/int/jsonapi.php?client=wgapp&q=forecast&username=windgurufuchs&password=eWo-C2B-z5K-E37&id_model=3&id_spot=64141
        static let searchForecastUrl = "https://www.windguru.cz/int/jsonapi.php?client=wgapp&q=forecast&username=\(user)&password=\(password)"
        

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
