//
//  Model.swift
//  Pods
//
//  Created by javierfuchs on 7/13/17.
//
//

import Foundation

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

public class Model: Object, Mappable {
    var id_model : Int = 0
    var model_name: String? = nil
    var model: String? = nil
    var hr_start: Int = 0
    var hr_end : Int = 0
    var hr_step : Int = 0
    var period : Int = 0
    var resolution : Int = 0
    var update_time: String?
    var show_vars = [String]()

    
    required public convenience init?(map: [String: Any]?) {
        self.init()
        mapping(map: map)
    }
    
    public func mapping(map: [String:Any]?) {
        guard let map = map else { return }

        id_model = map["id_model"] as? Int ?? 0
        model_name = map["model_name"] as? String ?? nil
        model = map["model"] as? String ?? nil
        hr_start = map["hr_start"] as? Int ?? 0
        hr_end = map["hr_end"] as? Int ?? 0
        hr_step = map["hr_step"] as? Int ?? 0
        period = map["period"] as? Int ?? 0
        resolution = map["resolution"] as? Int ?? 0
        update_time = map["update_time"] as? String ?? nil
        show_vars = map["show_vars"] as? [String] ?? []
    }

    public var description : String {
        [
            "\(type(of:self)): ",
            "Model # \(id_model) ",
            model_name,
            model,
            "\(hr_start) : \(hr_end) : \(hr_step) : \(period) : \(resolution)",
            update_time,
            show_vars.compactMap{$0}.joined(separator: ", ")
        ]
            .compactMap{$0}
            .joined(separator: "\n")
    }
}
