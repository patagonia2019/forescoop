//
//  Color.swift
//  Pods
//
//  Created by javierfuchs on 7/27/17.
//
//

import Foundation

public struct Color {
        
    var alpha: Float = 0
    var red: Float = 0
    var green: Float = 0
    var blue: Float = 0
    
    public init?(a: Float = 0, r: Float = 0, g: Float = 0, b: Float = 0) {
        alpha = a
        red = r
        green = g
        blue = b
    }
    
    init(dictionary: [String: AnyObject?]) {
        // TODO
    }
    
    public var description : String {
        "\(type(of:self)): (\(alpha),\(red),\(green),\(blue))"
    }
    
}
