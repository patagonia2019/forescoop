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
    var user: User?
    var password: String?
    var service: String?
    var info: String?
    var forecastService: ForecastWindguruProtocol? = nil// = ForecastWindguruService()

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ApiInfoViewController {
            if let service = service {
                vc.title = service
                vc.info = info ?? "n/a"
            }
        }
    }

    lazy var services : [String] = {
        user?.isAnonymous == true ? anonymBasedServices : anonymBasedServices + userBasedServices
    }()
    
    func showAlert(title: String, error: WGError?) {
        let message = error?.title() ?? ""
        showAlert(title: title, message: message)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }

}

extension ApiListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        service = services[indexPath.item]
        
        guard let service = service else { return }

        var action : UIAlertAction? = nil
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        switch service {
            
        case "set_spots":
            alert.addTextField { (textfield) in
                textfield.placeholder = "set id"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
            }

            let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in
                guard let self = self else { return }
                
                guard let text = alert.textFields![0].text,
                      let user = self.user,
                      let password = self.password
                else {
                    self.showAlert(title: "\(service)", message: "Missing mandatory field: [Set Id]")
                    return
                }
                Task {
                    do {
                        self.info = try await self.forecastService?.addSetSpots(withSetId: text, username: user.name, password: password)?.description
                        self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                    } catch {
                        self.showAlert(title: "Error on \(service)", message: "Cannot add set id")
                    }
                }
            }
            action = UIAlertAction.init(title: "Add", style: .default, handler: block)
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
                guard let self = self else { return }
                
                guard let text = alert.textFields![0].text,
                    text.count > 0
                else {
                    self.showAlert(title: "\(service)", message: "Missing mandatory field: [Spot Id]")
                    return
                }
                Task {
                    do {
                        self.info = try await self.forecastService?.addFavoriteSpot(withSpotId: text, username: self.user?.name, password: self.password)?.description
                        self.showAlert(title: "\(service) success", message: self.info ?? "n/a")
                    } catch {
                        self.showAlert(title: "Error on \(service)", message: "Cannot add spot id")
                    }
                }
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
                guard let self = self else { return }

                guard let text = alert.textFields![0].text,
                    text.count > 0
                else {
                    self.showAlert(title: "\(service)", message: "Missing mandatory field: [Spot Id]")
                    return
                }
                Task {
                    do {
                        self.info = try await self.forecastService?.removeFavoriteSpot(withSpotId: text, username: self.user?.name, password: self.password)?.description
                        self.showAlert(title: "\(service) success", message: self.info ?? "n/a")
                    } catch {
                        self.showAlert(title: "Error on \(service)", message: "Cannot remove spot id")
                    }
                }
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
                guard let self = self else { return }

                guard let spotId = alert.textFields![0].text,
                    spotId.count > 0
                else {
                    self.showAlert(title: "\(service)", message: "Missing mandatory field: [Spot Id]")
                    return
                }
                
                var modelId = alert.textFields![1].text
                if modelId?.count == 0 {
                    modelId = nil
                }

                Task {
                    do {
                        self.info = try await self.forecastService?.forecast(bySpotId: spotId,
                                                                             model: modelId)?.description
                        self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                    } catch {
                        self.showAlert(title: "Error on \(service)", message: "No forecast result")
                    }
                }
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
                guard let self = self else { return }
                
                guard let spotId = alert.textFields![0].text,
                    spotId.count > 0
                else {
                    self.showAlert(title: "\(service)", message: "Missing mandatory field: [Spot Id]")
                    return
                }
                Task {
                    do {
                        self.info = try await self.forecastService?.spotInfo(bySpotId: spotId)?.description
                        self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                    } catch {
                        self.showAlert(title: "Error on \(service)", message: "No spot info")
                    }
                }
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
                guard let self = self else { return }
                Task {
                    do {
                        self.info = try await self.forecastService?.spots(withCountryId: alert.textFields![0].text,
                                                                          regionId: alert.textFields![1].text)?.description
                        self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                    } catch {
                        self.showAlert(title: "Error on \(service)", message: "No spots")
                    }
                }
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
                guard let self = self else { return }

                guard let location = alert.textFields![0].text,
                    location.count > 0
                else {
                    self.showAlert(title: "\(service)", message: "Missing mandatory field: [Location]")
                    return
                }
                Task {
                    do {
                        self.info = try await self.forecastService?.searchSpots(byLocation: location)?.description
                        self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                    } catch {
                        self.showAlert(title: "Error on \(service)", message: "No spots")
                    }
                }
            }
            action = UIAlertAction.init(title: "Search Spots", style: .default, handler: block)
            alert.title = "Enter location"
            alert.message = "Please enter a spot to search (i.e. Bariloche)"
            break

            
        case "c_spots":
            Task {
                do {
                    self.info = try await self.forecastService?.customSpots(withUsername: user?.name, password: password)?.description
                    self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                } catch {
                    self.showAlert(title: "Error on \(service)", message: "No custom spots")
                }
            }
            break

        case "f_spots":
            Task {
                do {
                    self.info = try await self.forecastService?.favoriteSpots(withUsername: user?.name, password: password)?.description
                    self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                } catch {
                    self.showAlert(title: "Error on \(service)", message: "No favorites spots")
                }
            }
            break

        case "sets":
            Task {
                do {
                    self.info = try await self.forecastService?.setSpots(withUsername: user?.name, password: password)?.description
                    self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                } catch {
                    self.showAlert(title: "Error on \(service)", message: "No sets")
                }
            }
            break

        case "model_info":
            
            alert.addTextField { (textfield) in
                textfield.placeholder = "model id # (optional)"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "3"
            }
            
            let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in
                guard let self = self else { return }
                var modelId = alert.textFields![0].text
                if modelId?.count == 0 {
                    modelId = nil
                }

                Task {
                    do {
                        self.info = try await self.forecastService?.modelInfo(onlyModelId: modelId)?.description
                        self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                    } catch {
                        self.showAlert(title: "Error on \(service)", message: "No model/s")
                    }
                }
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
            
            let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in

                guard let self = self else { return }
                guard let latText = alert.textFields![0].text,
                    let lonText = alert.textFields![0].text,
                    latText.count > 0,
                    lonText.count > 0
                else {
                    self.showAlert(title: "\(service)", message: "Missing mandatory field: [lat] / [lon]")
                    return
                }

                Task {
                    do {
                        self.info = try await self.forecastService?.models(bylat: latText, lon: lonText)
                        self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                    } catch {
                        self.showAlert(title: "Error on \(service)", message: "No model/s")
                    }
                }
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
            let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in
                guard let self = self else { return }
                guard let spotId = alert.textFields![0].text,
                    spotId.count > 0
                else {
                    self.showAlert(title: "\(service)", message: "Missing mandatory field: [spot id]")
                    return
                }
                var modelId = alert.textFields![1].text
                if modelId?.isEmpty == true {
                    modelId = nil
                }
                
                Task {
                    do {
                        self.info = try await self.forecastService?.wforecast(bySpotId: spotId,
                                                                              model: modelId,
                                                                              username: self.user?.name,
                                                                              password: self.password)?.description
                        self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                    } catch {
                        self.showAlert(title: "Error on \(service)", message: "No forecast results")
                    }
                }
            }

            action = UIAlertAction.init(title: "Forecast", style: .default, handler: block)
            alert.title = "Enter spot id"
            alert.message = "Please enter a spot id (i.e. 64141) and model id (i.e. 3)"
            break

        case "geo_regions":
            Task {
                do {
                    self.info = try await self.forecastService?.geoRegions()?.description
                    self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                } catch {
                    self.showAlert(title: "Error on \(service)", message: "No georegions results")
                }
            }
            break
            
        case "countries":
            alert.addTextField { (textfield) in
                textfield.placeholder = "region id (optional)"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
                textfield.text = "5"
            }
            let block : ((UIAlertAction) -> Void)? = { (action) in
                Task {
                    do {
                        self.info = try await self.forecastService?.countries(byRegionId: alert.textFields![0].text)?.description
                        self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                    } catch {
                        self.showAlert(title: "Error on \(service)", message: "No countries results")
                    }
                }
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

            let block : ((UIAlertAction) -> Void)? = { (action) in
                Task {
                    do {
                        self.info = try await self.forecastService?.regions(byCountryId: alert.textFields![0].text)?.description
                        self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                    } catch {
                        self.showAlert(title: "Error on \(service)", message: "No regions results")
                    }
                }
            }
            action = UIAlertAction.init(title: "get region/s", style: .default, handler: block)
            alert.title = "Enter country id"
            alert.message = "Please enter a country id (i.e. 76)"
            break

            
        case "user":
            if let user = user {
                info = user.description
                performSegue(withIdentifier: "ApiInfoViewController", sender: self)
            }
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
        cell.textLabel?.text = services[indexPath.item]
        return cell
    }
    

}


