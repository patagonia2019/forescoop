//
//  UserViewController.swift
//  Forescoop
//
//  Created by javierfuchs on 7/12/17.
//  Copyright © 2023 Mobile Patagonia. All rights reserved.
//

import Foundation
import Forescoop

class ApiListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var apiController: ApiController? = nil
    var info: String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ApiInfoViewController {
            if let service = apiController?.service {
                vc.title = service
                vc.info = info ?? "n/a"
            }
        }
    }
}

extension ApiListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        apiController?.currentServiceOrdinal = indexPath.item
        var action : UIAlertAction? = nil
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        switch apiController?.service {
            
        case UserBasedServices.set_spots.rawValue:
            action = change(alert: alert,
                            alertConfig: .init(textFields: [.init(placeholder: "set id")],
                                               title: "Add Set",
                                               actionBlock: { self.apiController?.addSetSpots(id: alert.textFields![0].text) }))
            
        case UserBasedServices.add_f_spot.rawValue:
            action = change(alert: alert,
                            alertConfig: .init(textFields: [.init(placeholder: "spot id")],
                                               title: "Add Favorite",
                                               actionBlock: { self.apiController?.addFavoriteSpot(id: alert.textFields![0].text) }))
            
        case UserBasedServices.remove_f_spot.rawValue:
            action = change(alert: alert,
                            alertConfig: .init(textFields: [.init(placeholder: "spot id")],
                                               title: "Remove Favorite",
                                               actionBlock: { self.apiController?.removeFavoriteSpot(id: alert.textFields![0].text) }))
            
        case UserBasedServices.c_spots.rawValue:
            apiController?.customSpots()

        case UserBasedServices.f_spots.rawValue:
            apiController?.favoriteSpots()

        case UserBasedServices.sets.rawValue:
            apiController?.setSpots()

        case UserBasedServices.wforecast.rawValue:
            action = change(alert: alert,
                            alertConfig: .init(textFields: [.init(placeholder: "spot id #", text: "64141"),
                                                            .init(placeholder: "model id #", text: Model.defaultModel)],
                                               title: "Enter spot id",
                                               actionBlock: { self.apiController?.wforecast(spotId: alert.textFields![0].text,
                                                                                            modelId: alert.textFields![1].text) }))

        case AnonymousBaseServices.forecast.rawValue:
            action = change(alert: alert,
                            alertConfig: .init(textFields: [.init(placeholder: "spot id", text: "64141"),
                                                            .init(placeholder: "model", text: Model.defaultModel)],
                                               title: "Forecast",
                                               actionBlock: { self.apiController?.forecastSpot(id: alert.textFields![0].text, model: alert.textFields![1].text) }))

        case AnonymousBaseServices.spot.rawValue:
            action = change(alert: alert,
                            alertConfig: .init(textFields: [.init(placeholder: "spot id", text: "64141")],
                                               title: "Enter spot id",
                                               actionBlock: { self.apiController?.spotInfo(spotId: alert.textFields![0].text) }))

        case AnonymousBaseServices.spots.rawValue:
            action = change(alert: alert,
                            alertConfig: .init(textFields: [.init(placeholder: "country id# (optional)", text: "76"),
                                                            .init(placeholder: "region id# (optional)", text: "209")],
                                               title: "Enter country/region",
                                               actionBlock: { self.apiController?.spots(countryId: alert.textFields![0].text,
                                                                                        regionId: alert.textFields![1].text) }))
            
        case AnonymousBaseServices.search_spots.rawValue:
            action = change(alert: alert,
                            alertConfig: .init(textFields: [.init(placeholder: "Location", text: "Bariloche")],
                                               title: "Enter location",
                                               actionBlock: { self.apiController?.searchSpots(location: alert.textFields![0].text) }))

        case AnonymousBaseServices.geo_regions.rawValue:
            apiController?.geoRegions()
            
        case AnonymousBaseServices.countries.rawValue:
            action = change(alert: alert,
                            alertConfig: .init(textFields: [.init(placeholder: "region id (optional)", text: "5")],
                                               title: "Enter region id",
                                               actionBlock: { self.apiController?.countries(regionId: alert.textFields![0].text) }))
            
        case AnonymousBaseServices.regions.rawValue:
            action = change(alert: alert,
                            alertConfig: .init(textFields: [.init(placeholder: "country id (optional)", text: "76")],
                                               title: "Enter country id",
                                               actionBlock: { self.apiController?.regions(countryId: alert.textFields![0].text) }))
            
        case AnonymousBaseServices.user.rawValue:
            info = apiController?.userDescription
            performSegue(withIdentifier: "ApiInfoViewController", sender: self)
            break
            
        case AnonymousBaseServices.model_info.rawValue:
            action = change(alert: alert,
                            alertConfig: .init(textFields: [.init(placeholder: "model id # (optional)", text: Model.defaultModel)],
                                               title: "Enter model id",
                                               actionBlock: { self.apiController?.modelInfo(id: alert.textFields![0].text) }))

        case AnonymousBaseServices.models_latlon.rawValue:
            action = change(alert: alert,
                            alertConfig: .init(textFields: [.init(placeholder: "latitude", text: "-41"),
                                                            .init(placeholder: "longitude", text: "-71")],
                                               title: "Enter latitude/longitude",
                                               actionBlock: { self.apiController?.models(lat: alert.textFields![0].text,
                                                                                         lon: alert.textFields![1].text) }))


        default:
            break
        }
        
        if let action = action {
            alert.addAction(action)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }

    }
}

extension ApiListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        apiController?.numberOfServices ?? 0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
        cell.textLabel?.text = apiController?.services[indexPath.item]
        return cell
    }
}

extension ApiListViewController: ApiControllerDelegate {
    func showApiInfo(info: String) {
        self.info = info
        performSegue(withIdentifier: "ApiInfoViewController", sender: self)
    }
    
    func showError(service: String?, error: Error?) {
        let title = "Error on \(service ?? "n/a")"
        let message = (error as? CustomError)?.description ?? error?.localizedDescription ?? "n/a"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}

private extension ApiListViewController {
    struct AlertTextField {
        var placeholder: String
        var text: String? = nil
    }
    struct AlertConfig {
        var textFields: [AlertTextField]
        var title: String
        var actionBlock: ()->()
    }
    
    private func change(alert: UIAlertController, alertConfig: AlertConfig) -> UIAlertAction? {
        alertConfig.textFields.forEach { tf in
            alert.addTextField { (textfield) in
                textfield.placeholder = tf.placeholder
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = tf.text
            }
        }
        let action = UIAlertAction.init(title: "Go", style: .default) { _ in
            alertConfig.actionBlock()
        }
        alert.title = apiController?.service
        alert.message = alertConfig.textFields
            .compactMap { $0.text != nil ? "\($0.placeholder) = \($0.text! )" : ""}
            .joined(separator: "\n")
        return action
    }
}
