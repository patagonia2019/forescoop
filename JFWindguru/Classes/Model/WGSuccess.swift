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
    
#if USE_EXT_FWK
    required public init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        returnString <- map["return"]
        message <- map["message"]
    }
#endif
    
    public required init(dictionary: [String: Any?]) {
        returnString = dictionary["return"] as? String
        message = dictionary["message"] as? String
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
