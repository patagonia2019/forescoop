//
//  Elapse.swift
//  Pods
//
//  Created by Javier Fuchs on 6/6/16.
//
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
    import Realm
#endif

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
    
    required convenience public init?(map: Map) {
        self.init()
    }

    public func mapping(map: Map) {
    }

#if USE_EXT_FWK
    
    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required public init() {
        super.init()
    }
    
    required public init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
#endif

    public override var description : String {
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
