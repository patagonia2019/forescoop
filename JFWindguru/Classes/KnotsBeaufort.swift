//
//  Float+.swift
//  Pods
//
//  Created by javierfuchs on 7/24/17.
//
//

import Foundation

public struct KnotsBeaufort {
    
    public var knots : Float = 1
    
    public init(value: Float) {
        knots = value
    }
    
    
    public mutating func kmh() -> Float? {
        // 1 knot = 1.852 km/h
        guard let conversion = conversionDict(),
            let kmh = conversion["kmh"] as? Float else {
                return nil
        }
        return knots * kmh
    }
    
    public mutating func mph() -> Float? {
        // 1 knot = 1.15078 mph
        //        return knots * 1.15078
        guard let conversion = conversionDict(),
            let mph = conversion["mph"] as? Float else {
                return nil
        }
        return knots * mph
    }
    
    public mutating func mps() -> Float? {
        // 1 knot = 0.514444 mps
        //        return knots * 0.514444
        guard let conversion = conversionDict(),
            let mps = conversion["mps"] as? Float else {
                return nil
        }
        return knots * mps
    }

    /*
     * Beaufort
     */
    
    // Thanks to https://www.windfinder.com/wind/windspeed.htm
    public mutating func bft() -> Int? {
        guard let bftArray = beaufortArray() else {
            return nil
        }
        for bftInfo in bftArray {
            if let knotsLimit = bftInfo["knotsLimit"] as? Float,
                knots > knotsLimit
            {
                return bftInfo["beaufort"] as? Int
            }
        }
        return nil
    }
    
    public mutating func effect() -> String? {
        guard let bftArray = beaufortArray() else {
            return nil
        }
        for bftInfo in bftArray {
            if let knotsLimit = bftInfo["knotsLimit"] as? Float,
                knots > knotsLimit
            {
                return bftInfo["effect"] as? String
            }
        }
        return nil
    }
    
    public mutating func effectOnSea() -> String? {
        guard let bftArray = beaufortArray() else {
            return nil
        }
        for bftInfo in bftArray {
            if let knotsLimit = bftInfo["knotsLimit"] as? Float,
                knots > knotsLimit
            {
                return bftInfo["effectOnSea"] as? String
            }
        }
        return nil
    }
    
    public mutating func effectOnLand() -> String? {
        guard let bftArray = beaufortArray() else {
            return nil
        }
        for bftInfo in bftArray {
            if let knotsLimit = bftInfo["knotsLimit"] as? Float,
                knots > knotsLimit
            {
                return bftInfo["effectOnLand"] as? String
            }
        }
        return nil
    }
    

    /*
     * Private parts
     */
    
    private struct Constants {
        static let plist = "KnotsBeaufort"
        static let frameworkBundle = "JFWindguru"
        static let bundleResource = "JFWindguru"
    }
    
    private func bundleFromFramework() -> Bundle? {
        var fwkBundle : Bundle? = nil
        for bundle in Bundle.allFrameworks {
            if let bundleIdentifier = bundle.bundleIdentifier,
                bundleIdentifier.hasSuffix(Constants.frameworkBundle) == true {
                fwkBundle = bundle
                break
            }
        }
        if let fwkBundle = fwkBundle,
           let innerBundlePath = fwkBundle.path(forResource: Constants.bundleResource, ofType: "bundle")
        {
            return Bundle.init(path: innerBundlePath)
        }
        return Bundle.init(identifier: "org.cocoapods.\(Constants.bundleResource)")
    }
 
    
    private func fwkBundle() -> Bundle? {
        guard let bundle = bundleFromFramework() else {
            assert(false, "Check if \(Constants.frameworkBundle) is framework available in bundle:\(Constants.bundleResource)")
            return nil
        }
        return bundle
    }
    
    private lazy var info : [String : AnyObject]? = {
        guard let bundle = self.fwkBundle(),
            let path = bundle.path(forResource: Constants.plist, ofType: "plist"),
            let dict = NSDictionary.init(contentsOfFile: path) as? [String: AnyObject] else {
                return nil
        }
        return dict
    }()
    
    private mutating func conversionDict() -> [String: Float?]? {
        guard let info = info else {
            return nil
        }
        return info["conversion"] as? [String: Float?]
    }
    
    private mutating func beaufortArray() -> Array<[String: Any?]>? {
        guard let info = info,
              let bft = info["bft"] as? Array<[String: Any?]> else {
            return nil
        }
        return bft
    }
    
}
