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
    var content: ListGeoRegion?
    
    required public init?(map: [String: Any]?) throws {
        super.init()
        try mapping(map: map)
    }
        
    public override func mapping(map: [String: Any]?) throws {
        try super.mapping(map: map)
        content = try map?.compactMap { try GeoRegion(map: ["id": $0.key, "name": $0.value]) }
    }

    public var description : String {
        [
            "\(type(of:self))\n\n",
            content?
                .compactMap{ $0.description }
                .joined(separator: "\n")
        ]
            .compactMap{$0}
            .joined(separator: "\n")
    }
}

public extension GeoRegions {
    var sorted: [GeoRegion] {
        content?.sorted(by: {$0.name ?? "" < $1.name ?? ""}) ?? []
    }
}



