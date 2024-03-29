//
//  SetResult.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2023 Fuchs. All rights reserved.
//

import Foundation

/*
 *  SetResult
 *
 *  Discussion:
 *    Model object representing the result of c_sets
 *
 * {
 *   "count": 1,
 *   "sets": {
 *      "229823": "My forecast"
 *    }
 *  }
 */


public class SetResult: Object, Mappable {

    // count: number of results obtained
    var count: Int = 0
    // spots: is a dictionary forecast id/ forecast name

    var sets: [SetInfo]?
    
    required public convenience init?(map: [String: Any]?) throws {
        self.init()
        try mapping(map: map)
    }
    
    public override func mapping(map: [String: Any]?) throws {
        try super.mapping(map: map)
        count = map?["count"] as? Int ?? 0
        sets = try (map?["sets"] as? [String: Any])?.compactMap {try SetInfo(map: ["id": $0.key, "name": $0.value])}
    }

    public var description : String {
        [
            "\(type(of:self)) ",
            sets?.compactMap{$0.description}
                .joined(separator: "\n")
        ]
            .compactMap {$0}
            .joined(separator: "\n")
    }

}
