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

public class SetInfo: Object, Mappable {
    
    dynamic var id: String? = nil
    dynamic var name: String? = nil

#if USE_EXT_FWK
    required convenience public init?(map: Map) {
        self.init()
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
    
#else

    public required init(dictionary: [String: Any?]) {
        id = dictionary["id"] as? String ?? nil
        name = dictionary["name"] as? String  ?? nil
    }

#endif
    
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


