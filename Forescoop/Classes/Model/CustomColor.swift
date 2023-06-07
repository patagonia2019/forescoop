//
//  Color.swift
//  Forescoop
//
//  Created by javierfuchs on 7/27/17.
//
//

import Foundation

public struct CustomColor {
    
    var info: String?
    var alpha: Float
    var red: Float
    var green: Float
    var blue: Float
    
    public var description : String {
        "\(type(of:self)): (\(info ?? "")\(alpha),\(red),\(green),\(blue))"
    }
}
