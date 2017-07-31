//
//  WindguruStation.swift
//  Pods
//
//  Created by javierfuchs on 7/17/17.
//
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
#endif

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

public class WindguruStation: Object, Mappable {

    dynamic var id: String? = nil
    dynamic var station: String? = nil
    dynamic var distance: Int = 0
    dynamic var id_type: String? = nil
    dynamic var wind_avg: Int = 0

    required public convenience init?(map: Map) {
        self.init()
        #if !USE_EXT_FWK
            mapping(map: map)
        #endif
    }
    
    public func mapping(map: Map) {
        #if USE_EXT_FWK
            id <- map["id"]
            station <- map["station"]
            distance <- map["distance"]
            id_type <- map["id_type"]
            wind_avg <- map["wind_avg"]
        #else
            id = map["id"] as? String
            station = map["station"] as? String
            distance = map["distance"] as? Int ?? 0
            id_type = map["id_type"] as? String
            wind_avg = map["wind_avg"] as? Int ?? 0
        #endif
    }
    
    override public var description : String {
        var aux : String = "\(type(of:self)): "
        if let id = id {
            aux += "id \(id) "
        }
        if let station = station {
            aux += "station \(station) "
        }
        aux += "distance \(distance) "
        if let id_type = id_type {
            aux += "id_type \(id_type) "
        }
        aux += "wind_avg \(wind_avg) "
        return aux
    }
    
    
}
