//
//  ForecastWindguruService+AsyncAwait.swift
//  Forescoop
//
//  Created by fox on 01/06/2023.
//

import Foundation

public extension ForecastWindguruService {
    // searchSpots = api(query: routine.search_spots,
    //               errorCode: err.search_spots.rawValue,
    //              parameters: [parameter.search,
    //                           parameter.opt])
    func searchSpots(byLocation location: String) async throws -> SpotResult? {

        let escapedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let tokens = [Definition.service.api.parameter.search : escapedLocation]
        let api = Definition.service.api.searchSpots
        let url = Definition.service.url(api: api, tokens: tokens)
        
        let (data, _) = try await URLSession.shared.data(from: URL.init(string: url)!)
        
        if let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String : Any]
        {
            print("SUCCESS url = \(url) - response.result.value \(String(describing: json))")
            return SpotResult.init(map: json)
        }
        else {
            print("FAILURE url = \(url)")
            throw CustomError.invalidParsing
        }
    }

    // forecast = api(query: routine.forecast,
    //            errorCode: err.forecast.rawValue,
    //           parameters: [parameter.id_spot,
    //                        parameter.id_model,
    //                        parameter.no_wave])

    func forecast(bySpotId spotId: String,
                         model modelId: String? = nil) async throws -> SpotForecast? {
        let tokens = [Definition.service.api.parameter.id_model : modelId ?? Definition.defaultModel,
                      Definition.service.api.parameter.id_spot : spotId]
        let api = Definition.service.api.forecast
        let url = Definition.service.url(api: api, tokens: tokens)
        
        let (data, _) = try await URLSession.shared.data(from: URL.init(string: url)!)
        
        if let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String : Any]
        {
            print("SUCCESS url = \(url) - response.result.value \(String(describing: json))")
            return SpotForecast.init(map: json)
        }
        else {
            print("FAILURE url = \(url)")
            throw CustomError.invalidParsing
        }
    }
}
