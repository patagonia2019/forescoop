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

public class GeoRegions: Object, Mappable {

#if USE_EXT_FWK
    typealias ListGeoRegion    = List<GeoRegion>
#else
    typealias ListGeoRegion    = [GeoRegion]
#endif
    
    var geoRegions = ListGeoRegion()

#if USE_EXT_FWK
    required convenience public init?(map: Map) {
        self.init()
    }

    public func mapping(map: Map) {
        for json in map.JSON {
            let tmpDictionary = ["id": json.key, "name": json.value]
            if let georegion = Mapper<GeoRegion>().map(JSON: tmpDictionary) {
                geoRegions.append(georegion)
            }
        }
    }
#else
    public required init(dictionary: [String: Any?]) {
        for (k,v) in dictionary {
            let tmpDictionary = ["id": k, "name": v]
            let geoRegion = GeoRegion.init(dictionary: tmpDictionary)
            geoRegions.append(geoRegion)
        }
    }
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


