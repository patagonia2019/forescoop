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

public class ForecastModel {
    public var model: String?
    public var info: Forecast?
    
    init(model: String, info: Forecast)
    {
        self.model = model
        self.info = info
    }
    
    var description : String {
        var aux : String = ""
        if let model = model {
            aux += "Model # \(model)\n"
        }
        if let info = info {
            aux += "\(info).\n"
        }
        return aux
    }
}
