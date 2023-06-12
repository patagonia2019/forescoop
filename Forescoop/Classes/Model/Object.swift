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

public class Object {
    public func mapping(map: [String:Any]?) throws {
        guard let map = map else { throw CustomError.notMappeable }
        if map.keys.contains("error_id") == true {
            let error = try WGError(map: map)
            throw CustomError.unexpected(code: error?.code, message: error?.localizedDescription)
        }
    }
}

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
