//
//  AlertViewModel.swift
//  Forescoop_Example
//
//  Created by fox on 14/06/2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import Forescoop

struct AlertViewModel {
    
    private struct AlertTextField {
        var placeholder: String
        var text: String? = nil
    }
    
    var apiController: ApiController?
    
    var alertController: UIAlertController? {
        guard let service = apiController?.service else { return nil }
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        var textFields: [AlertTextField] = []
        var actionBlock: (()->())? = nil

        switch service {
            
        case UserBasedServices.set_spots.rawValue:
            textFields = [.init(placeholder: "set id")]
            actionBlock = { self.apiController?.addSetSpots(id: alert.textFields![0].text) }
            break
            
        case UserBasedServices.add_f_spot.rawValue:
            textFields = [.init(placeholder: "spot id")]
            actionBlock = { self.apiController?.addFavoriteSpot(id: alert.textFields![0].text) }
            
        case UserBasedServices.remove_f_spot.rawValue:
            textFields = [.init(placeholder: "spot id")]
            actionBlock = { self.apiController?.removeFavoriteSpot(id: alert.textFields![0].text) }
            
        case UserBasedServices.c_spots.rawValue:
            actionBlock = { self.apiController?.customSpots() }
            
        case UserBasedServices.f_spots.rawValue:
            actionBlock = { self.apiController?.favoriteSpots() }

        case UserBasedServices.sets.rawValue:
            actionBlock = { self.apiController?.setSpots() }

        case UserBasedServices.wforecast.rawValue:
            textFields = [.init(placeholder: "spot id", text: "64141"),
                          .init(placeholder: "model id", text: Model.defaultModel)]
            actionBlock = { self.apiController?.wforecast(spotId: alert.textFields![0].text,
                                                          modelId: alert.textFields![1].text) }

        case AnonymousBaseServices.forecast.rawValue:
            textFields = [.init(placeholder: "spot id", text: "64141"),
                          .init(placeholder: "model", text: Model.defaultModel)]
            actionBlock = { self.apiController?.forecastSpot(id: alert.textFields![0].text, model: alert.textFields![1].text) }

        case AnonymousBaseServices.spot.rawValue:
            textFields = [.init(placeholder: "spot id", text: "64141")]
            actionBlock = { self.apiController?.spotInfo(spotId: alert.textFields![0].text) }

        case AnonymousBaseServices.spots.rawValue:
            textFields = [.init(placeholder: "country id (optional)", text: "76"),
                          .init(placeholder: "region id (optional)", text: "209")]
            actionBlock = { self.apiController?.spots(countryId: alert.textFields![0].text,
                                                      regionId: alert.textFields![1].text) }
            
        case AnonymousBaseServices.search_spots.rawValue:
            textFields = [.init(placeholder: "Location", text: "Bariloche")]
            actionBlock = { self.apiController?.searchSpots(location: alert.textFields![0].text) }

        case AnonymousBaseServices.geo_regions.rawValue:
            actionBlock = { self.apiController?.geoRegions() }

            
        case AnonymousBaseServices.countries.rawValue:
            textFields = [.init(placeholder: "region id (optional)", text: "5")]
            actionBlock = { self.apiController?.countries(regionId: alert.textFields![0].text) }
            
        case AnonymousBaseServices.regions.rawValue:
            textFields = [.init(placeholder: "country id (optional)", text: "76")]
            actionBlock = { self.apiController?.regions(countryId: alert.textFields![0].text) }
            
        case AnonymousBaseServices.user.rawValue:
            apiController?.delegate?.showApiInfo(info: apiController?.userDescription ?? "")
            
        case AnonymousBaseServices.model_info.rawValue:
            textFields = [.init(placeholder: "model id (optional)", text: Model.defaultModel)]
            actionBlock = { self.apiController?.modelInfo(id: alert.textFields![0].text) }

        case AnonymousBaseServices.models_latlon.rawValue:
            textFields = [.init(placeholder: "latitude", text: "-41"),
                          .init(placeholder: "longitude", text: "-71")]
            actionBlock = { self.apiController?.models(lat: alert.textFields![0].text,
                                                       lon: alert.textFields![1].text) }
        default:
            fatalError()
        }
        
        guard textFields.isEmpty == false else {
            actionBlock?()
            return nil
        }

        alert.title = service
        alert.message = textFields
            .compactMap { $0.text != nil ? "\($0.placeholder) = \($0.text! )" : ""}
            .joined(separator: "\n")

        textFields.forEach { tf in
            alert.addTextField { (textfield) in
                textfield.placeholder = tf.placeholder
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = tf.text
            }
        }
        let action = UIAlertAction.init(title: "Go", style: .default) { _ in
            actionBlock?()
        }
        alert.addAction(action)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancel)
        return alert
    }


}
