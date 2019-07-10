//
//  SpotForecast+formatter.swift
//  JFWindguru
//
//  Created by Javier Fuchs on 10/8/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
import JFWindguru

extension SpotForecast
{
    
    public func weatherInfo() -> String
    {
        // 
        // information comes in UTC, contains the every 3 hours information
        //

        var str : String = ""
        if (isNight())
        {
            str = "🌙"
        } else {
            str = "☀️"
        }
        if isRaining() {
            str += "🌧"
        } else if isCloudy() {
            str += "🌥"
        }
        return str
    }

    private func isNight() -> Bool
    {
        return elapseContainsTime(date: NSDate())
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
        if cloudCoverTotal() != 0
        {
            return false
        }
        return true
    }
    
    
    private func cloudCoverTotal() -> Int
    {
        guard let forecast = getForecast(),
            let cloudCoverTotal = forecast.cloudCoverTotal(hh: hourString()) else {
                return 0
        }
        return cloudCoverTotal
    }
    
    private func isRaining() -> Bool {
        return precipitation() > 0.0
    }
    
    private func precipitation() -> Float
    {
        guard let forecast = getForecast(),
            let cloudCoverTotal = forecast.precipitation(hh: hourString()) else {
                return 0
        }
        return cloudCoverTotal
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
    
    var asCurrentWindDirectionName: String? {
        guard let forecast = getForecast() else { return nil }
        return forecast.windDirectionName(hh: hourString())
    }
    
    var asCurrentWindDirection: Float {
        guard let forecast = getForecast() else { return 0.0 }
        return Float(forecast.windDirection(hh: hourString()) ?? 0.0)
    }
    
    public var asCurrentWindSpeed: String? {
        guard let forecast = getForecast(),
            let windSpeed = forecast.windSpeed(hh: hourString()) else {
                return nil
        }
        return "\(windSpeed) knots"
    }
    
    
    // "11"
    public var asCurrentTemperature: String? {
        guard let forecast = getForecast(),
            let temperatureReal = forecast.temperatureReal(hh: hourString()) else {
                return nil
        }
        return "\(temperatureReal)\(asCurrentUnit)"
    }
    
    // "C" or "F"
    public var asCurrentUnit: String {
        return "°C"
    }
    
    // name contains the location in this object
    public var asCurrentLocation: String? {
        return name()
    }
    
}

