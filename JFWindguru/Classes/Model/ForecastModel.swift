//
//  ForecastModel.swift
//  Xoshem-watch
//
//  Created by Javier Fuchs on 10/7/15.
//  Copyright © 2015 Fuchs. All rights reserved.
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
#endif

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

#if USE_EXT_FWK

    required convenience public init?(map: Map) {
        self.init()
    }

    public func mapping(map: Map) {
    }

    convenience public init(modelValue: String, infoForecast: Forecast)
    {
        self.init()
        model = modelValue
        info = infoForecast
    }

#else
    public required init(dictionary: [String: Any?]) {
        for (k,v) in dictionary {
            model = k
            if let dict = v as? [String:Any?] {
                info = Forecast.init(dictionary: dict)
            }
        }
    }
#endif

    override public var description : String {
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
