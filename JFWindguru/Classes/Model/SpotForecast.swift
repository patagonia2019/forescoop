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
    import Realm
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

public class SpotForecast: SpotInfo {
    
    public dynamic var currentModel: String? = nil

    var forecasts = List<ForecastModel>()

    required public convenience init?(map: Map) {
        self.init()
        #if !USE_EXT_FWK
            mapping(map: map)
        #endif
    }
    

    public override func mapping(map: Map) {
        super.mapping(map: map)
        #if USE_EXT_FWK
            for model in models {
                var tmpForecast : Forecast?
                if let modelValue = model.value {
                    tmpForecast <- map["forecast.\(modelValue)"]
                    if let forecast = tmpForecast {
                        forecasts.append(ForecastModel(modelValue: modelValue, infoForecast: forecast))
                        currentModel = model.value
                    }
                }
            }
        #else
            guard let forecastDict = map["forecast"] as? [String: Any] else { return }
            for (k,v) in forecastDict {
                let tmpDictionary = ["model" : k , "info" : v]
                let forecastModel = ForecastModel(map: tmpDictionary)
                forecasts.append(forecastModel)
                currentModel = k
            }
        #endif
    }
    

#if USE_EXT_FWK
    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required public init() {
        super.init()
    }
    
    required public init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
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
