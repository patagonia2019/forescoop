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

#if USE_EXT_FWK
    public class Countries: CountriesObject, Mappable {
        
        required convenience public init?(map: Map) {
            self.init()
        }
        
        public func mapping(map: Map) {
            for json in map.JSON {
                let jsonKV = ["id": json.key, "name": json.value]
                if let country = Mapper<Country>().map(JSON: jsonKV) {
                    countries.append(country)
                }
            }
        }
    }
#else
    public class Countries: CountriesObject {
        
        init(dictionary: [String: AnyObject?]) {
            // TODO
        }
    }
#endif

public class CountriesObject : Object {
    #if USE_EXT_FWK
    let countries = List<Country>()
    #else
    public dynamic var countries = [Country]()
    #endif
    
    override public var description : String {
        var aux : String = "\(type(of:self)): "
        for country in countries {
            aux += "\(country.description)\n"
        }
        aux += "\n"
        return aux
    }
    
}


