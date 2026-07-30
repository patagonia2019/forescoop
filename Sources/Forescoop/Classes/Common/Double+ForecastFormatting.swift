//
//  Double+ForecastFormatting.swift
//  Forescoop package
//
//  Created by Javier on 07/30/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import Foundation

extension Double {
    func forecastFormatted(precision: Int = 1) -> String {
        formatted(.number.precision(.fractionLength(precision)))
    }
}
