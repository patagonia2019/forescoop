//
//  Object.swift
//  Pods
//
//  Created by javierfuchs on 7/25/17.
//
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
    import Realm
    
    public class StringObject: Object {
        dynamic var value: String? = nil
        override public var description: String  {
           return value ?? ""
        }
        
        class func map(map: Map, key: String) -> List<StringObject> {
            var array = [String?]()
            array <- map[key]
            let list = List<StringObject>()
            for s in array { list.append(StringObject.init(value: [s])) }
            return list
        }
    }
    
    public class FloatObject: Object {
        let value = RealmOptional<Float>()
        override public var description: String  {
            guard let value = value.value else { return "" }
            return "\(value)"
        }
        
        class func map(map: Map, key: String) -> List<FloatObject> {
            var array = [Float?]()
            array <- map[key]
            let list = List<FloatObject>()
            for f in array { list.append(FloatObject.init(value: [f])) }
            return list
        }
    }
    
    public class IntObject: Object {
        let value = RealmOptional<Int>()
        override public var description: String  {
            guard let value = value.value else { return "" }
            return "\(value)"
        }
        
        class func map(map: Map, key: String) -> List<IntObject> {
            var array = [Int?]()
            array <- map[key]
            let list = List<IntObject>()
            for i in array { list.append(IntObject.init(value: [i])) }
            return list
        }

    }
        
    class ArrayTransform<T:RealmSwift.Object> : TransformType where T:Mappable {
        typealias Object = List<T>
        typealias JSON = Array<AnyObject>
        
        let mapper = Mapper<T>()
        
        func transformFromJSON(_ value: Any?) -> List<T>? {
            let result = List<T>()
            if let tempArr = value as! Array<AnyObject>? {
                for entry in tempArr {
                    let mapper = Mapper<T>()
                    let model : T = mapper.map(JSON: entry as! [String : Any])!
                    result.append(model)
                }
            }
            return result
        }
        
        func transformToJSON(_ value: Object?) -> JSON? {
            var results = [AnyObject]()
            if let value = value {
                for obj in value {
                    let json = mapper.toJSON(obj)
                    results.append(json as AnyObject)
                }
            }
            return results
        }
    }
#else
    public class Object : NSObject {}
#endif

