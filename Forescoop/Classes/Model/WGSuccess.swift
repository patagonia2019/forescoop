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

public class WGSuccess: Object, Mappable {

    var returnString: String?
    var message: String?
    
    required public convenience init?(map: [String: Any]?) throws {
        self.init()
        try mapping(map: map)
    }
    
    public override func mapping(map: [String: Any]?) throws {
        try super.mapping(map: map)

        returnString = map?["return"] as? String
        message = map?["message"] as? String
    }
    
    public var description : String {
        ["\(type(of:self))", returnString, message].compactMap {$0}.joined(separator: ", ")
    }
}
