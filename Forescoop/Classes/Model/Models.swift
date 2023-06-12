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

    var content = ListModel()

    required public convenience init?(map: [String: Any]?) throws {
        self.init()
        try mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) throws {
        guard let map = map else { throw CustomError.notMappeable }

        content = try map.JSON().compactMap{$0.value as? [String: Any]}.compactMap {try Mapper<Model>().map(JSON:$0)}
    }
    
    public var description : String {
        "\(type(of:self))\n" + content.compactMap{$0.description}.joined(separator: "\n")
    }
}

public extension Models {
    var sorted: [Model] {
        content.sorted(by: {$0.oficinalName ?? "" < $1.oficinalName ?? ""})
    }
}
