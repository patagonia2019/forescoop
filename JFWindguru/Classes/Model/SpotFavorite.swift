//
//  SpotFavorite.swift
//  Pods
//
//  Created by javierfuchs on 7/12/17.
//
//

import Foundation
import ObjectMapper

/*
 *  SpotFavorite
 *
 *  Discussion:
 *    Model object representing an entity forecast favorite.
 *
 * {
 *      "id_spot": "48769",
 *      "spotname": "Bolonia",
 *      "country": "Spain",
 *      "id_user": "169"
 * }
 */


public class SpotFavorite: Mappable {

    public var id_spot: String?
    public var spotname: String?
    public var country: String?
    public var id_user: String?
    
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        id_spot <- map["id_spot"]
        spotname <- map["spotname"]
        country <- map["country"]
        id_user <- map["id_user"]
    }
    
    
    public var description : String {
        var aux : String = ""
        if let id_spot = id_spot {
            aux += "Spot # \(id_spot), "
        }
        if let spotname = spotname {
            aux += "name \(spotname), "
        }
        if let country = country {
            aux += "country \(country), "
        }
        if let id_user = id_user {
            aux += "user ud \(id_user)."
        }
        return aux
    }
    
}
