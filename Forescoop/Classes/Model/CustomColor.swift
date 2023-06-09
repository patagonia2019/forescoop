//
//  Color.swift
//  Forescoop
//
//  Created by javierfuchs on 7/27/17.
//
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

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
    #if os(iOS)
    var color: UIColor {
        UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: CGFloat(alpha))
    }
    #elseif os(macOS)
    var color: NSColor {
        NSColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: CGFloat(alpha))
    }
    #else
    var color: UIColor {
        UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: CGFloat(alpha))
    }
    #endif
}
