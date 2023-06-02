//
//  Object.swift
//  Pods
//
//  Created by javierfuchs on 7/31/17.
//
//

import Foundation

public class Object {}
public protocol BaseMappable {
    /// This function is where all variable mappings should occur. It is executed by Mapper during the mapping (serialization and deserialization) process.
    mutating func mapping(map: [String:Any])
}

public final class Mapper<N: BaseMappable> {
    public func map(JSON map: [String:Any]) -> N? {
        if let klass = N.self as? Mappable.Type { // Check if object is Mappable
            if var object = klass.init(map: map) as? N {
                object.mapping(map: map)
                return object
            }
        }
        return nil
    }
}

extension Dictionary {
    public func JSON() -> Dictionary {
        return self
    }
}

public protocol Mappable: BaseMappable {
    /// This function can be used to validate JSON prior to mapping. Return nil to cancel mapping at this point
    init?(map: [String:Any])
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


