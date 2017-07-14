//
//  ForecastResult.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
import ObjectMapper

/*
 *  ForecastResult
 *
 *  Discussion:
 *    Represents a model information of the stot or location when the forecast is obtained.
 *    By inheritance the common attributes are parsed and filled in Spot.
 *    Contains id of the spot, spot name, country, latitude, longitude, altitude, timezone,
 *    GMT hour offset, time of sunrise/sunset, the models (normal 3 is the public model), and the
 *    complete forecast (inside a single instance of ForecastModel)
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

public class ForecastResult: Spot {
    public var countryId: Int?
    public var latitude: Double?
    public var longitude: Double?
    public var altitude: Int?
    public var timezone: String?
    public var gmtHourOffset: Int?
    public var sunrise: String?
    public var sunset: String?
    var elapse : Elapse?
    public var models: Array<String>?
    public var currentModel: String?
    public var tides: String?
    public var forecasts: Dictionary<String, ForecastModel>

    required public init?(map: Map) {
        forecasts = [:]
        super.init(map: map)
    }
    
    
    override public func mapping(map: Map) {
        super.mapping(map: map)
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
            elapse = Elapse.init(sunrise, end: sunset)
        }
        models <- map["models"]
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
        tides <- map["tides"]
    }
    
    override public var description : String {
        var aux : String = super.description
        if let countryId = countryId {
            aux += "country # \(countryId), "
        }
        if let latitude = latitude {
            aux += "latitude \(latitude), "
        }
        if let longitude = longitude {
            aux += "longitude \(longitude), "
        }
        if let altitude = altitude {
            aux += "altitude # \(altitude), "
        }
        if let timezone = timezone {
            aux += "timezone \(timezone), "
        }
        if let gmtHourOffset = gmtHourOffset {
            aux += "gmtHourOffset \(gmtHourOffset), "
        }
        if let sunrise = sunrise {
            aux += "sunrise \(sunrise), "
        }
        if let sunset = sunset {
            aux += "sunset \(sunset), "
        }
        if let elapse = elapse {
            aux += "elapse \(elapse), "
        }
        if let models = models {
            aux += "models \(models), "
        }
        if let currentModel = currentModel {
            aux += "currentModel \(currentModel), "
        }
        if let tides = tides {
            aux += "tides \(tides).\n"
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
