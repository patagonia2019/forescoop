
//
//  TimeWeather.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation

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


public class TimeWeather: Object, Mappable {

    var keys = [String]()
    var strings = [String]()
    var floats = [Float]()

    required public convenience init(map: [String:Any]) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]) {
        for (k,v) in map {
            keys.append(k)
            if let str = v as? String {
                strings.append(str)
            }
            else if let str = v as? Float {
                floats.append(str)
            }
        }
    }

    public var description : String {
        
        var aux : String = "\(type(of:self)): "

        let orderkeys = keys.sorted { (a, b) -> Bool in
            return a < b
        }
        for k in orderkeys {
            let key = k
            guard let index = keys.index(of: k) else { return "" }
            aux += "\(key): "
            if strings.count >= 0 && index < strings.count {
                aux += strings[index]
            }
            else if floats.count > 0 && index < floats.count {
                let v = floats[index]
                aux += "\(v)"
            }
            aux += ", "
        }
        return aux
    }

}
