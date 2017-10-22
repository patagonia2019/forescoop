//
//  ForecastModel.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
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

    convenience public init(modelValue: String, infoForecast: Forecast)
    {
        self.init()
        model = modelValue
        info = infoForecast
    }

    required public convenience init(map: [String:Any]) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]) {
        model = map["model"] as? String
        if let forecastMap = map["info"] as? [String:Any] {
            info = Forecast.init(map: forecastMap)
        }
    }

    public var description : String {
        var aux : String = "\(type(of:self)): "
        if let model = model {
            aux += "Model # \(model)\n"
        }
        if let info = info {
            aux += "\(info.description).\n"
        }
        return aux
    }
}
