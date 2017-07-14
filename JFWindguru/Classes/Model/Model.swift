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
 *  "42": {
 *      "id_model": 42,
 *      "model_name": "WRF 3 km",
 *      "model": "wrfcas",
 *      "hr_start": 0,
 *      "hr_end": 48,
 *      "hr_step": 1,
 *      "period": 6,
 *      "resolution": 3,
 *      "update_time": "+7 hours +35 minutes",
 *      "show_vars": [
 *          "WINDSPD",
 *          "GUST",
 *          "MWINDSPD",
 *          "SMER",
 *          "TMP",
 *          "TMPE",
 *          "WCHILL",
 *          "FLHGT",
 *          "CDC",
 *          "TCDC",
 *          "APCP1s",
 *          "RH",
 *          "SLP",
 *          "RATING"
 *      ]
 *   }
 * }
 */

public class Model: Mappable {
    public var models = [ModelDetail]()

    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        for json in map.JSON {
            if  let jsonValue = json.value as? [String: Any],
                let model = Mapper<ModelDetail>().map(JSON: jsonValue) {
                models.append(model)
            }
        }
   }
    
    public var description : String {
        var aux : String = ""
        for model in models {
            aux += model.description + "\n"
        }
        return aux
    }
    
    
}
