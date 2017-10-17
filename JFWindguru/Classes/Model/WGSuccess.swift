//
//  WGSuccess.swift
//  Pods
//
//  Created by javierfuchs on 7/13/17.
//
//

import Foundation
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

    var returnString: String?
    var message: String?
    
    required public init?(map: Map) {
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        returnString = map["return"] as? String
        message = map["message"] as? String
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
