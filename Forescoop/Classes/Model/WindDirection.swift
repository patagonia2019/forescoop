//
//  WindDirection.swift
//  Forescoop
//
//  Created by fox on 06/06/2023.
//

import Foundation

public struct WindDirection {
    let value: Int
    
    var name: String? {
        let compass = ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW","N"]
        let total = compass.count
        let k360: Int = 360
        let module = Double(value % k360)
        let index = Int(module / Double(k360 / (total - 1))) + 1 // degrees for each sector
        if index >= 0 && index < compass.count {
            return compass[index]
        }
        return nil
    }
    
    var description : String {
        name ?? "\(value)"
    }
}
