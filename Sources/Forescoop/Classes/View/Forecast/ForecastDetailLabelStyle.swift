//
//  ForecastDetailLabelStyle.swift
//  Forescoop package
//
//  Created by Javier Fuchs on 07/31/26.
//  Copyright © 2026 Mobile Patagonia. All rights reserved.
//

import SwiftUI

/// Gives every forecast detail icon a consistent leading column.
struct ForecastDetailLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.icon
                .frame(width: 24, alignment: .center)
            configuration.title
        }
    }
}
