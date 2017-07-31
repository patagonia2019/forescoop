//
//  Regions.swift
//  Pods
//
//  Created by javierfuchs on 7/16/17.
//
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
#endif

/*
 *  Regions
 *
 *  Discussion:
 *    Model object representing all the regions.
 *
 * {
 * "209": "Alagoas",
 * "212": "Bahia",
 * "213": "Ceará",
 * "222": "Paraíba",
 * "223": "Paraná",
 * "224": "Pernambuco",
 * "225": "Piauí",
 * "226": "Rio de Janeiro",
 * "227": "Rio Grande do Norte",
 * "228": "Rio Grande do Sul",
 * "231": "Santa Catarina",
 * "232": "São Paulo"
 * }
 */

public class Regions: Object, Mappable {

    var regions = List<Region>()

    required public convenience init(map: Map) {
        self.init()
        #if !USE_EXT_FWK
            mapping(map: map)
        #endif
    }
    
    public func mapping(map: Map) {
        for json in map.JSON() {
            let jsonKV = ["id": json.key, "name": json.value]
            if let region = Mapper<Region>().map(JSON: jsonKV) {
                regions.append(region)
            }
        }
    }

    override public var description : String {
        var aux : String = "\(type(of:self)): "
        for region in regions {
            aux += "\(region.description)\n"
        }
        aux += "\n"
        return aux
    }
    
}



