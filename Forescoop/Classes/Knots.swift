//
//  Knots.swift
//  Forescoop
//
//  Created by javierfuchs on 7/24/17.
//
//

import Foundation

public class Knots {
    
    private var knots: Float = 1
    private lazy var definition: Definition = {
        Definition()
    }()

    public init(value: Float?) {
        knots = value ?? 1
    }
}

public extension Knots {
    
    private var beaufortArray: Array<[String: Any?]>? {
        self.definition.beaufortArray
    }
    
    private var conversionDict: [String: Double?]? {
        self.definition.conversionDict
    }

    var kmh: Float? {
        // 1 knot = 1.852 km/h
        guard let conversion = conversionDict,
            let kmh = conversion["kmh"] as? Double else {
                return nil
        }
        return knots * Float(kmh)
    }
    
    var mph: Float? {
        // 1 knot = 1.15078 mph
        //        return knots * 1.15078
        guard let conversion = conversionDict,
            let mph = conversion["mph"] as? Double else {
                return nil
        }
        return knots * Float(mph)
    }
    
    var mps: Float? {
        // 1 knot = 0.514444 mps
        //        return knots * 0.514444
        guard let conversion = conversionDict,
            let mps = conversion["mps"] as? Double else {
                return nil
        }
        return knots * Float(mps)
    }

    /*
     * Beaufort
     */
    
    // Thanks to https://www.windfinder.com/wind/windspeed.htm
    var bft: Int? {
        guard let bftArray = beaufortArray else {
            return nil
        }
        for bftInfo in bftArray {
            if let knotsLimit = bftInfo["knotsLimit"] as? Float,
                knots < knotsLimit
            {
                return bftInfo["beaufort"] as? Int
            }
        }
        return nil
    }
    
    var effect: String? {
        guard let bftArray = beaufortArray else {
            return nil
        }
        for bftInfo in bftArray {
            if let knotsLimit = bftInfo["knotsLimit"] as? Float,
                knots < knotsLimit
            {
                return bftInfo["effect"] as? String
            }
        }
        return nil
    }
    
    var effectOnSea: String? {
        guard let bftArray = beaufortArray else {
            return nil
        }
        for bftInfo in bftArray {
            if let knotsLimit = bftInfo["knotsLimit"] as? Float,
                knots < knotsLimit
            {
                return bftInfo["effectOnSea"] as? String
            }
        }
        return nil
    }
    
    var effectOnLand: String? {
        guard let bftArray = beaufortArray else {
            return nil
        }
        for bftInfo in bftArray {
            if let knotsLimit = bftInfo["knotsLimit"] as? Float,
                knots < knotsLimit
            {
                return bftInfo["effectOnLand"] as? String
            }
        }
        return nil
    }
}
