//
//  Countries.swift
//  Pods
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
    
    var countries = Array<Country>()

    required public convenience init(map: [String:Any]?) {
        self.init()
        mapping(map: map)
    }

    public func mapping(map: [String:Any]?) {
        guard let map = map else { return }
        countries = map.JSON().compactMap({Mapper<Country>().map(JSON: ["id": $0.key, "name": $0.value])})
    }
    
    public var description : String {
        "\(type(of:self))\n" + countries.compactMap({$0.description}).joined(separator: "\n") + "\n"
    }
}
