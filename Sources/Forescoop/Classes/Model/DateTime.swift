//
//  DateTime.swift
//  Forescoop
//
//  Created by Javier Fuchs on 6/7/23.
//
//

import Foundation

public class DateTime {

    var string: String?
    var format: String = "YYYY-MM-DD HH:mm:ss"
    var gmtHourOffset: Int = 0
    
    required public init?(_ str: String?, gmtHourOffset: Int, format: String = "YYYY-MM-DD HH:mm:ss") {
        self.string = str
        self.format = format
        self.gmtHourOffset = gmtHourOffset
    }
    
    public var description : String {
        "\(type(of:self)) " + String(describing: string)
    }
}

public extension DateTime {
    var asISO8601String: String? {
        asDate?.ISO8601Format()
    }
    var asString: String? {
        asDate != nil ? dateTimeFormater.string(from: asDate!) : nil
    }
    var asDate: Date? {
        string != nil ? dateTimeFormater.date(from: string!) : nil
    }
}

private extension DateTime {
    var timeZone: TimeZone {
        TimeZone(secondsFromGMT: Int(gmtHourOffset)*60*60)!
    }
    
    var timeZoneCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }
    
    var dateTimeFormater: DateFormatter {
        let df = DateFormatter()
        df.timeZone = timeZone
        df.dateFormat = format
        return df
    }
}
