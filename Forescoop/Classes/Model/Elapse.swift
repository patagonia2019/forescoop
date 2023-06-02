//
//  Elapse.swift
//  Pods
//
//  Created by Javier Fuchs on 6/6/16.
//
//

import Foundation

public class Elapse: Object, Mappable {
        
    var start: Time?
    var end: Time?
    
    required public init?(elapseStart: String? = nil, elapseEnd: String? = nil) {
        super.init()
        guard let elapseStart = elapseStart,
            let elapseEnd = elapseEnd else { return nil }
        start = Time(elapseStart)
        end = Time(elapseEnd)
    }
    
    required convenience public init?(map: [String:Any]) {
        self.init()
    }

    public func mapping(map: [String:Any]) {
    }

    public var description : String {
        var aux : String = "\(type(of:self)): "
        if let start = start {
            aux += "start \(start), "
        }
        if let end = end {
            aux += "end \(end)."
        }
        return aux
    }
}

extension Elapse {
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
    
    public func starting() -> String? {
        if let start = start {
            return start.description
        }
        return nil
    }

    public func ending() -> String? {
        if let end = end {
            return end.description
        }
        return nil
    }
}
