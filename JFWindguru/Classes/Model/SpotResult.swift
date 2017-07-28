//
//  SpotResult.swift
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
    public dynamic var count: Int = 0
    
    //
    // spots: is an array of SpotOwner objects
    //
#if USE_EXT_FWK
    public typealias ListSpotOwner    = List<SpotOwner>
#else
    public typealias ListSpotOwner    = [SpotOwner]
#endif

    public var spots = ListSpotOwner()
 
#if USE_EXT_FWK
    required convenience public init?(map: Map) {
        self.init()
    }
    
    public func mapping(map: Map) {
        count <- map["count"]
        spots <- (map["spots"], ArrayTransform<SpotOwner>())
    }
    
#else

    init(dictionary: [String: AnyObject?]) {
        count = dictionary["count"] as? Int ?? 0
//        if let dict = dictionary["spots"] as {
//            for so in dict {
//                spots.append(SpotOwner.init(dictionary:so))
//            }
//        }
   }

#endif

    override public var description : String {
        var aux : String = "\(type(of:self)): "
        aux += "\n\(count) spots.\n"
        for spot in spots {
            aux += "\(spot.description)\n"
        }
        return aux
    }
    
}
