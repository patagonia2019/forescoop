//
//  Time.swift
//  Pods
//
//  Created by Javier Fuchs on 6/6/16.
//
//

import Foundation

public class Time: Object, Mappable {
    
    var hour: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0

    required public convenience init?(map: Map) {
        self.init("00:00:00")
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
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
        var aux : String = "\(type(of:self)): "
        aux += String(format: "%02d:%02d:%02d", hour, minutes, seconds)
        return aux
    }

}

extension Time {
    
    public func asDate() -> Date? {
        var interval = Double(hour)
        interval += Double(minutes * 60)
        interval += Double(seconds * 60 * 60)
        let date = Date.init(timeInterval:interval, since: Date.init())
        return date
    }

}
