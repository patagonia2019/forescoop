//
//  TimeWeather.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
import ObjectMapper

/*
 *  TimeWeather
 *
 *  Discussion:
 *    Represents a model information of the weather schedule every 3 hours from the time of 
 *    recovering.
 *    Here the information could come as Int, Double, String. A convenient AnyObject helps to 
 *    reduce code for now.
 *    
 *    TODO: the best thing to do here is to remove all the interminable attributes and use directly
 *          an array :)
 *
 *    Example: information of temperature in celsius.
 *     {
 *         "0": -1,
 *         "3": -1.4,
 *         "6": 0.1,
 *         "9": 2.7,
 *         "12": 3.3,
 *         "15": 2,
 *         "18": -3.1,
 *         "21": -4.3,
 *         "24": -5,
 *         "27": -5.5,
 *         "30": -0.7,
 *         "33": 4.7,
 *         "36": 6.3,
 *         "39": 4.9,
 *         "42": -1.4,
 *         "45": -1.7,
 *         "48": -1.7,
 *         "51": -1.5,
 *         "54": 2.8,
 *         "57": 6,
 *         "60": 7.6,
 *         "63": 7.2,
 *         "66": 1.2,
 *         "69": 0.6,
 *         "72": -0.3,
 *         "75": -0.8,
 *         "78": 2.9,
 *         "81": 6.3,
 *         "84": 8.2,
 *         "87": 7.3,
 *         "90": 2.2,
 *         "93": 1.3,
 *         "96": -0.1,
 *         "99": 1.3,
 *         "102": 2.1,
 *         "105": 5,
 *         "108": 6.5,
 *         "111": 7.1,
 *         "114": 2.5,
 *         "117": 1.6,
 *         "120": 1.7,
 *         "123": 1.8,
 *         "126": 4.1,
 *         "129": 7.2,
 *         "132": 8.2,
 *         "135": 6,
 *         "138": 3.6,
 *         "141": 3.2,
 *         "144": 3.1,
 *         "147": 3,
 *         "150": 3.3,
 *         "153": 4.7,
 *         "156": 3.8,
 *         "159": 2.3,
 *         "162": -1.5,
 *         "165": -1.5,
 *         "168": -2.6,
 *         "171": -2.9,
 *         "174": -1.1,
 *         "177": 2.4,
 *         "180": 3.9
 *     }
 *
 */


public class TimeWeather: Mappable {

    public var value: Dictionary<String, AnyObject>?

    required public init?(map: Map){
        value = [:]
    }
    
    public func mapping(map: Map) {
        for key in map.JSON.keys {
            var tmpValue : AnyObject?
            tmpValue <- map[key]
            value![key] = tmpValue
        }
    }
}
