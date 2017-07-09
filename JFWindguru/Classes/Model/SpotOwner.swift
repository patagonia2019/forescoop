//
//  SpotOwner.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
import ObjectMapper

/*
 *  SpotOwner
 *
 *  Discussion:
 *    Represents a model information of the stot.
 *    By inheritance the common attributes are parsed and filled in Spot.
 *    It adds 2 more properties, nick name and id of the user that controls the weather station.
 *    Probably information not useful now, but in terms of having all the data.
 *
 *     {
 *        "nickname": "oamxyz09",
 *        "id_user": "348765"
 *     }
 * 
 *        
 *
 */

public class SpotOwner: Spot {
    public var nickname: String?
    public var userId: Int?
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    override public func mapping(map: Map) {
        super.mapping(map: map)
        nickname <- map["nickname"]
        userId <- map["id_user"]
    }
}
