//
//  WGError.swift
//  Pods
//
//  Created by javierfuchs on 7/11/17.
//
//

import Foundation
import ObjectMapper

/*
 *  WGError
 *
 *  Discussion:
 *    Model object representing an error in a request in Windguru api.
 *
 * {
 *   "return":"error",
 *   "error_id":2,
 *   "error_message":"Wrong password"
 * }
 */

public class WGError: Mappable {
    public var returnString: String?
    public var error_id: Int?
    public var error_message: String?
    
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map) {
        returnString <- map["return"]
        error_id <- map["error_id"]
        error_message <- map["error_message"]
    }
    
    var info : String {
        var aux : String = ""
        if let returnString = returnString {
            aux += "#\(returnString) "
        }
        if let error_id = error_id {
            aux += "# \(error_id) - "
        }
        if let error_message = error_message {
            aux += "\(error_message)."
        }
        aux += "]"
        return aux
    }
    
    var description : String {
        var aux : String = "["
        if let returnString = returnString {
            aux += "\(returnString);"
        }
        if let error_id = error_id {
            aux += "\(error_id);"
        }
        if let error_message = error_message {
            aux += "\(error_message);"
        }
        aux += "]"
        return aux
    }
    
}
