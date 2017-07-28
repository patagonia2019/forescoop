
//
//  TimeWeather.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
#endif

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

#if USE_EXT_FWK
    public var keys = List<StringObject>()
    public var strings = List<StringObject>()
    public var floats = List<FloatObject>()
#else
    public var keys = [String]()
    public var strings = [String]()
    public var floats = [Float]()
#endif

#if USE_EXT_FWK
    required convenience public init?(map: Map) {
        self.init()
    }
    
    public func mapping(map: Map) {
        for key in map.JSON.keys {
            var tmpValue : AnyObject?
            tmpValue <- map[key]
            keys.append(StringObject.init(value:[key]))
            if let str = tmpValue as? String {
                strings.append(StringObject.init(value:[str]))
            }
            else if let f = tmpValue as? Float {
                floats.append(FloatObject.init(value:[f]))
            }
        }
    }

#else

    init(dictionary: [String: AnyObject?]) {
        // TODO
   }

#endif

    override public var description : String {
        
        var aux : String = "\(type(of:self)): "

        let orderkeys = keys.sorted { (a, b) -> Bool in
#if USE_EXT_FWK
            if let av = a.value, let bv = b.value,
                let avi = Int(av), let bvi = Int(bv) {
                return avi < bvi
            }
            return false
#else
            return a < b
#endif
        }
        for k in orderkeys {
#if USE_EXT_FWK
            guard let index = keys.index(of: k),
                let key = k.value
                else { return "" }
            aux += "\(key): "
            if strings.count >= 0 && index < strings.count {
                aux += strings[index].value ?? ""
            }
            else if floats.count > 0 && index < floats.count {
                if let v = floats[index].value.value {
                    aux += v.description
                }
            }
#else
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
#endif
            aux += ", "
        }
        aux += "\n"
        return aux
    }

}
