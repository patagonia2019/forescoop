//
//  GeoRegions.swift
//  Pods
//
//  Created by javierfuchs on 7/14/17.
//
//

import Foundation

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

    typealias ListGeoRegion = Array<GeoRegion>
    
    var geoRegions = ListGeoRegion()
    
    required public convenience init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) {
        guard let map = map else { return }

        for json in map.JSON() {
            if let georegion = Mapper<GeoRegion>().map(JSON: ["id": json.key, "name": json.value]) {
                geoRegions.append(georegion)
            }
        }
    }    

    public var description : String {
        [
            "\(type(of:self)) \n",
            geoRegions.compactMap{ $0.description }.joined(separator: "\n")
        ]
            .compactMap{$0}
            .joined(separator: "\n")
    }
    
}


