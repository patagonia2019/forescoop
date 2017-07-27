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

#if USE_EXT_FWK
    public class ForecastModel: ForecastModelObject, Mappable {


        required convenience public init?(map: Map) {
            self.init()
        }

        public func mapping(map: Map) {
        }

    }

#else

    public class ForecastModel: ForecastModelObject {
        init(dictionary: [String: AnyObject?]) {
            // TODO
       }
    }
#endif

public class ForecastModelObject : Object {
    public var model: String?
    public var info: Forecast?
    
    convenience public init(model: String, info: Forecast)
    {
        self.init()
        self.model = model
        self.info = info
    }
    
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
