//
//  Time.swift
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

public class Time: Object, Mappable {
    
    dynamic var hour: Int = 0
    dynamic var minutes: Int = 0
    dynamic var seconds: Int = 0

    required public convenience init?(map: Map) {
        #if USE_EXT_FWK
            self.init()
        #else
            self.init("00:00:00")
            mapping(map: map)
        #endif
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
                self.hour = Int(words[0]) ?? 0
                self.minutes = Int(words[1]) ?? 0
            }
            else {
                assert(false)
            }
        }
    }
    
    public override var description : String {
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
