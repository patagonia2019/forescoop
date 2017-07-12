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
        
        let words = str.components(separatedBy: ":")
        
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

    public func asDate() -> Date {
        var interval = Double(hour!)
        interval += Double(minutes! * 60)
        interval += Double(seconds! * 60 * 60)
        let date = Date.init(timeInterval:interval, since: Date.init())
        return date
    }
    
    public override var description : String {
        var aux : String = "["
        aux += "\(String(describing: hour));"
        aux += "\(String(describing: minutes));"
        aux += "\(String(describing: seconds));"
        aux += "]"
        return aux
    }


}
