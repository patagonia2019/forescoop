//
//  Knots.swift
//  Pods
//
//  Created by javierfuchs on 7/24/17.
//
//

import Foundation

public struct Knots {
    
    var knots : Float = 1
    
    public init(value: Float) {
        knots = value
    }
    
    
    public mutating func kmh() -> Float? {
        // 1 knot = 1.852 km/h
        guard let conversion = ForecastWindguruService.instance.conversionDict(),
            let kmh = conversion["kmh"] as? Float else {
                return nil
        }
        return knots * kmh
    }
    
    public mutating func mph() -> Float? {
        // 1 knot = 1.15078 mph
        //        return knots * 1.15078
        guard let conversion = ForecastWindguruService.instance.conversionDict(),
            let mph = conversion["mph"] as? Float else {
                return nil
        }
        return knots * mph
    }
    
    public mutating func mps() -> Float? {
        // 1 knot = 0.514444 mps
        //        return knots * 0.514444
        guard let conversion = ForecastWindguruService.instance.conversionDict(),
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
        guard let bftArray = ForecastWindguruService.instance.beaufortArray() else {
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
    
    public mutating func effect() -> String? {
        guard let bftArray = ForecastWindguruService.instance.beaufortArray() else {
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
    
    public mutating func effectOnSea() -> String? {
        guard let bftArray = ForecastWindguruService.instance.beaufortArray() else {
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
    
    public mutating func effectOnLand() -> String? {
        guard let bftArray = ForecastWindguruService.instance.beaufortArray() else {
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
