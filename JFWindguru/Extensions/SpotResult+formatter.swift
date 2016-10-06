//
//  SpotResult+formatter.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/8/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation

extension SpotResult
{
    public var asSpotName: String {
        
        var currentLocation : String!
        
        currentLocation = self.spots?.last?.name
        
        return currentLocation
    }
}