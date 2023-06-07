//
//  Models.swift
//  Forescoop
//
//  Created by javierfuchs on 7/13/17.
//
//

import Foundation

/*
 *  Models
 *
 *  Discussion:
 *    This is just a container of Model.
 *
 * { [ <Model> ] }
 */

public class Models: Object, Mappable {
    
    typealias ListModel    = Array<Model>

    var models = ListModel()

    required public convenience init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) {
        guard let map = map else { return }

        models = map.JSON().compactMap{$0.value as? [String: Any]}.compactMap {Mapper<Model>().map(JSON:$0)}
    }
    
    public var description : String {
        "\(type(of:self))\n" + models.compactMap{$0.description}.joined(separator: "\n")
    }
    
}
