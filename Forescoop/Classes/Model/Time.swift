//
//  Time.swift
//  Forescoop
//
//  Created by Javier Fuchs on 6/6/16.
//
//

import Foundation

public class Time: Object, Mappable {
    
    var hour: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0

    required public convenience init?(map: [String: Any]?) {
        self.init("00:00:00")
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) {
    }
    
    required public init?(_ str: String?) {
        super.init()
        hour = 0
        minutes = 0
        seconds = 0
        
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

extension Time {
    public func asDate() -> Date? {
        Date.init(timeInterval: Double(hour) + Double(minutes * 60) + Double(seconds * 60 * 60), since: Date.init())
    }
}
