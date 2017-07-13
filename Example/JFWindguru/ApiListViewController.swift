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
                            "countries",
                            "forecast",
                            "geo_regions",
                            "model_info",
                            "models_latlon",
                            "regions",
                            "search_spots",
                            "spot",
                            "spots",
                            "wforecast"]

    let servicesWithUser = ["add_f_spot",
                            "c_spots",
                            "f_spots",
                            "set_spots",
                            "sets",
                            "user",
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
        return svcs.sorted()
    }()
}


extension ApiListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        service = services[indexPath.item]
        guard let service = service else { return }
        switch service {
            
        case "countries":
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
                    (forecastResult) in
                    guard let forecastResult = forecastResult else {
                        let subTitle = "No forecast result"
                        SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                        return
                    }
                    SCLAlertView().showSuccess("\(service) success", subTitle: "").setDismissBlock {
                        self?.info = forecastResult.description
                        self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                    }
                }
            }
            alert.showEdit("Enter spot id", subTitle: "Please enter a spot id (i.e. 64141)", closeButtonTitle: "Cancel")
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
                    SCLAlertView().showSuccess("\(service) success", subTitle: "").setDismissBlock {
                        self?.info = spotResult.description
                        self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                    }
                }
            }
            alert.showEdit("Enter location", subTitle: "Please enter a spot to search (i.e. Bariloche)", closeButtonTitle: "Cancel")
            break
            
            
        case "f_spots":
            ForecastWindguruService.instance.favoriteSpots(withUsername: user?.username, password: password, failure: {
                (error) in
                let subTitle = error?.title() ?? ""
                SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
            }) {
                [weak self]
                (favorites) in
                guard let favorites = favorites else {
                    let subTitle = "No favorites"
                    SCLAlertView().showError("Error on \(service)", subTitle: subTitle)
                    return
                }
                SCLAlertView().showSuccess("\(service) success", subTitle: "").setDismissBlock {
                    self?.info = favorites.description
                    self?.performSegue(withIdentifier: "ApiInfoViewController", sender: self)
                }
            }
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


