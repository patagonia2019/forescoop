//
//  SpotResult+formatter.swift
//  JFWindguru
//
//  Created by Javier Fuchs on 10/8/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
import JFWindguru

extension SpotResult
{
    public var asSpotName: String {
        
        var currentLocation : String!
        
        currentLocation = self.lastSpot()?.name()
        
        return currentLocation
    }
}
