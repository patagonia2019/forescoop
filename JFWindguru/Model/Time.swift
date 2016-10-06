//
//  Time.swift
//  Pods
//
//  Created by Javier Fuchs on 6/6/16.
//
//

import Foundation

public class Time: NSObject {
    public var hour: Int?
    public var minutes: Int?
    public var seconds: Int?

    required public init?(_ str: String) {
        self.hour = 0
        self.minutes = 0
        self.seconds = 0
        
        let words = str.characters.split(":").map { String($0) }
        
        if words.count == 3 {
            self.hour = Int(words[0])
            self.minutes = Int(words[1])
            self.seconds = Int(words[2])
        }
        else if words.count == 2 {
            self.hour = Int(words[0])
            self.minutes = Int(words[1])
        }
        else {
            assert(false)
        }
    }

    public func asDate() -> NSDate {
        var interval = Double(hour!)
        interval += Double(minutes! * 60)
        interval += Double(seconds! * 60 * 60)
        let date = NSDate.init(timeInterval:interval, sinceDate: NSDate.init())
        return date
    }

}