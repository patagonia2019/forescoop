//
//  GeoRegion.swift
//  Pods
//
//  Created by javierfuchs on 7/16/17.
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
 *    Model object representing the base class of GeoRegion.
 *
 *  "2": "Africa",
 */

#if USE_EXT_FWK
    public class GeoRegion: GeoRegionObject, Mappable {
        
        required convenience public init?(map: Map) {
            self.init()
        }
        
        public func mapping(map: Map) {
            id <- map["id"]
            name <- map["name"]
        }
    }

#else
    public class GeoRegion: GeoRegionObject {
        init(dictionary: [String: AnyObject?]) {
            super.init()
            id = dictionary["id"] as? String ?? nil
            name = dictionary["name"] as? String ?? nil
        }
    }
#endif


public class GeoRegionObject : Object {
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
