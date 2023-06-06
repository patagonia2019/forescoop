//
//  WindDirection.swift
//  Pods
//
//  Created by fox on 06/06/2023.
//

import Foundation

public struct WindDirection {
    let value: Int
    
    var name: String? {
        let compass = ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW","N"]
        let module = Double(value % 360)
        let index = Int(module / 22.5) + 1 // degrees for each sector
        if index >= 0 && index < compass.count {
            return compass[index]
        }
        return nil
    }
    
    var description : String {
        name ?? "\(value)"
    }
}
