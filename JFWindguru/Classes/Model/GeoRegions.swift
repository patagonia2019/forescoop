//
//  GeoRegions.swift
//  Pods
//
//  Created by javierfuchs on 7/14/17.
//
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
#endif

/*
 *  GeoRegions
 *
 *  Discussion:
 *    Model object representing all the geo-regions.
 *
 * {
 *  "2": "Africa",
 *  "5": "South America",
 *  "9": "Oceania",
 *  "13": "Central America",
 *  "21": "Northern America",
 *  "29": "Caribbean",
 *  "53": "Australia and New Zealand",
 *  "142": "Asia",
 *  "150": "Europe"
 * }
 */

#if USE_EXT_FWK
    public class GeoRegions: GeoRegionsObject, Mappable {
    
        required convenience public init?(map: Map) {
            self.init()
        }

        public func mapping(map: Map) {
            for json in map.JSON {
                let jsonKV = ["id": json.key, "name": json.value]
                if let georegion = Mapper<GeoRegion>().map(JSON: jsonKV) {
                    geoRegions.append(georegion)
                }
            }
        }
    }

#else

    public class GeoRegions: GeoRegionsObject {
        
        init(dictionary: [String: AnyObject?]) {
            // TODO
        }
    }
#endif

public class GeoRegionsObject : Object {
    #if USE_EXT_FWK
    let geoRegions = List<GeoRegion>()
    #else
    public dynamic var geoRegions = [GeoRegion]()
    #endif
    
    override public var description : String {
        var aux : String = "\(type(of:self)): "
        for region in geoRegions {
            aux += "\(region.description)\n"
        }
        aux += "\n"
        return aux
    }
    
}


