//
//  UserViewController.swift
//  JFWindguru
//
//  Created by javierfuchs on 7/12/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import Foundation
import JFWindguru
import SCLAlertView

class ApiListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var user: User?
    var password: String?
    var service: String?
    var info = String()

    let servicesAnonymos = ["user",
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

    let servicesWithUser = ["add_f_spot",
                            "remove_f_spot",
                            "f_spots",
                            "c_spots",
                            "set_spots",
                            "sets",
                            "wforecast_latlon"]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        var svcs = self.servicesAnonymos
        if let user = self.user, user.isAnonymous() == false
        {
            svcs += self.servicesWithUser
        }
        return svcs
    }()
}


extension ApiListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        service = services[indexPath.item]
        guard let service = service else { return }
        switch service {
            
        case "set_spots":
            var searchText: UITextField?
            let alert = SCLAlertView()
            searchText = alert.addTextField("set id")
            searchText?.autocorrectionType = .no
            searchText?.autocapitalizationType = .none
            
            alert.addButton("Add") { [weak self] in
                guard let text = searchText?.text,
                    let user = self?.user,
                    let username = user.username,
                    let password = self?.password else { return }
                ForecastWindguruService.instance.addSetSpots(withSetId: text, username: username, password: password,
                                                                 failure: {
                                                                    (error) in
                                                                    let subTitle = error?.title() ?? ""
                                                                    SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                }) {
                    (spots) in
                    guard let spots = spots else {
                        let subTitle = "Cannot add set id"
                        SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                        return
                    }
                    self?.info = spots.description
                    self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                }
            }
            alert.showEdit("Add Set id", subTitle: "Please enter a set id (i.e. 229823)", closeButtonTitle: "Cancel")
            break
            
        case "add_f_spot":
            var searchText: UITextField?
            let alert = SCLAlertView()
            searchText = alert.addTextField("spot id")
            searchText?.autocorrectionType = .no
            searchText?.autocapitalizationType = .none
            
            alert.addButton("Add") { [weak self] in
                guard let text = searchText?.text,
                    let user = self?.user,
                    let username = user.username,
                    let password = self?.password else { return }
                ForecastWindguruService.instance.addFavoriteSpot(withSpotId: text, username: username, password: password,
                                                                 failure: {
                                                                    (error) in
                                                                    let subTitle = error?.title() ?? ""
                                                                    SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                }) {
                    (result) in
                    guard let result = result else {
                        let subTitle = "Cannot add spot id"
                        SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                        return
                    }
                    SCLAlertView().showSuccess("\(service) success", subTitle: result.description)
                }
            }
            alert.showEdit("Add Favorite", subTitle: "Please enter a spot id (i.e. 64141)", closeButtonTitle: "Cancel")
            break
            
        case "remove_f_spot":
            var searchText: UITextField?
            let alert = SCLAlertView()
            searchText = alert.addTextField("spot id")
            searchText?.autocorrectionType = .no
            searchText?.autocapitalizationType = .none
            
            alert.addButton("Remove") { [weak self] in
                guard let text = searchText?.text,
                      let user = self?.user,
                      let username = user.username,
                      let password = self?.password else { return }
                ForecastWindguruService.instance.removeFavoriteSpot(withSpotId: text, username: username, password: password,
                 failure: {
                    (error) in
                    let subTitle = error?.title() ?? ""
                    SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                }) {
                    (result) in
                    guard let result = result else {
                        let subTitle = "Cannot remove spot id"
                        SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                        return
                    }
                    SCLAlertView().showSuccess("\(service) success", subTitle: result.description)
                }
            }
            alert.showEdit("Remove Favorite", subTitle: "Please enter a spot id (i.e. 64141)", closeButtonTitle: "Cancel")
            break
            
        case "forecast":
            var searchText: UITextField?
            let alert = SCLAlertView()
            searchText = alert.addTextField("spot id")
            searchText?.autocorrectionType = .no
            searchText?.autocapitalizationType = .none
            
            alert.addButton("Forecast") { [weak self] in
                guard let text = searchText?.text else { return }
                ForecastWindguruService.instance.forecast(bySpotId: text,
                                                          failure: {
                                                            (error) in
                                                            let subTitle = error?.title() ?? ""
                                                            SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                }) {
                    [weak self]
                    (spotForecast) in
                    guard let spotForecast = spotForecast else {
                        let subTitle = "No forecast result"
                        SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                        return
                    }
                    self?.info = spotForecast.description
                    self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                }
            }
            alert.showEdit("Enter spot id", subTitle: "Please enter a spot id (i.e. 64141)", closeButtonTitle: "Cancel")
            break
            
            
        case "spot":
            var spotIdTextField: UITextField?
            let alert = SCLAlertView()
            spotIdTextField = alert.addTextField("spot id")
            spotIdTextField?.autocorrectionType = .no
            spotIdTextField?.autocapitalizationType = .none
            
            alert.addButton("get Spot Info") { [weak self] in
                guard let text = spotIdTextField?.text else { return }
                ForecastWindguruService.instance.spotInfo(bySpotId: text,
                  failure: {
                    (error) in
                    let subTitle = error?.title() ?? ""
                    SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                }) {
                    [weak self]
                    (spotInfo) in
                    guard let spotInfo = spotInfo else {
                        let subTitle = "No spot info"
                        SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                        return
                    }
                    self?.info = spotInfo.description
                    self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                }
            }
            alert.showEdit("Enter spot id", subTitle: "Please enter a spot id (i.e. 64141)", closeButtonTitle: "Cancel")
            break
            
            
        case "spots":
            var countryText: UITextField?
            var regionText: UITextField?
            let alert = SCLAlertView()
            countryText = alert.addTextField("country id# (optional)")
            countryText?.autocorrectionType = .no
            countryText?.autocapitalizationType = .none
            
            regionText = alert.addTextField("region id# (optional)")
            regionText?.autocorrectionType = .no
            regionText?.autocapitalizationType = .none
            
            alert.addButton("get spots") { [weak self] in
                ForecastWindguruService.instance.spots(withCountryId: countryText?.text, regionId: regionText?.text,
                   failure: {
                    (error) in
                    let subTitle = error?.title() ?? ""
                    SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                }) {
                    [weak self]
                    (spotResult) in
                    guard let spotResult = spotResult else {
                        let subTitle = "No spots"
                        SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                        return
                    }
                    self?.info = spotResult.description
                    self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                }
            }
            alert.showEdit("Enter country/region", subTitle: "Please enter info to search (i.e. country = 76, region = 209)", closeButtonTitle: "Cancel")
            break
            
            
            
        case "search_spots":
            var searchText: UITextField?
            let alert = SCLAlertView()
            searchText = alert.addTextField("Location")
            searchText?.autocorrectionType = .no
            searchText?.autocapitalizationType = .none
            
            alert.addButton("Search Spots") { [weak self] in
                guard let text = searchText?.text else { return }
                ForecastWindguruService.instance.searchSpots(byLocation: text,
                    failure: {
                    (error) in
                    let subTitle = error?.title() ?? ""
                    SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                }) {
                    [weak self]
                    (spotResult) in
                    guard let spotResult = spotResult else {
                        let subTitle = "No spots"
                        SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                        return
                    }
                    self?.info = spotResult.description
                    self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                }
            }
            alert.showEdit("Enter location", subTitle: "Please enter a spot to search (i.e. Bariloche)", closeButtonTitle: "Cancel")
            break
        
        case "c_spots":
            ForecastWindguruService.instance.customSpots(withUsername: user?.username, password: password, failure: {
                (error) in
                let subTitle = error?.title() ?? ""
                SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
            }) {
                [weak self]
                (spots) in
                guard let spots = spots else {
                    let subTitle = "No custom spots"
                    SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                    return
                }
                self?.info = spots.description
                self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
            }
            break
            
        case "f_spots":
            ForecastWindguruService.instance.favoriteSpots(withUsername: user?.username, password: password, failure: {
                (error) in
                let subTitle = error?.title() ?? ""
                SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
            }) {
                [weak self]
                (spots) in
                guard let spots = spots else {
                    let subTitle = "No favorites"
                    SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                    return
                }
                self?.info = spots.description
                self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
            }
            break
            
        case "sets":
            ForecastWindguruService.instance.setSpots(withUsername: user?.username, password: password, failure: {
                (error) in
                let subTitle = error?.title() ?? ""
                SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
            }) {
                [weak self]
                (sets) in
                guard let sets = sets else {
                    let subTitle = "No sets"
                    SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                    return
                }
                self?.info = sets.description
                self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
            }
            break
            
        case "model_info":
            var modelIdTextField: UITextField?
            let alert = SCLAlertView()
            modelIdTextField = alert.addTextField("model id (optional)")
            modelIdTextField?.autocorrectionType = .no
            modelIdTextField?.autocapitalizationType = .none
            
            alert.addButton("get model/s") { [weak self] in
                ForecastWindguruService.instance.modelInfo(onlyModelId: modelIdTextField?.text,
                                                           failure: {
                                                            (error) in
                                                            let subTitle = error?.title() ?? ""
                                                            SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                }) {
                    [weak self]
                    (model) in
                    guard let model = model else {
                        let subTitle = "No models"
                        SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                        return
                    }
                    self?.info = model.description
                    self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                }
            }
            alert.showEdit("Enter model id", subTitle: "Please enter a model id (i.e. 3)", closeButtonTitle: "Cancel")
            break
            
        case "models_latlon":
            let alert = SCLAlertView()
            var latTextField: UITextField?
            latTextField = alert.addTextField("latitude")
            latTextField?.autocorrectionType = .no
            latTextField?.autocapitalizationType = .none
            var lonTextField: UITextField?
            lonTextField = alert.addTextField("longitude")
            lonTextField?.autocorrectionType = .no
            lonTextField?.autocapitalizationType = .none
            
            alert.addButton("query lat/lon") {
                guard let latText = latTextField?.text,
                    let lonText = lonTextField?.text else { return }
                ForecastWindguruService.instance.models(bylat: latText, lon: lonText,
                failure: {
                    (error) in
                    let subTitle = error?.title() ?? ""
                    SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                }) {
                    (models) in
                    guard let models = models else {
                        let subTitle = "No models"
                        SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                        return
                    }
                    SCLAlertView().showSuccess("\(service) success", subTitle: models.description)
                }
            }
            alert.showEdit("Enter latitude/longitude", subTitle: "Please enter (i.e. -41 / -71)", closeButtonTitle: "Cancel")
            break
            
        case "wforecast":
            var searchText: UITextField?
            let alert = SCLAlertView()
            searchText = alert.addTextField("spot id")
            searchText?.autocorrectionType = .no
            searchText?.autocapitalizationType = .none
            
            alert.addButton("Forecast") { [weak self] in
                guard let text = searchText?.text else { return }
                ForecastWindguruService.instance.wforecast(bySpotId: text,
                                                          failure: {
                                                            (error) in
                                                            let subTitle = error?.title() ?? ""
                                                            SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                }) {
                    [weak self]
                    (spotForecast) in
                    guard let spotForecast = spotForecast else {
                        let subTitle = "No forecast result"
                        SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                        return
                    }
                    self?.info = spotForecast.description
                    self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                }
            }
            alert.showEdit("Enter spot id", subTitle: "Please enter a spot id (i.e. 64141)", closeButtonTitle: "Cancel")
            break
            

        case "geo_regions":
            ForecastWindguruService.instance.geoRegions(withFailure: {
                (error) in
                let subTitle = error?.title() ?? ""
                SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
            }) {
                [weak self]
                (georegions) in
                guard let georegions = georegions else {
                    let subTitle = "No georegions"
                    SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                    return
                }
                self?.info = georegions.description
                self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
            }
            break
            
            
            
        case "countries":
            var regionIdTextField: UITextField?
            let alert = SCLAlertView()
            regionIdTextField = alert.addTextField("region id (optional)")
            regionIdTextField?.autocorrectionType = .no
            regionIdTextField?.autocapitalizationType = .none
            
            alert.addButton("get country/s") { [weak self] in
                ForecastWindguruService.instance.countries(byRegionId: regionIdTextField?.text,
                                                           failure: {
                                                            (error) in
                                                            let subTitle = error?.title() ?? ""
                                                            SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                }) {
                    [weak self]
                    (countries) in
                    guard let countries = countries else {
                        let subTitle = "No countries"
                        SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                        return
                    }
                    self?.info = countries.description
                    self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                }
            }
            alert.showEdit("Enter region id", subTitle: "Please enter a region id (i.e. 5)", closeButtonTitle: "Cancel")
            break
            
            
            
        case "regions":
            var countryIdTextField: UITextField?
            let alert = SCLAlertView()
            countryIdTextField = alert.addTextField("country id (optional)")
            countryIdTextField?.autocorrectionType = .no
            countryIdTextField?.autocapitalizationType = .none
            
            alert.addButton("get region/s") { [weak self] in
                ForecastWindguruService.instance.regions(byCountryId: countryIdTextField?.text,
                                                           failure: {
                                                            (error) in
                                                            let subTitle = error?.title() ?? ""
                                                            SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                }) {
                    [weak self]
                    (regions) in
                    guard let regions = regions else {
                        let subTitle = "No regions"
                        SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                        return
                    }
                    self?.info = regions.description
                    self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                }
            }
            alert.showEdit("Enter country id", subTitle: "Please enter a country id (i.e. 76)", closeButtonTitle: "Cancel")
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


