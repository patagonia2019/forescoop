//
//  Models.swift
//  Pods
//
//  Created by javierfuchs on 7/13/17.
//
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
#endif

/*
 *  Models
 *
 *  Discussion:
 *    This is just a container of Model.
 *
 * { [ <Model> ] }
 */

#if USE_EXT_FWK
    public class Models: ModelsObject, Mappable {

        required convenience public init?(map: Map) {
            self.init()
        }
        
        public func mapping(map: Map) {
            for json in map.JSON {
                if  let jsonValue = json.value as? [String: Any],
                    let model = Mapper<Model>().map(JSON: jsonValue) {
                    models.append(model)
                }
            }
        }
    }

#else

    public class Models: ModelsObject {
        init(dictionary: [String: AnyObject?]) {
            // TODO
        }
    }

#endif
        
public class ModelsObject : Object {
    #if USE_EXT_FWK
    public var models = List<Model>()
    #else
    public dynamic var models = [Model]()
    #endif
    
    override public var description : String {
        var aux : String = "\(type(of:self)): "
        for model in models {
            aux += model.description + "\n"
        }
        return aux
    }
    
}
