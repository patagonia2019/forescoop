//
//  Color.swift
//  Forescoop
//
//  Created by javierfuchs on 7/27/17.
//
//

import Foundation
import UIKit

public struct CustomColor {
    
    let info: String?
    let alpha: Float
    let red: Float
    let green: Float
    let blue: Float
    
    public var description : String {
        "\(type(of:self)): (\(info ?? "")\(alpha),\(red),\(green),\(blue))"
    }
}

public extension CustomColor {
    var color: UIColor {
        UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: CGFloat(alpha))
    }
}
