//
//  Object.swift
//  Forescoop
//
//  Created by javierfuchs on 7/31/17.
//
//

import Foundation

public protocol BaseMappable {
    /// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
    mutating func mapping(map: [String:Any]?)
}

public final class Mapper<N: BaseMappable> {
    func map(JSON map: [String:Any]?) -> N? {
        if let klass = N.self as? Mappable.Type, let jsonMap = map { // Check if object is Mappable
            if var object = klass.init(map: jsonMap) as? N {
                object.mapping(map: map)
                return object
            }
        }
        return nil
    }
}

public class Object {}

extension Dictionary {
    func JSON() -> Dictionary {
        return self
    }
}

public protocol Mappable: BaseMappable {
    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    init?(map: [String:Any]?)
}

public extension Array {
     var description: String {
        "\(type(of:self)) " + compactMap{"\($0)"}.joined(separator: ", ")
    }
}
