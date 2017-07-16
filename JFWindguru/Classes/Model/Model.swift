//
//  Model.swift
//  Pods
//
//  Created by javierfuchs on 7/13/17.
//
//

import Foundation
import ObjectMapper

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

public class Model: Mappable {
    public var id_model: Int?
    public var model_name: String?
    public var model: String?
    public var hr_start: Int?
    public var hr_end: Int?
    public var hr_step: Int?
    public var period: Int?
    public var resolution: Int?
    public var update_time: String?
    public var show_vars: [String]?
    
    required public init?(map: Map) {
        
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
    
    public var description : String {
        var aux : String = ""
        if let id_model = id_model {
            aux += "Model # \(id_model), "
        }
        if let model_name = model_name {
            aux += "name \(model_name), "
        }
        if let model = model {
            aux += "model \(model).\n"
        }
        if let hr_start = hr_start {
            aux += "hr_start \(hr_start), "
        }
        if let hr_end = hr_end {
            aux += "hr_end \(hr_end), "
        }
        if let period = period {
            aux += "period \(period), "
        }
        if let resolution = resolution {
            aux += "resolution \(resolution).\n"
        }
        if let update_time = update_time {
            aux += "update_time \(update_time)\n"
        }
        if let show_vars = show_vars {
            aux += "show_vars \(show_vars)\n"
        }
        return aux
    }
    
    
}
