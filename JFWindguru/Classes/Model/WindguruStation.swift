//
//  WindguruStation.swift
//  Pods
//
//  Created by javierfuchs on 7/17/17.
//
//

import Foundation
import ObjectMapper

/*
 *  SpotOwner
 *
 *  Discussion:
 *    Represents a model information of the stot.
 *    By inheritance the common attributes are parsed and filled in Spot.
 *    It adds 2 more properties, nick name and id of the user that controls the weather station.
 *    Probably information not useful now, but in terms of having all the data.
 *
 *      {
 *          "id": "292",
 *          "station": "Agrotécnico 4 - San Pedro, Guasayan - Sgo del Estero, MeteoStar",
 *          "distance": 0,
 *          "id_type": "7",
 *          "wind_avg": 2
 *      }
 *
 *
 *
 */

public class WindguruStation: Mappable {
    public var id: String?
    public var station: String?
    public var distance: Int?
    public var id_type: String?
    public var wind_avg: Int?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        station <- map["station"]
        distance <- map["distance"]
        id_type <- map["id_type"]
        wind_avg <- map["wind_avg"]
    }
    
    public var description : String {
        var aux : String = ""
        if let id = id {
            aux += "id \(id) "
        }
        if let station = station {
            aux += "station \(station) "
        }
        if let distance = distance {
            aux += "distance \(distance) "
        }
        if let id_type = id_type {
            aux += "id_type \(id_type) "
        }
        if let wind_avg = wind_avg {
            aux += "wind_avg \(wind_avg) "
        }
        return aux
    }
    
    
}
