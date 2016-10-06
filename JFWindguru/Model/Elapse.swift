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
        let dstart = start?.asDate()
        let dend = end?.asDate()
        if date.compare(dstart!) == NSComparisonResult.OrderedAscending {
            return false
        }
        if date.compare(dend!) == NSComparisonResult.OrderedDescending {
            return false
        }
        return true
    }

}