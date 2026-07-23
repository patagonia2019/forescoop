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
        if let spotMaps = map?["spots"] as? [[String: Any]] {
            spots = try spotMaps.compactMap { try SpotOwner(map: $0) }
        } else if let spotNames = map?["spots"] as? [String: String] {
            spots = try spotNames.compactMap { identifier, label in
                let parts = label.split(separator: "-", maxSplits: 1).map {
                    $0.trimmingCharacters(in: .whitespaces)
                }
                guard parts.count == 2 else { return nil }
                return try SpotOwner(map: [
                    "id_spot": identifier,
                    "country": parts[0],
                    "spotname": parts[1]
                ])
            }
        } else {
            spots = nil
        }
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
    var allSpots: [SpotOwner] {
        spots ?? []
    }

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
