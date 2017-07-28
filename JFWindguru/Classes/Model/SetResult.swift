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
    public dynamic var count: Int = 0
    // spots: is a dictionary forecast id/ forecast name

#if USE_EXT_FWK
    public typealias ListSetInfo    = List<SetInfo>
#else
    public typealias ListSetInfo    = [SetInfo]
#endif

    public var sets = ListSetInfo()
    

#if USE_EXT_FWK
    required convenience public init?(map: Map) {
        self.init()
    }
    
    public func mapping(map: Map) {
        count <- map["count"]
        var dict = [String: String]()
        dict <- map["sets"]
        for (k,v) in dict {
            let jsonKV = ["id": k, "name": v]
            if let setInfo = Mapper<SetInfo>().map(JSON: jsonKV) {
                sets.append(setInfo)
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
        aux += "\(count) sets, "
        for setInfo in sets {
            aux += "\(setInfo.description)\n"
        }
        return aux
    }

}
