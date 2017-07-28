//
//  SpotForecast+formatter.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/8/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation

extension SpotForecast
{
    
    private func weatherType() -> String
    {
        // 
        // information comes in UTC, contains the every 3 hours information
        //

        /*
        WeatherCloudy
        WeatherCloudyRain
        WeatherCloudyRainStorm
        WeatherCloudySnow
        WeatherCloudySnowWater
        WeatherFog
        WeatherMoon
        WeatherMoonCloud
        WeatherMoonCloudMore
        WeatherMoonCloudRain
        WeatherMoonCloudRainMore
        WeatherMoonCloudSnow
        WeatherMoonCloudSnowMore
        WeatherSun
        WeatherSunCloud
        WeatherSunCloudMore
        WeatherSunCloudRain
        WeatherSunCloudRainMore
        WeatherSunCloudSnow
        WeatherSunCloudSnowMore
        WeatherSunCloudSnowRain
    */
        if (isSunny())
        {
            if (isNight())
            {
                return "WeatherMoon"
            }
            return "WeatherSun"
        }
        return "WeatherFog"
    }

    private func isNight() -> Bool
    {
        let date = NSDate()
        if ((elapse?.containsTime(date: date)) != nil) {
            return true
        }
        return false
    }

    private func isSunny() -> Bool
    {
        // if TCDC is == 0

        if cloudCoverTotal() == 0
        {
            return true
        }
        return false
    }
    
    private func isCloudy() -> Bool
    {
        if cloudCoverTotal() == 0
        {
            return false
        }
        return true
    }
    
    private func forecast() -> Forecast?
    {
        guard let currentModel = currentModel else { return nil }
        for forecastModel in forecasts {
            if forecastModel.model == currentModel {
                return forecastModel.info
            }
        }
        return nil
    }
    
    private func valueForKey(key : TimeWeather) -> AnyObject?
    {
        guard let hhString = hourString() else { return nil }
#if USE_EXT_FWK
        for k in key.keys {
            if k.value == hhString {
                guard let index = key.keys.index(of: k) else { continue }
                if key.strings.count >= 0 && index < key.strings.count {
                    return key.strings[index].value as AnyObject
                }
                else if key.floats.count >= 0 && index < key.floats.count{
                    return key.floats[index].value.value as AnyObject
                }
            }
        }
        return nil
#else
    for k in key.keys {
        if k == hhString {
            guard let index = key.keys.index(of: k) else { continue }
            if key.strings.count >= 0 && index < key.strings.count {
                return key.strings[index] as AnyObject
            }
            else if key.floats.count >= 0 && index < key.floats.count{
                return key.floats[index] as AnyObject
            }
        }
    }
    return nil
#endif
    }

    private func cloudCoverTotal() -> Int
    {
        guard let forecast = forecast(),
            let cloudCoverTotal = forecast.cloudCoverTotal,
            let value = valueForKey(key: cloudCoverTotal) as? Int else {
                return 0
        }
        return value
    }

    
    private func hourInt() -> Int
    {
        let date = NSDate()
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: date as Date)
        
        // TODO: Timezone
        
        return hour
    }
    
    
    
    private func hour() -> Int
    {
        var hour: Int = hourInt()
        let remainder = hour % 3
        
        hour -= remainder
        
        // TODO: here the increment
        
        return hour
    }

    private func hourString() -> String?
    {
        var hourString: String
        let hh: Int = hour()

        hourString = String(format: "%d", hh)
        
        return hourString
    }
    

    public var asHourString: String
    {
        var hourString: String
        let hh: Int = hour()

        hourString = String(format: "%02d hs", hh)
        
        return hourString
    }
    
    // "WeatherSun"
    public var asCurrentWeatherImagename: String? {

        return weatherType()

    }
    
    
    // "WindDirectionN"
    public var asCurrentWindDirectionImagename: String? {
        
        guard let asCurrentWindDirectionName = asCurrentWindDirectionName else {
            return nil
        }
        return "WindDirection\(asCurrentWindDirectionName)"
    }
    
    var asCurrentWindDirectionName: String? {
        guard let forecast = forecast(),
            let windDirectionName = forecast.windDirectionName,
            let value = valueForKey(key: windDirectionName) as? String else {
                return nil
        }
        return value
    }
    
    public var asCurrentWindSpeed: String? {
        guard let forecast = forecast(),
            let windSpeed = forecast.windSpeed,
            let value = valueForKey(key: windSpeed) as? Float
            else {
                return nil
        }
        return "\(value) knots"
    }
    
    
    // "11"
    public var asCurrentTemperature: String? {
        guard let forecast = forecast(),
            let temperatureReal = forecast.temperatureReal,
            let value = valueForKey(key: temperatureReal) as? Float
            else {
                return nil
        }
        return "\(value)"
    }
    
    // "C" or "F"
    public var asCurrentUnit: String {
        return "°C"
    }
    
    // name contains the location in this object
    public var asCurrentLocation: String? {
        return spotname
    }
    
}

