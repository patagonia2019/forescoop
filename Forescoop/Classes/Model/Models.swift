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
    
    typealias ListModel = Array<Model>

    var content: ListModel?

    required public convenience init?(map: [String: Any]?) throws {
        self.init()
        try mapping(map: map)
    }
    
    public override func mapping(map: [String:Any]?) throws {
        try super.mapping(map: map)

        content = try map?.compactMap { try Model(map: $0.value as? [String: Any]) }
    }
    
    public var description : String {
        [
            "\(type(of:self))\n",
            content?.compactMap{$0.description}
                .joined(separator: "\n")
        ]
            .compactMap {$0}
            .joined(separator: "\n")
    }
}

public extension Models {
    var sorted: [Model] {
        content?.sorted(by: {$0.oficinalName ?? "" < $1.oficinalName ?? ""}) ?? []
    }
}
