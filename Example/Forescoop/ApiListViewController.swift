//
//  UserViewController.swift
//  Forescoop
//
//  Created by javierfuchs on 7/12/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import Foundation
import Forescoop

class ApiListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var user: User?
    var password: String?
    var service: String?
    var info = String()

    let anonymBasedServices = ["user",
                               "geo_regions",
                               "countries",
                               "regions",
                               "spot",
                               "spots",
                               "search_spots",
                               "model_info",
                               "models_latlon",
                               "forecast",
                               "wforecast"]
    
    let userBasedServices = ["add_f_spot",
                             "remove_f_spot",
                             "f_spots",
                             "c_spots",
                             "set_spots",
                             "sets",
                             // "wforecast_latlon"
                            ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ApiInfoViewController {
            if let service = service {
                vc.title = service
                vc.info = info
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
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { [weak self] (action) in
            self?.tableView.isHidden = false
        }))
        self.present(alert, animated: true, completion: nil)
    }

}

extension ApiListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        service = services[indexPath.item]
        
        guard let service = service else { return }

        tableView.isHidden = true

        let failureBlock : ForecastWindguruService.FailureType = {
            [weak self] (error) in
            self?.showAlert(title: "Error", error: error)
        }

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
                ForecastWindguruService.instance.addSetSpots(withSetId: text, username: user.name, password: password,
                                                             failure: failureBlock,
                                                             success: { [weak self]
                    (spots) in
                    guard let self = self else { return }
                    self.tableView.isHidden = false
                    guard let spots = spots else {
                        self.showAlert(title: "Error on \(service)", message: "Cannot add set id")
                        return
                    }
                    self.info = spots.description
                    self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                })
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
                ForecastWindguruService.instance.addFavoriteSpot(withSpotId: text, username: self.user?.name, password: self.password,
                                                             failure: failureBlock,
                                                             success: { [weak self] (result) in
                    guard let self = self else { return }
                    self.tableView.isHidden = false
                    guard let result = result else {
                        self.showAlert(title: "Error on \(service)", message: "Cannot add spot id")
                        return
                    }
                    self.showAlert(title: "\(service) success", message: result.description)
                })
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
            }
            let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in
                guard let self = self else { return }

                guard let text = alert.textFields![0].text,
                    text.count > 0
                else {
                    self.showAlert(title: "\(service)", message: "Missing mandatory field: [Spot Id]")
                    return
                }
                ForecastWindguruService.instance.removeFavoriteSpot(withSpotId: text, username: self.user?.name, password: self.password,
                                                                    failure: failureBlock,
                                                                    success: { [weak self] (result) in
                    guard let self = self else { return }
                    self.tableView.isHidden = false
                    guard let result = result else {
                        self.showAlert(title: "Error on \(service)", message: "Cannot remove spot id")
                        return
                    }
                    self.showAlert(title: "\(service) success", message: result.description)
                })
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
            }
            
            alert.addTextField { (textfield) in
                textfield.placeholder = "model"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
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

                ForecastWindguruService.instance.forecast(bySpotId: spotId,
                                                          model: modelId,
                                                          failure: failureBlock,
                                                          success: { [weak self] (spotForecast) in
                    guard let self = self else { return }
                    self.tableView.isHidden = false
                    guard let spotForecast = spotForecast else {
                        self.showAlert(title: "Error on \(service)", message: "No forecast result")
                        return
                    }
                    self.info = spotForecast.description
                    self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                })
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
            }
            
            let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in
                guard let self = self else { return }
                
                guard let spotId = alert.textFields![0].text,
                    spotId.count > 0
                else {
                    self.showAlert(title: "\(service)", message: "Missing mandatory field: [Spot Id]")
                    return
                }
                ForecastWindguruService.instance.spotInfo(bySpotId: spotId,
                                                          failure: failureBlock,
                                                          success: { [weak self] (spotInfo) in
                    guard let self = self else { return }
                    self.tableView.isHidden = false
                    guard let spotInfo = spotInfo else {
                        self.showAlert(title: "Error on \(service)", message: "No spot info")
                        return
                    }
                    self.info = spotInfo.description
                    self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                })
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
            }
            
            alert.addTextField { (textfield) in
                textfield.placeholder = "region id# (optional)"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
            }
            
            let block : ((UIAlertAction) -> Void)? = { (action) in
                
                ForecastWindguruService.instance.spots(withCountryId: alert.textFields![0].text,
                                                       regionId: alert.textFields![1].text,
                                                       failure: failureBlock,
                                                       success: { [weak self]
                    (spotResult) in
                    guard let self = self else { return }
                    self.tableView.isHidden = false
                    guard let spotResult = spotResult else {
                        self.showAlert(title: "Error on \(service)", message: "No spots")
                        return
                    }
                    self.info = spotResult.description
                    self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                })
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
            }

            let block : ((UIAlertAction) -> Void)? = { (action) in
                
                guard let location = alert.textFields![0].text,
                    location.count > 0
                else {
                    self.showAlert(title: "\(service)", message: "Missing mandatory field: [Location]")
                    return
                }
                ForecastWindguruService.instance.searchSpots(byLocation: location,
                                                             failure: failureBlock,
                                                             success: { [weak self] (spotResult) in
                    guard let self = self else { return }
                    self.tableView.isHidden = false
                    guard let spotResult = spotResult else {
                        self.showAlert(title: "Error on \(service)", message: "No spots")
                        return
                    }
                    self.info = spotResult.description
                    self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                })
            }
            action = UIAlertAction.init(title: "Search Spots", style: .default, handler: block)
            alert.title = "Enter location"
            alert.message = "Please enter a spot to search (i.e. Bariloche)"
            break

            
        case "c_spots":
            ForecastWindguruService.instance.customSpots(withUsername: user?.name, password: password,
                                                         failure: failureBlock,
                                                         success: { [weak self] (spots) in
                guard let self = self else { return }

                self.tableView.isHidden = false
                guard let spots = spots else {
                    self.showAlert(title: "Error on \(service)", message: "No custom spots")
                    return
                }
                self.info = spots.description
                self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
            })
            break

        case "f_spots":
            ForecastWindguruService.instance.favoriteSpots(withUsername: user?.name, password: password,
                                                           failure: failureBlock,
                                                           success: { [weak self] (spots) in
                guard let self = self else { return }

                self.tableView.isHidden = false
                guard let spots = spots else {
                    self.showAlert(title: "Error on \(service)", message: "No favorites spots")
                    return
                }
                self.info = spots.description
                self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
            })
            break

        case "sets":
            ForecastWindguruService.instance.setSpots(withUsername: user?.name, password: password,
                                                      failure: failureBlock,
                                                      success: { [weak self] (sets) in
                guard let self = self else { return }

                self.tableView.isHidden = false
                guard let sets = sets else {
                    self.showAlert(title: "Error on \(service)", message: "No sets")
                    return
                }
                self.info = sets.description
                self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
            })
            break

        case "model_info":
            
            alert.addTextField { (textfield) in
                textfield.placeholder = "model id # (optional)"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
            }
            
            var modelId = alert.textFields![0].text
            if modelId?.count == 0 {
                modelId = nil
            }

            let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in

                ForecastWindguruService.instance.modelInfo(onlyModelId: modelId,
                                                           failure: failureBlock,
                                                           success: { [weak self] (model) in
                    guard let self = self else { return }
                    self.tableView.isHidden = false
                    guard let model = model else {
                        self.showAlert(title: "Error on \(service)", message: "No model/s")
                        return
                    }
                    self.info = model.description
                    self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                })
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
            }
            alert.addTextField { (textfield) in
                textfield.placeholder = "longitude"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
            }
            
            let block : ((UIAlertAction) -> Void)? = { (action) in

                guard let latText = alert.textFields![0].text,
                    let lonText = alert.textFields![0].text,
                    latText.count > 0,
                    lonText.count > 0
                else {
                    self.showAlert(title: "\(service)", message: "Missing mandatory field: [lat] / [lon]")
                    return
                }

                ForecastWindguruService.instance.models(bylat: latText, lon: lonText,
                                                        failure: failureBlock,
                                                        success: { [weak self] (models) in
                    guard let self = self else { return }
                    self.tableView.isHidden = false
                    guard let models = models else {
                        self.showAlert(title: "Error on \(service)", message: "No model/s")
                        return
                    }
                    self.showAlert(title: "\(service) success", message: models.description)
                })
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
            }
            alert.addTextField { (textfield) in
                textfield.placeholder = "model id #"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
            }
            let block : ((UIAlertAction) -> Void)? = { (action) in
                
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
                ForecastWindguruService.instance.wforecast(bySpotId: spotId,
                                                           model: modelId,
                                                           failure: failureBlock,
                                                           success: { [weak self] (spotForecast) in
                    guard let self = self else { return }
                    self.tableView.isHidden = false
                    guard let spotForecast = spotForecast else {
                        self.showAlert(title: "Error on \(service)", message: "No forecast results")
                        return
                    }
                    self.info = spotForecast.description
                    self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                })
            }

            action = UIAlertAction.init(title: "Forecast", style: .default, handler: block)
            alert.title = "Enter spot id"
            alert.message = "Please enter a spot id (i.e. 64141)"
            
            break


        case "geo_regions":
            ForecastWindguruService.instance.geoRegions(withFailure: failureBlock,
                success: { [weak self] (georegions) in
                guard let self = self else { return }

                self.tableView.isHidden = false
                guard let georegions = georegions else {
                    self.showAlert(title: "Error on \(service)", message: "No georegions")
                    return
                }
                self.info = georegions.description
                self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
            })
            break
            

            
        case "countries":
            alert.addTextField { (textfield) in
                textfield.placeholder = "region id (optional)"
                textfield.autocorrectionType = .no
                textfield.autocapitalizationType = .none
            }
            let block : ((UIAlertAction) -> Void)? = { (action) in

                ForecastWindguruService.instance.countries(byRegionId: alert.textFields![0].text,
                                                           failure: failureBlock,
                                                           success: { [weak self] (countries) in
                    guard let self = self else { return }
                    self.tableView.isHidden = false
                    guard let countries = countries else {
                        self.showAlert(title: "Error on \(service)", message: "No countries")
                        return
                    }
                    self.info = countries.description
                    self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                })
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
            }

            let block : ((UIAlertAction) -> Void)? = { (action) in

                ForecastWindguruService.instance.regions(byCountryId: alert.textFields![0].text,
                                                         failure: failureBlock,
                                                         success: { [weak self] (regions) in
                    guard let self = self else { return }
                    self.tableView.isHidden = false
                    guard let regions = regions else {
                        self.showAlert(title: "Error on \(service)", message: "No regions")
                        return
                    }
                    self.info = regions.description
                    self.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                })
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
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] (action) in
                self?.tableView.isHidden = false
            })
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


