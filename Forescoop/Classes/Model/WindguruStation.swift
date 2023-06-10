//
//  WindguruStation.swift
//  Forescoop
//
//  Created by javierfuchs on 7/17/17.
//
//

import Foundation

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

    var id: String? = nil
    var station: String? = nil
    var distance: Int = 0
    var id_type: String? = nil
    var wind_avg: Int = 0

    required convenience public init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) {
        guard let map = map else { return }

        id = map["id"] as? String
        station = map["station"] as? String
        distance = map["distance"] as? Int ?? 0
        id_type = map["id_type"] as? String
        wind_avg = map["wind_avg"] as? Int ?? 0
    }
    
    public var description : String {
        ["\(type(of:self))", id, station, "\(distance)", id_type, "\(wind_avg)"]
            .compactMap {$0}
            .joined(separator: ", ")
    }
}
