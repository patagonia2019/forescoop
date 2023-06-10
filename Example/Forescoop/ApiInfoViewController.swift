//
//  ApiInfoViewController.swift
//  Forescoop
//
//  Created by javierfuchs on 7/13/17.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import Forescoop

class ApiInfoViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    var info = String()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = info
    }
    
}


