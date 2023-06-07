//
//  SpotOwner.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation

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
 *      "id_spot": "48769",
 *      "spotname": "Bolonia",
 *      "country": "Spain",
 *      "id_user": "169"
 *     }
 * 
 *        
 *
 */

public class SpotOwner: Spot {

    var id_user: String? = nil

    required convenience init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }
    
    public override func mapping(map: [String:Any]?) {
        guard let map = map else { return }

        super.mapping(map: map)
        id_user = map["id_user"] as? String
    }

    override public var description: String {
        [super.description, "\(type(of:self))", id_user].compactMap{$0}.joined(separator: ", ")
    }
    
}

