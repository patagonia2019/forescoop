//
//  Model.swift
//  Pods
//
//  Created by javierfuchs on 7/13/17.
//
//

import Foundation
#if USE_EXT_FWK
    import ObjectMapper
    import RealmSwift
#endif

/*
 *  Model
 *
 *  Discussion:
 *    Model object representing the base class of Model.
 *
 * {
 *     "id_model": 3,
 *     "model_name": "GFS 27 km",
 *     "model": "gfs",
 *     "hr_start": 0,
 *     "hr_end": 240,
 *     "hr_step": 3,
 *     "period": 6,
 *     "resolution": 27,
 *     "update_time": "+4 hours +50 minutes",
 *     "show_vars": [
 *         "WINDSPD",
 *         "GUST",
 *         "MWINDSPD",
 *         "SMER",
 *         "TMP",
 *         "TMPE",
 *         "WCHILL",
 *         "FLHGT",
 *         "CDC",
 *         "TCDC",
 *         "APCPs",
 *         "SLP",
 *         "RH",
 *         "RATING"
 *     ]
 * }
 */

#if USE_EXT_FWK
    public class Model: ModelObject, Mappable {
        
        required convenience public init?(map: Map) {
            self.init()
        }
    
        public func mapping(map: Map) {
            id_model    <- map["id_model"]
            model_name  <- map["model_name"]
            model       <- map["model"]
            hr_start    <- map["hr_start"]
            hr_end      <- map["hr_end"]
            hr_step     <- map["hr_step"]
            period      <- map["period"]
            resolution  <- map["resolution"]
            update_time <- map["update_time"]
            show_vars   <- map["show_vars"]
        }
}

#else

    public class Model: ModelObject {

        init(dictionary: [String: AnyObject?]) {
            super.init()
            id_model = dictionary["id_model"] as? Int
            model_name = dictionary["model_name"] as? String ?? nil
            model = dictionary["model"] as? String ?? nil
            hr_start = Opt.init(dictionary["hr_start"] as? Int)
            hr_end = Opt.init(dictionary["hr_end"] as? Int)
            hr_step = Opt.init(dictionary["hr_step"] as? Int)
            period = Opt.init(dictionary["period"] as? Int)
            resolution = Opt.init(dictionary["resolution"] as? Int)
            update_time = dictionary["update_time"] as? String ?? nil
            show_vars = dictionary["show_vars"] as? [String] ?? nil
        }
    }

#endif

public class ModelObject: Object {
    public dynamic var id_model : Int = 0
    public dynamic var model_name: String? = nil
    public dynamic var model: String? = nil
    public dynamic var hr_start: Int = 0
    public var hr_end : Int = 0
    public var hr_step : Int = 0
    public var period : Int = 0
    public var resolution : Int = 0
    public dynamic var update_time: String?
    public var show_vars = List<StringObject>()

    override public var description : String {
        var aux : String = "\(type(of:self)): "
        aux += "Model # \(id_model), "
        if let model_name = model_name {
            aux += "name \(model_name), "
        }
        if let model = model {
            aux += "model \(model).\n"
        }
        aux += "hr_start \(hr_start), "
        aux += "hr_end \(hr_end), "
        aux += "period \(period), "
        aux += "resolution \(resolution).\n"
        if let update_time = update_time {
            aux += "update_time \(update_time)\n"
        }
        if show_vars.count > 0 {
            aux += "show_vars \(show_vars)\n"
        }
        return aux
    }
}
