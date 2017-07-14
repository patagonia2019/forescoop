//
//  Elapse.swift
//  Pods
//
//  Created by Javier Fuchs on 6/6/16.
//
//

import Foundation

public class Elapse : NSObject {
    public var start: Time?
    public var end: Time?
    
    required public init?(_ start: String, end: String) {
        self.start = Time(start)
        self.end = Time(end)
    }
 
    public func containsTime(date: NSDate) -> Bool {
        guard let dstart = start?.asDate(),
            let dend = end?.asDate()
            else {
                return false
        }
        if date.compare(dstart) == ComparisonResult.orderedAscending {
            return false
        }
        if date.compare(dend) == ComparisonResult.orderedDescending {
            return false
        }
        return true
    }
    
    public override var description : String {
        var aux : String = ""
        if let start = start {
            aux += "start \(start), "
        }
        if let end = end {
            aux += "end \(end)."
        }
        return aux
    }

}
