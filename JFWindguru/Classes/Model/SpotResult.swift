//
//  SpotResult.swift
//  Pods
//
//  Created by javierfuchs on 7/17/17.
//
//

import Foundation

/*
 *  SpotResult
 *
 *  Discussion:
 *    Model object representing the result of a forecast query of locations/spots.
 *
 * {
 *   "count": 2,
 *   "spots": [
 *       {
 *            "id_spot": "64141",
 *            "spotname": "Bariloche",
 *            "country": "Argentina",
 *            "id_user": "169"
 *        },
 *        {
 *            "id_spot": "209155",
 *            "spotname": "Bariloche Classic",
 *            "country": "Argentina",
 *            "id_user": "169"
 *        },
 *    ]
 * }
 */


public class SpotResult: Object, Mappable {
    //
    // count: number of results obtained
    //
    var count: Int = 0
    
    //
    // spots: is an array of SpotOwner objects
    //
    var spots = List<SpotOwner>()
 
    required public convenience init(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        count = map["count"] as? Int ?? 0
        if let dict = map["spots"] as? [Map] {
            for so in dict {
                if let spotOwner = SpotOwner.init(map: so) {
                    spots.append(spotOwner)
                }
            }
        }
    }

    override public var description : String {
        var aux : String = "\(type(of:self)): "
        aux += "\n\(count) spots.\n"
        for spot in spots {
            aux += "\(spot.description)\n"
        }
        return aux
    }
    
}

extension SpotResult {
    public func numberOfSpots() -> Int {
        return spots.count
    }

    public func firstSpot() -> SpotOwner? {
        return spots.first
    }

    public func lastSpot() -> SpotOwner? {
        return spots.last
    }
}
