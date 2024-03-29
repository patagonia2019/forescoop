//
//  SpotResult.swift
//  Forescoop
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
    var spots: [SpotOwner]?
 
    required public convenience init?(map: [String: Any]?) throws {
        self.init()
        try mapping(map: map)
    }
    
    public override func mapping(map: [String: Any]?) throws {
        try super.mapping(map: map)

        count = map?["count"] as? Int ?? 0
        spots = try (map?["spots"] as? [[String: Any]])?.compactMap({try SpotOwner(map: $0)})
    }

    public var description: String {
        [
            "\(type(of:self))",
            "\n\(count) spots.\n",
            spots?.compactMap({"\($0.description)"}).joined(separator: ", ")
        ]
            .compactMap {$0}
            .joined(separator: ", ")
    }
}

public extension SpotResult {
    var numberOfSpots: Int {
        spots?.count ?? 0
    }

    var firstSpot: SpotOwner? {
        spots?.first
    }

    var lastSpot: SpotOwner? {
        spots?.last
    }
    
    var asSpotName: String {
        lastSpot?.name ?? ""
    }
    
    func find(nickname: String) -> Spot? {
        spots?.first(where: {$0.nickname == nickname})
    }
}
