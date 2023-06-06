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
    
    required convenience public init?(map: [String:Any]?) {
        self.init()
    }

    public func mapping(map: [String:Any]?) {
    }

    public var description : String {
        ["\(type(of:self)): ", start?.description, end?.description].compactMap {$0}.joined(separator: ", ")
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
    
    public var starting: String? {
        start?.description
    }

    public var ending: String? {
        end?.description
    }
}
