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
    
    @IBOutlet weak var textView: UITextView!
    var info = String()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = info
    }
    
}


