//
//  Time.swift
//  Forescoop
//
//  Created by Javier Fuchs on 6/6/16.
//
//

import Foundation

public class Time {
    
    var hour: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    var gmtHourOffset: Float = 0
    
    required public init?(_ str: String?, gmtHourOffset: Float) {
        hour = 0
        minutes = 0
        seconds = 0
        self.gmtHourOffset = gmtHourOffset
        
        if let str = str {
            let words = str.components(separatedBy: ":")
            
            if words.count == 3 {
                hour = Int(words[0]) ?? 0
                minutes = Int(words[1]) ?? 0
                seconds = Int(words[2]) ?? 0
            }
            else if words.count == 2 {
                hour = Int(words[0]) ?? 0
                minutes = Int(words[1]) ?? 0
            }
            else {
                assert(false)
            }
        }
    }
    
    public var description : String {
        "\(type(of:self)) " + String(format: "%02d:%02d:%02d", hour, minutes, seconds)
    }
}

public extension Time {
    
    var timeZone: TimeZone {
        TimeZone(secondsFromGMT: Int(gmtHourOffset)*60*60)!
    }
    var timeZoneCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }
    
    var asDate: Date? {
        timeZoneCalendar.date(bySettingHour: hour, minute: minutes, second: seconds, of: Date())
    }
    
    var dateFormater: DateFormatter {
        let df = DateFormatter()
        df.timeZone = timeZone
        df.dateFormat = "HH:mm"
        return df
    }
    
    var asISO8601String: String? {
        asDate?.ISO8601Format()
    }

    var asString: String? {
        dateFormater.string(from: asDate!)
    }

}
