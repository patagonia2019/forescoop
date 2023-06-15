//
//  WGError.swift
//  Forescoop
//
//  Created by javierfuchs on 7/11/17.
//
//

import Foundation
/*
 *  WGError
 *
 *  Discussion:
 *    Model object representing an error in a request in Forescoop api.
 *
 * {
 *   "return":"error",
 *   "error_id":2,
 *   "error_message":"Wrong password"
 * }
 */

public class WGError: Mappable {
    private var returnString: String?
    private var error_id: Int?
    private var error_message: String?
    
    required public init?(map: [String: Any]?) throws {
        try mapping(map: map)
    }
    
    public static func isMappable(map: [String: Any]) -> Bool {
        var ret : Bool = true
        for key in ["return", "error_id", "error_message"] {
            ret = ret && map.keys.contains(key)
        }
        return ret
    }
    
    public func mapping(map: [String: Any]?) throws {
        returnString = map?["return"] as? String
        error_id = map?["error_id"] as? Int
        error_message = map?["error_message"] as? String
    }
    
    public var description: String {
        [
            "\(type(of:self))",
            returnString,
            error_id?.description,
            error_message
        ]
            .compactMap {$0}
            .joined(separator: ", ")
    }
}

public extension WGError {
    var code: Int {
        error_id ?? -1
    }

    var localizedDescription: String {
        error_message ?? "Unknown error"
    }
    
    var message: String {
        error_message ?? "Unknown error"
    }
}

public enum CustomError: Error {
    case cannotFindSpotId

    // Throw when an issue with the parsing
    case invalidParsing

    case cannotInit

    case notMappeable

    // Throw in all other cases
    case unexpected(code: Int?, message: String?)
}

extension CustomError: CustomStringConvertible {
    
    public var localizedDescription: String {
        description
    }
    
    public var description: String {
        switch self {
        case .cannotFindSpotId:
            return "The spot id is not right."
        case .invalidParsing:
            return "The pasing is not valid."
        case .cannotInit:
            return "Cannot init"
        case .notMappeable:
            return "Cannot map"
        case .unexpected(let code, let message):
            if let code = code, let message = message {
                return "\(code): \(message)."
            } else {
                return "An unexpected error occurred"
            }
        }
    }
}
