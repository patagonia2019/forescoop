//
//  SetInfo.swift
//  Forescoop
//
//  Created by javierfuchs on 7/27/17.
//
//

import Foundation

/*
 *  GeoRegion
 *
 *  Discussion:
 *    Model object representing the base class of Region.
 *
 * "229823": "My forecast",
 */

public class SetInfo: Object, Mappable {
    
    var id: String? = nil
    var name: String? = nil

    required public convenience init?(map: [String: Any]?) throws {
        self.init()
        try mapping(map: map)
    }
    
    public override func mapping(map: [String:Any]?) throws {
        try super.mapping(map: map)

        id = map?["id"] as? String
        name = map?["name"] as? String
    }

    public var description : String {
        ["\(type(of:self))", id, name].compactMap {$0}.joined(separator: ", ")
    }
}
