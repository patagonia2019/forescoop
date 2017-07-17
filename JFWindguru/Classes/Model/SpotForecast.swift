//
//  SpotForecast.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
import ObjectMapper

/*
 *  SpotForecast
 *
 *  Discussion:
 *    Represents a model information of the stot or location when the forecast is obtained.
 *    By inheritance the common attributes are parsed and filled in SpotInfo and Spot.
 *    Contains the complete forecast (inside a single instance of ForecastModel)
 *
 *   {
 *       "id_spot": "64141",
 *       "spotname": "Bariloche",
 *       "country": "Argentina",
 *       "id_country": 32,
 *       "lat": -41.1281,
 *       "lon": -71.348,
 *       "alt": 770,
 *       "tz": "America/Argentina/Mendoza",
 *       "gmt_hour_offset": -3,
 *       "sunrise": "07:11",
 *       "sunset": "19:54",
 *       "models": [
 *           "3"
 *       ],
 *       "tides": "0",
 *       "forecast": { ... }
 *   }
 *        
 *
 */

public class SpotForecast: SpotInfo {
    public var currentModel: String?
    public var forecasts: Dictionary<String, ForecastModel>

    required public init?(map: Map) {
        forecasts = [:]
        super.init(map: map)
    }
    
    
    override public func mapping(map: Map) {
        super.mapping(map: map)
        if let models = models {
            for model in models {
                var tmpForecast : Forecast?
                tmpForecast <- map["forecast.\(model)"]
                if let forecast = tmpForecast {
                    forecasts[model] = ForecastModel(model: model, info: forecast)
                    currentModel = model
                }
            }
        }
    }
    
    override public var description : String {
        var aux : String = super.description
        if let currentModel = currentModel {
            aux += "currentModel \(currentModel), "
        }
        if let models = models {
            for model in models {
                if let forecast = forecasts[model] {
                    aux += "Forecast model: \(model)\n\(forecast.description)\n"
                }
            }
        }

        return aux
    }


}
