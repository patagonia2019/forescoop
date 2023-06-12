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
    mutating func mapping(map: [String:Any]?) throws
}

public final class Mapper<N: BaseMappable> {
    func map(JSON map: [String:Any]?) throws -> N? {
        if let klass = N.self as? Mappable.Type, let jsonMap = map { // Check if object is Mappable
            if var object = try klass.init(map: jsonMap) as? N {
                try object.mapping(map: map)
                return object
            } else {
                throw CustomError.invalidParsing
            }
        }
        throw CustomError.cannotInit
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
    init?(map: [String:Any]?) throws
}

public extension Array {
     var description: String {
        "\(type(of:self)) " + compactMap{"\($0)"}.joined(separator: ", ")
    }
}
