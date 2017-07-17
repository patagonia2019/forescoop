//
//  Countries.swift
//  Pods
//
//  Created by javierfuchs on 7/16/17.
//
//

import Foundation
import ObjectMapper

/*
 *  Countries
 *
 *  Discussion:
 *    Model object representing the base class of Countries.
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

public class Countries: Mappable {
    
    public var countries = [Country]()
    
    required public init?(map: Map){
    }
    
    public func mapping(map: Map) {
        for json in map.JSON {
            let jsonKV = ["id": json.key, "name": json.value]
            if let country = Mapper<Country>().map(JSON: jsonKV) {
                countries.append(country)
            }
        }
    }
    public var description : String {
        var aux : String = ""
        for country in countries {
            aux += "\(country.description)\n"
        }
        aux += "\n"
        return aux
    }
    
}


