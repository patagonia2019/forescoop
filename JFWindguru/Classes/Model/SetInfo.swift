//
//  SetInfo.swift
//  Pods
//
//  Created by javierfuchs on 7/27/17.
//
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
#endif

/*
 *  GeoRegion
 *
 *  Discussion:
 *    Model object representing the base class of Region.
 *
 * "229823": "My forecast",
 */

#if USE_EXT_FWK
    public class SetInfo: SetInfoObject, Mappable {
        
        required convenience public init?(map: Map) {
            self.init()
        }
        
        public func mapping(map: Map) {
            id <- map["id"]
            name <- map["name"]
        }
        
    }
    
#else
    
    public class SetInfo: SetInfoObject {
        
        init(dictionary: [String: AnyObject?]) {
            super.init()
            id = dictionary["id"] as? String ?? nil
            name = dictionary["name"] as? String  ?? nil
        }
    }
    
#endif

public class SetInfoObject: Object {
    
    public dynamic var id: String? = nil
    public dynamic var name: String? = nil
    
    override public var description : String {
        var aux : String = "\(type(of:self)): "
        
        if let id = id {
            aux += "id: \(id), "
        }
        if let name = name {
            aux += "name: \(name)"
        }
        return aux
    }
    
}


