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

    let anonymBasedServices = ["user",
                               "geo_regions",
                               "countries",
                               "regions",
                               "spot",
                               "spots",
                               "search_spots",
                               "model_info",
                               "models_latlon",
                               "forecast"]
    
    let userBasedServices = ["add_f_spot",
                             "remove_f_spot",
                             "f_spots",
                             "c_spots",
                             "set_spots",
                             "sets",
                             "wforecast"
                             // "wforecast_latlon"
                            ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiController?.delegate = self
    }
    
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

    lazy var services: [String] = {
        apiController?.isUserAnonymous == false ? anonymBasedServices + userBasedServices : anonymBasedServices
    }()
    
}

extension ApiListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        apiController?.service = services[indexPath.item]
        var action : UIAlertAction? = nil
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        switch apiController?.service {
            
        case "set_spots":
            alert.addTextField { (textfield) in
                textfield.placeholder = "set id"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
            }
            action = UIAlertAction.init(title: "Add", style: .default) { [weak self] _ in
                self?.apiController?.addSetSpots(id: alert.textFields![0].text)
            }
            alert.title = "Add Set id"
            alert.message = "Please enter a set id (i.e. 229823)"
            break
            
        case "add_f_spot":
            alert.addTextField { (textfield) in
                textfield.placeholder = "spot id"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
            }
            let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in
                self?.apiController?.addFavoriteSpot(id: alert.textFields![0].text)
            }
            action = UIAlertAction.init(title: "Add", style: .default, handler: block)
            alert.title = "Add Favorite"
            alert.message = "Please enter a spot id (i.e. 64141)"
            break

        case "remove_f_spot":
            alert.addTextField { (textfield) in
                textfield.placeholder = "spot id"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "64141"
            }
            let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in
                self?.apiController?.removeFavoriteSpot(id: alert.textFields![0].text)
            }
            
            action = UIAlertAction.init(title: "Remove", style: .default, handler: block)
            alert.title = "Remove Favorite"
            alert.message = "Please enter a spot id (i.e. 64141)"
            break

        case "forecast":
            alert.addTextField { (textfield) in
                textfield.placeholder = "spot id"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "64141"
            }
            
            alert.addTextField { (textfield) in
                textfield.placeholder = "model"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "3"
            }

            let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in
                self?.apiController?.forecastSpot(id: alert.textFields![0].text, model: alert.textFields![1].text)
            }
            action = UIAlertAction.init(title: "Forecast", style: .default, handler: block)
            alert.title = "Enter spot id"
            alert.message = "Please enter a spot id (i.e. 64141), model id (i.e 3)"
            break

        case "spot":
            alert.addTextField { (textfield) in
                textfield.placeholder = "spot id"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "64141"
            }
            
            let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in
                self?.apiController?.spotInfo(spotId: alert.textFields![0].text)
            }
            action = UIAlertAction.init(title: "Get Spot Info", style: .default, handler: block)
            alert.title = "Enter spot id"
            alert.message = "Please enter a spot id (i.e. 64141)"
            break

        case "spots":
            alert.addTextField { (textfield) in
                textfield.placeholder = "country id# (optional)"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "76"
            }
            
            alert.addTextField { (textfield) in
                textfield.placeholder = "region id# (optional)"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "209"
            }
            
            let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in
                self?.apiController?.spots(countryId: alert.textFields![0].text,
                                           regionId: alert.textFields![1].text)
            }
            action = UIAlertAction.init(title: "Get Spots", style: .default, handler: block)
            alert.title = "Enter country/region"
            alert.message = "Please enter info to search (i.e. country = 76, region = 209)"
            break
            
        case "search_spots":
            alert.addTextField { (textfield) in
                textfield.placeholder = "Location"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "Bariloche"
            }

            let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in
                self?.apiController?.searchSpots(location: alert.textFields![0].text)
            }
            action = UIAlertAction.init(title: "Search Spots", style: .default, handler: block)
            alert.title = "Enter location"
            alert.message = "Please enter a spot to search (i.e. Bariloche)"
            break

            
        case "c_spots":
            apiController?.customSpots()
            break

        case "f_spots":
            apiController?.favoriteSpots()
            break

        case "sets":
            apiController?.setSpots()
            break

        case "model_info":
            
            alert.addTextField { (textfield) in
                textfield.placeholder = "model id # (optional)"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "3"
            }
            
            let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in
                self?.apiController?.modelInfo(id: alert.textFields![0].text)
            }
            action = UIAlertAction.init(title: "get model/s", style: .default, handler: block)
            alert.title = "Enter model id"
            alert.message = "Please enter a model id (i.e. 3)"
            break


        case "models_latlon":
            alert.addTextField { (textfield) in
                textfield.placeholder = "latitude"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "-41"
            }
            alert.addTextField { (textfield) in
                textfield.placeholder = "longitude"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "-71"
            }
            
            let block: ((UIAlertAction) -> Void)? = { [weak self] (action) in
                self?.apiController?.models(lat: alert.textFields![0].text, lon: alert.textFields![1].text)
            }
            action = UIAlertAction.init(title: "query lat/lon", style: .default, handler: block)
            alert.title = "Enter latitude/longitude"
            alert.message = "Please enter (i.e. -41 / -71)"
            break

        case "wforecast":
            alert.addTextField { (textfield) in
                textfield.placeholder = "spot id #"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "64141"
            }
            alert.addTextField { (textfield) in
                textfield.placeholder = "model id #"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "3"
            }
            let block: ((UIAlertAction) -> Void)? = { [weak self] (action) in
                self?.apiController?.wforecast(spotId: alert.textFields![0].text,
                                               modelId: alert.textFields![1].text)
            }
            action = UIAlertAction.init(title: "Forecast", style: .default, handler: block)
            alert.title = "Enter spot id"
            alert.message = "Please enter a spot id (i.e. 64141) and model id (i.e. 3)"
            break

        case "geo_regions":
            apiController?.geoRegions()
            break
            
        case "countries":
            alert.addTextField { (textfield) in
                textfield.placeholder = "region id (optional)"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "5"
            }
            let block : ((UIAlertAction) -> Void)? = { [weak self] _ in
                self?.apiController?.countries(regionId: alert.textFields![0].text)
            }
            action = UIAlertAction.init(title: "get country/s", style: .default, handler: block)
            alert.title = "Enter region id"
            alert.message = "Please enter a region id (i.e. 5)"
            break
            
        case "regions":
            alert.addTextField { (textfield) in
                textfield.placeholder = "country id (optional)"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "76"
            }

            let block : ((UIAlertAction) -> Void)? = { [weak self] _ in
                self?.apiController?.regions(countryId: alert.textFields![0].text)
            }
            action = UIAlertAction.init(title: "get region/s", style: .default, handler: block)
            alert.title = "Enter country id"
            alert.message = "Please enter a country id (i.e. 76)"
            break
            
        case "user":
            info = apiController?.userDescription
            performSegue(withIdentifier: "ApiInfoViewController", sender: self)
            break
            
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
        services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
        cell.textLabel?.text = services[indexPath.item]
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
