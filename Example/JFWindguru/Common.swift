//
//  Common.swift
//  JFWindguru
//
//  Created by javierfuchs on 7/9/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import Foundation

/*
 *  WDCommon
 *
 *  Discussion:
 *    Some common and global constants.
 */



let kWDForecastUpdated : String = "WDForecastUpdated"

let kWDWatchPlist: String = "WDWatch.plist"

let kWDGroup : String = "group.fuchs.windguru"

let kWDKeyLocality : String = "locality"

let kWDKeyCountry : String = "country"

let kWDMinimumDistanceFilterInMeters : Double = 60.0 // update every 200ft

let kWDSearchSpotsUrl = "https://www.windguru.cz/int/jsonapi.php?client=wgapp&q=search_spots&username=southfox&password=zorrito1&search="

let kWDSearchForecastUrl = "https://www.windguru.cz/int/jsonapi.php?client=wgapp&q=forecast&username=southfox&password=zorrito1&id_model=3&id_spot="

let kWDAnimationDuration: Double = 2.0
