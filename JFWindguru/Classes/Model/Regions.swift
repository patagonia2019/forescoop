//
//  Regions.swift
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
 *  Regions
 *
 *  Discussion:
 *    Model object representing all the regions.
 *
 * {
 * "209": "Alagoas",
 * "212": "Bahia",
 * "213": "Ceará",
 * "222": "Paraíba",
 * "223": "Paraná",
 * "224": "Pernambuco",
 * "225": "Piauí",
 * "226": "Rio de Janeiro",
 * "227": "Rio Grande do Norte",
 * "228": "Rio Grande do Sul",
 * "231": "Santa Catarina",
 * "232": "São Paulo"
 * }
 */

#if USE_EXT_FWK
    public class Regions: RegionsObject, Mappable {
    
        required convenience public init?(map: Map) {
            self.init()
        }
    
        public func mapping(map: Map) {
            for json in map.JSON {
                let jsonKV = ["id": json.key, "name": json.value]
                if let region = Mapper<Region>().map(JSON: jsonKV) {
                    regions.append(region)
                }
            }
        }
    }

#else

    public class Regions: RegionsObject {
        
        init(dictionary: [String: AnyObject?]) {
            // TODO
        }
    }
#endif

public class RegionsObject : Object {
    #if USE_EXT_FWK
    public var regions = List<Region>()
    #else
    public dynamic var regions = [Region]()
    #endif

    override public var description : String {
        var aux : String = "\(type(of:self)): "
        for region in regions {
            aux += "\(region.description)\n"
        }
        aux += "\n"
        return aux
    }
    
}



