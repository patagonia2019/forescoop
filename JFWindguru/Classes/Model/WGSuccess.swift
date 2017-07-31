//
//  WGSuccess.swift
//  Pods
//
//  Created by javierfuchs on 7/13/17.
//
//

import Foundation
#if USE_EXT_FWK
import ObjectMapper
#endif
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
        #if !USE_EXT_FWK
            mapping(map: map)
        #endif
    }
    
    public func mapping(map: Map) {
        #if USE_EXT_FWK
            returnString <- map["return"]
            message <- map["message"]
        #else
            returnString = map["return"] as? String
            message = map["message"] as? String
        #endif
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
