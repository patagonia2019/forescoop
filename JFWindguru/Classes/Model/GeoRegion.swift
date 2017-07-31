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

public class GeoRegion: Object, Mappable {

    dynamic var id: String? = nil
    dynamic var name: String? = nil

    required public convenience init(map: Map) {
        self.init()
        #if !USE_EXT_FWK
            mapping(map: map)
        #endif
    }
    
    public func mapping(map: Map) {
        #if USE_EXT_FWK
            id <- map["id"]
            name <- map["name"]
        #else
            id = map["id"] as? String ?? nil
            name = map["name"] as? String ?? nil
        #endif
    }

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
