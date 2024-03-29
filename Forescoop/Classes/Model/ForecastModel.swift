//
//  ForecastModel.swift
//  Forescoop
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2023 Fuchs. All rights reserved.
//

import Foundation

/*
 *  ForecastModel
 *
 *  Discussion:
 *    Represents a model information of the weather data inside the model id 
 *    At this moment public models are all "3"
 *    The information contained is of type Forecast (only one object)
 *
 *        "3": { }
 *
 */

public class ForecastModel: Object, Mappable {

    var model: String?
    var info: Forecast?

    convenience public init(modelValue: String, infoForecast: Forecast) {
        self.init()
        model = modelValue
        info = infoForecast
    }

    required public convenience init?(map: [String: Any]?) throws {
        self.init()
        try mapping(map: map)
    }
    
    public override func mapping(map: [String: Any]?) throws {
        try super.mapping(map: map)
        
        model = map?["model"] as? String
        info = try Forecast.init(map: map?["info"] as? [String: Any])
        info?.gmtHourOffset = map?["gmt_hour_offset"] as? Int ?? 0
    }
    
    public var description: String {
        [
            "\(type(of:self))",
            model?.description,
            info?.description
        ]
            .compactMap{$0}
            .joined(separator: "\n")
    }
}

public extension ForecastModel {
    var modelIdentifier: String? {
        model
    }

    var forecast: Forecast? {
        info
    }
}
