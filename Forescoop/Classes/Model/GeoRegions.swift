//
//  GeoRegions.swift
//  Forescoop
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
    
    var content = ListGeoRegion()
    
    required public convenience init?(map: [String: Any]?) throws {
        self.init()
        try mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) throws {
        guard let map = map else { throw CustomError.notMappeable }

        for json in map.JSON() {
            if let georegion = try Mapper<GeoRegion>().map(JSON: ["id": json.key, "name": json.value]) {
                content.append(georegion)
            }
        }
    }    

    public var description : String {
        [
            "\(type(of:self))\n\n",
            content
                .compactMap{ $0.description }
                .joined(separator: "\n")
        ]
            .compactMap{$0}
            .joined(separator: "\n")
    }
}

public extension GeoRegions {
    var sorted: [GeoRegion] {
        content.sorted(by: {$0.name ?? "" < $1.name ?? ""})
    }
}



