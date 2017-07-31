//
//  Countries.swift
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
 *  Countries
 *
 *  Discussion:
 *    Model object representing the base class of Countries.
 *
 * {
 * "32": "Argentina",
 * "68": "Bolivia",
 * "76": "Brazil",
 * "152": "Chile",
 * "170": "Colombia",
 * "218": "Ecuador",
 * "254": "French Guiana",
 * "600": "Paraguay",
 * "604": "Peru",
 * "858": "Uruguay",
 * "862": "Venezuela"
 * }
 */

public class Countries: Object, Mappable {
    
    var countries = List<Country>()

    required public convenience init(map: Map) {
        self.init()
        #if !USE_EXT_FWK
        mapping(map: map)
        #endif
    }

    public func mapping(map: Map) {
        for json in map.JSON() {
            let jsonKV = ["id": json.key, "name": json.value]
            if let country = Mapper<Country>().map(JSON: jsonKV) {
                countries.append(country)
            }
        }
    }
    
    override public var description : String {
        var aux : String = "\(type(of:self)): "
        for country in countries {
            aux += "\(country.description)\n"
        }
        aux += "\n"
        return aux
    }
}
