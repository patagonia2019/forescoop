//
//  Country.swift
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
 * "32": "Argentina"
 */

#if USE_EXT_FWK

    public class Country: CountryObject, Mappable {
        
        required convenience public init?(map: Map) {
            self.init()
        }
        
        public func mapping(map: Map) {
            id <- map["id"]
            name <- map["name"]
        }
    }

#else
    public class Country: CountryObject {
        init(dictionary: [String: AnyObject?]) {
            super.init()
            id = dictionary["id"] as? String ?? nil
            name = dictionary["name"] as? String ?? nil
        }
    }
#endif

public class CountryObject : Object {

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


