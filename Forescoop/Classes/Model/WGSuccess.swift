//
//  WGSuccess.swift
//  Forescoop
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
    
    required public init?(map: [String: Any]?) {
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) {
        guard let map = map else { return }

        returnString = map["return"] as? String
        message = map["message"] as? String
    }
    
    public var description : String {
        ["\(type(of:self))", returnString, message].compactMap {$0}.joined(separator: ", ")
    }
}
