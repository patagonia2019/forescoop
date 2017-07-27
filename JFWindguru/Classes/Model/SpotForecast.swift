//
//  SpotForecast.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
#endif

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

#if USE_EXT_FWK
    public class SpotForecast: SpotForecastObject, Mappable {
        
        required convenience public init?(map: Map) {
            self.init()
        }
        
        public func mapping(map: Map) {
            id_spot <- map["id_spot"]
            spotname <- map["spotname"]
            country <- map["country"]
            countryId <- map["id_country"]
            latitude <- map["lat"]
            longitude <- map["lon"]
            altitude <- map["alt"]
            timezone <- map["tz"]
            gmtHourOffset <- map["gmt_hour_offset"]
            sunrise <- map["sunrise"]
            sunset <- map["sunset"]
            if let sunrise = sunrise,
                let sunset = sunset
            {
                elapse = Elapse.init(elapseStart: sunrise, elapseEnd: sunset)
            }
            models = StringObject.map(map: map, key: "models")
            tides <- map["tides"]
            for model in models {
                var tmpForecast : Forecast?
                if let modelValue = model.value {
                    tmpForecast <- map["forecast.\(modelValue)"]
                    if let forecast = tmpForecast {
                        #if USE_EXT_FWK
                            forecasts.append(ForecastModel(model: modelValue, info: forecast))
                        #else
                            forecasts?[model] = ForecastModel(model: modelValue, info: forecast)
                        #endif
                        currentModel = model.value
                    }
                }
            }
        }
        
    }

#else

    public class SpotForecast: SpotForecastObject {
        init(dictionary: [String: AnyObject?]) {
            super.init(dictionary: dictionary)
            current_model = dictionary["current_model"] ?? nil
            forecasts = dictionary["forecasts"] ?? nil
       }
    }
#endif

public class SpotForecastObject: SpotInfoObject {
    
    public dynamic var currentModel: String? = nil
    #if USE_EXT_FWK
    public let forecasts = List<ForecastModel>()
    #else
    public var forecasts: Dictionary<String, ForecastModel>?
    #endif

    override public var description : String {
        var aux : String = super.description
        aux += "\(type(of:self)): "
        if let currentModel = currentModel {
            aux += "currentModel \(currentModel), "
        }
        for model in models {
            #if USE_EXT_FWK
            let model = model.value
            #endif
            for forecast in forecasts {
                if  let fmodel =  forecast.model, fmodel == model {
                    aux += "Forecast model: \(fmodel)\n\(forecast.description)\n"
                }
            }
        }
        return aux
    }


}
