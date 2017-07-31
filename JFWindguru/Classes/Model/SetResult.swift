//
//  SetResult.swift
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
    dynamic var count: Int = 0
    // spots: is a dictionary forecast id/ forecast name

    var sets = List<SetInfo>()
    
    required public convenience init(map: Map) {
        self.init()
        #if !USE_EXT_FWK
            mapping(map: map)
        #endif
    }
    
    public func mapping(map: Map) {
        #if USE_EXT_FWK
            count <- map["count"]
            var dict = [String: String]()
            dict <- map["sets"]
        #else
            count = map["count"] as? Int ?? 0
            guard let dict = map["sets"] as? Map else { return }
        #endif
        for (k,v) in dict {
            let tmpDictionary = ["id": k, "name": v]
            if let setInfo = Mapper<SetInfo>().map(JSON: tmpDictionary) {
                sets.append(setInfo)
            }
        }
    }

    override public var description : String {
        var aux : String = "\(type(of:self)): "
        aux += "\(count) sets, "
        for setInfo in sets {
            aux += "\(setInfo.description)\n"
        }
        return aux
    }

}
