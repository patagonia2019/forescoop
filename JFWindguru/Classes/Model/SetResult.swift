//
//  SetResult.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation

/*
 *  SetResult
 *
 *  Discussion:
 *    Model object representing the result of c_sets
 *
 * {
 *   "count": 1,
 *   "sets": {
 *      "229823": "My forecast"
 *    }
 *  }
 */


public class SetResult: Object, Mappable {

    // count: number of results obtained
    var count: Int = 0
    // spots: is a dictionary forecast id/ forecast name

    var sets = Array<SetInfo>()
    
    required public convenience init(map: [String:Any]) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]) {
        count = map["count"] as? Int ?? 0
        guard let dict = map["sets"] as? [String:Any] else { return }
        for (k,v) in dict {
            let tmpDictionary = ["id": k, "name": v]
            if let setInfo = Mapper<SetInfo>().map(JSON: tmpDictionary) {
                sets.append(setInfo)
            }
        }
    }

    public var description : String {
        var aux : String = "\(type(of:self)): "
        aux += "\(count) sets, "
        for setInfo in sets {
            aux += "\(setInfo.description)\n"
        }
        return aux
    }

}
