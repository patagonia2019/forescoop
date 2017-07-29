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
        return v() ?? ""
    }
    
    func v() -> String? {
        return value
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
        guard let v = v() else { return "" }
        return "\(v)"
    }
    
    func v() -> Float? {
        return value.value
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
        guard let v = v() else { return "" }
        return "\(v)"
    }
    
    func v() -> Int? {
        return value.value
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
public protocol Mappable {
    init(dictionary: [String: Any?])
}

open class DateTransform {
    public typealias Object = Date
    public typealias JSON = Double
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Date? {
        if let timeInt = value as? Double {
            return Date(timeIntervalSince1970: TimeInterval(timeInt))
        }
        
        if let timeStr = value as? String {
            return Date(timeIntervalSince1970: TimeInterval(atof(timeStr)))
        }
        
        return nil
    }
    
    open func transformToJSON(_ value: Date?) -> Double? {
        if let date = value {
            return Double(date.timeIntervalSince1970)
        }
        return nil
    }
}

#endif

#if USE_EXT_FWK
public typealias ListIntObject    = List<IntObject>
public typealias ListFloatObject  = List<FloatObject>
public typealias ListStringObject = List<StringObject>
#else
public typealias ListIntObject    = [Int]
public typealias ListFloatObject  = [Float]
public typealias ListStringObject = [String]
#endif

#if USE_EXT_FWK
extension List where Iterator.Element == StringObject {
    public func printDescription() -> String {
        var aux : String = "\(type(of:self)): "
        
        for i in 0..<count {
            let r = self[i]
            if let value = r.v() {
                aux += "\(value), "
            }
            else {
                aux += ", "
            }
        }
        return aux
    }
}
extension List where Iterator.Element == IntObject {
    public func printDescription() -> String {
        var aux : String = "\(type(of:self)): "
        
        for i in 0..<count {
            let r = self[i]
            if let value = r.v() {
                aux += "\(value), "
            }
            else {
                aux += ", "
            }
        }
        return aux
    }
}
extension List where Iterator.Element == FloatObject {
    public func printDescription() -> String {
        var aux : String = "\(type(of:self)): "

        for i in 0..<count {
            let r = self[i]
            if let value = r.v() {
                aux += "\(value), "
            }
            else {
                aux += ", "
            }
        }
        return aux
    }
}
#else
extension Array where Iterator.Element == String {
    public func printDescription() -> String {
        var aux : String = "\(type(of:self)): "
        
        for i in 0..<count {
            let r = self[i]
            aux += "\(r), "
        }
        return aux
    }
}
extension Array where Iterator.Element == Int {
    public func printDescription() -> String {
        var aux : String = "\(type(of:self)): "
        
        for i in 0..<count {
            let r = self[i]
            aux += "\(r), "
        }
        return aux
    }
}
extension Array where Iterator.Element == Float {
    public func printDescription() -> String {
        var aux : String = "\(type(of:self)): "
        
        for i in 0..<count {
            let r = self[i]
            aux += "\(r), "
        }
        return aux
    }
}

extension String {
    public func v() -> String {
        return self
    }
}

extension Float {
    public func v() -> Float {
        return self
    }
}
    
extension Int {
    public func v() -> Int {
        return self
    }
}
#endif
