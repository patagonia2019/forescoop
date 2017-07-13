//
//  ApiInfoViewController.swift
//  JFWindguru
//
//  Created by javierfuchs on 7/13/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import JFWindguru
import SCLAlertView

class ApiInfoViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var info = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

extension ApiInfoViewController: UITableViewDelegate {
}

extension ApiInfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return info.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
        cell.textLabel?.text = info[indexPath.row]
        return cell
    }
    
    
}


