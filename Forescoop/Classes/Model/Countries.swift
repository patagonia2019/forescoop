//
//  Countries.swift
//  Forescoop
//
//  Created by javierfuchs on 7/16/17.
//
//

import Foundation

/*
 *  Countries
 *
 *  Discussion:
 *    Model object representing the base class of Countries.
 *
 * {
 * "32": "Argentina",
 * "68": "Bolivia",
 * "76": "Brazil",
 * "152": "Chile",
 * "170": "Colombia",
 * "218": "Ecuador",
 * "254": "French Guiana",
 * "600": "Paraguay",
 * "604": "Peru",
 * "858": "Uruguay",
 * "862": "Venezuela"
 * }
 */

public class Countries: Object, Mappable {
    
    var content: [Country]?

    required public convenience init(map: [String: Any]?) throws {
        self.init()
        try mapping(map: map)
    }

    public override func mapping(map: [String: Any]?) throws {
        try super.mapping(map: map)
        content = try map?.compactMap { try Country(map: ["id": $0.key, "name": $0.value]) }
    }
    
    public var description : String {
        [
            "\(type(of:self))",
            content?.compactMap({$0.description}).joined(separator: "\n"),
        ]
            .compactMap {$0}
            .joined(separator: "\n")
    }
}

public extension Countries {
    var sorted: [Country] {
        content?.sorted(by: {$0.name ?? "" < $1.name ?? ""}) ?? []
    }
}
