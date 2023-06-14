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

        guard let alert = AlertViewModel(apiController: apiController).alertController else { return }
        self.present(alert, animated: true, completion: nil)
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
