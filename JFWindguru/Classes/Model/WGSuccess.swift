//
//  WGSuccess.swift
//  Pods
//
//  Created by javierfuchs on 7/13/17.
//
//

import Foundation
import ObjectMapper

/*
 *  WGSuccess
 *
 *  Discussion:
 *    Model object representing the a success response in some services.
 *
 * {
 *  "return": "OK",
 *  "message": "Favourite spot added"
 * }
 */

public class WGSuccess: Mappable {
    public var returnString: String?
    public var message: String?
    
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        returnString <- map["return"]
        message <- map["message"]
    }
    
    public var description : String {
        var aux : String = "\(type(of:self)): "
        if let returnString = returnString {
            aux += "\(returnString): "
        }
        if let message = message {
            aux += "\(message)\n"
        }
        return aux
    }
    
    
}
