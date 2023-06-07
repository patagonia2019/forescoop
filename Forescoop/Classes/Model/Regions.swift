//
//  Regions.swift
//  Forescoop
//
//  Created by javierfuchs on 7/16/17.
//
//

import Foundation

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

public class Regions: Object, Mappable {

    var regions = Array<Region>()

    required public convenience init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) {
        guard let map = map else { return }

        for json in map.JSON() {
            let jsonKV = ["id": json.key, "name": json.value]
            if let region = Mapper<Region>().map(JSON: jsonKV) {
                regions.append(region)
            }
        }
    }

    public var description : String {
        "\(type(of:self))\n\n" + regions.compactMap{$0.description}.joined(separator: "\n")
    }
    
}



