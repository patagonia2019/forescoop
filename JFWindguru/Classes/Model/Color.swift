//
//  Color.swift
//  Pods
//
//  Created by javierfuchs on 7/27/17.
//
//

import Foundation

public class Color: Object {
        
    var alpha: Float = 0
    var red: Float = 0
    var green: Float = 0
    var blue: Float = 0
    
    required public init?(a: Float = 0, r: Float = 0, g: Float = 0, b: Float = 0) {
        super.init()
        alpha = a
        red = r
        green = g
        blue = b
    }
    
    init(dictionary: [String: AnyObject?]) {
        // TODO
    }
    
    public override var description : String {
        var aux : String = "\(type(of:self)): "
        aux += "(\(alpha),\(red),\(green),\(blue))"
        return aux
    }
    
}
