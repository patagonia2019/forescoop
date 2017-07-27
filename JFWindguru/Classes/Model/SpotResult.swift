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
    public var spots = List<SpotOwner>()
    #else
    public var spots: [SpotOwner]?
    #endif
 
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
        super.init(dictionary: dictionary)
        count = dictionary["count"] ?? nil
        spots = dictionary["spots"] ?? nil
   }

#endif

    override public var description : String {
        var aux : String = "\(type(of:self)): "
        aux += "\n\(count) spots.\n"
        #if USE_EXT_FWK
        #else
            guard let spots = spots else { return aux }
        #endif
    
        for spot in spots {
            aux += "\(spot.description)\n"
        }
        return aux
    }
    
}
