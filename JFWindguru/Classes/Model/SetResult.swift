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


#if USE_EXT_FWK
    public class SetResult: SetResultObject, Mappable {

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

    }
    
#else

    public class SetResult: SetResultObject {
        init(dictionary: [String: AnyObject?]) {
            // TODO
        }
    }

#endif
        
public class SetResultObject : Object {

    // count: number of results obtained
    public dynamic var count: Int = 0
    // spots: is a dictionary forecast id/ forecast name
    #if USE_EXT_FWK
    public var sets = List<SetInfo>()
    #else
    public var sets: [SetInfo]?
    #endif


    override public var description : String {
        var aux : String = "\(type(of:self)): "
        aux += "\(count) sets, "
        #if USE_EXT_FWK
        #else
            guard let sets = sets else { return aux }
        #endif
        for forecastName in sets {
            aux += "\(forecastName)\n"
        }
        return aux
    }

}
