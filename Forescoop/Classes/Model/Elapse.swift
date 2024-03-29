//
//  Elapse.swift
//  Forescoop
//
//  Created by Javier Fuchs on 6/6/16.
//
//

import Foundation

public class Elapse {
        
    var start: DateTime?
    var end: DateTime?
    
    required public init?(_ starting: String? = nil, _ ending: String? = nil, _ gmtHourOffset: Int) {
        guard let starting = starting,
            let ending = ending else { return nil }
        start = DateTime(starting, gmtHourOffset: gmtHourOffset, format: "HH:mm")
        end = DateTime(ending, gmtHourOffset: gmtHourOffset, format: "HH:mm")
    }
    
    public var description : String {
        ["\(type(of:self))", starting, ending].compactMap {$0}.joined(separator: " ")
    }
}

extension Elapse {
    public func containsTime(date: Date) -> Bool {
        guard let dstart = start?.asDate,
            let dend = end?.asDate
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
    
    public var starting: String? {
        start?.asString
    }

    public var ending: String? {
        end?.asString
    }
}
