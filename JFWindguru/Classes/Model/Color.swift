//
//  Color.swift
//  Pods
//
//  Created by javierfuchs on 7/27/17.
//
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
    import Realm
#endif

public class Color: Object {
        
    public dynamic var alpha: Float = 0
    public dynamic var red: Float = 0
    public dynamic var green: Float = 0
    public dynamic var blue: Float = 0
    
    required public init?(a: Float = 0, r: Float = 0, g: Float = 0, b: Float = 0) {
        super.init()
        alpha = a
        red = r
        green = g
        blue = b
    }
    
#if USE_EXT_FWK
    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required public init() {
        super.init()
    }
    
    required public init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
#else
    init(dictionary: [String: AnyObject?]) {
        // TODO
    }
#endif
    
    public override var description : String {
        var aux : String = "\(type(of:self)): "
        aux += "(\(alpha),\(red),\(green),\(blue))"
        return aux
    }
    
}
