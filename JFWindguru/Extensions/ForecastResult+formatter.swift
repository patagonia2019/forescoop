//
//  ForecastResult+formatter.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/8/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation

extension ForecastResult
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
        if (self.isSunny())
        {
            if (self.isNight())
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
        if ((self.elapse?.containsTime(date)) != nil) {
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
    
    private func forecast() -> Forecast
    {
        let forecastModel = self.forecasts![self.currentModel!]
        return (forecastModel?.info)!
    }
    
    private func valueForKey(key : TimeWeather) -> AnyObject!
    {
        let value : AnyObject!
        value = key.value![hourString()]
        return value
    }

    private func cloudCoverTotal() -> Int
    {
        let value = valueForKey(self.forecast().cloudCoverTotal!)
        return value! as! Int
    }

    
    private func hourInt() -> Int
    {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.Hour, fromDate: date)
        let hour = components.hour
        
        // TODO: Timezone
        
        return hour;
    }
    
    
    
    private func hour() -> Int
    {
        var hour: Int = self.hourInt()
        let remainder = hour % 3
        
        hour -= remainder
        
        // TODO: here the increment
        
        return hour
    }

    private func hourString() -> String
    {
        var hourString: String!
        let hour: Int = self.hour()

        hourString = String(format: "%d", hour)
        
        return hourString
    }
    

    public var asHourString: String
    {
        var hourString: String!
        let hour: Int = self.hour()

        hourString = String(format: "%02d hs", hour)
        
        return hourString
    }
    
    // "WeatherSun"
    public var asCurrentWeatherImagename: String {

        var imageName : String!
        
        imageName = self.weatherType()
        
        return imageName

    }
    
    
    // "WindDirectionN"
    public var asCurrentWindDirectionImagename: String {
        
        var imageName : String!
        
        imageName = "WindDirection\(self.asCurrentWindDirectionName)"
        
        return imageName
    }
    
    var asCurrentWindDirectionName: String {
        let value = valueForKey(self.forecast().windDirectionName!)
        return value! as! String
    }
    
    public var asCurrentWindSpeed: String {
        let windSpeed : Double = valueForKey(self.forecast().windSpeed!) as! Double
        return "\(windSpeed) knots"
    }
    
    
    // "11"
    public var asCurrentTemperature: String {
        let value = valueForKey(self.forecast().temperatureReal!)
        return "\(value! as! Int)"
    }
    
    // "C" or "F"
    public var asCurrentUnit: String {
        return "C"
    }
    
    // name contains the location in this object
    public var asCurrentLocation: String {
        return self.name!
    }
    
}

