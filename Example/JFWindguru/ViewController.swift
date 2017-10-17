//
//  ViewController.swift
//  JFWindguru
//
//  Created by Javier Fuchs on 07/06/2017.
//  Copyright (c) 2017 Mobile Patagonia. All rights reserved.
//

import UIKit
import JFWindguru

class ViewController: UIViewController {
    
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var horizontalSlider: UISlider!
    @IBOutlet weak var hourLabel: UILabel!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windDirectionArrowLabel: UILabel!
    @IBOutlet weak var windDirectionLabel: UILabel!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var passwordTextField: UITextField?
    
    var user: User?
    
    var spotForecast: SpotForecast!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        observeNotification()
        
        hideWeatherInfo()
        
        if spotForecast != nil
        {
            updateForecastView()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unobserveNotification()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateForecastView()
    {
        guard let spotForecast = spotForecast else {
            return
        }
        weatherLabel.text = spotForecast.weatherInfo()
        windDirectionLabel.text = spotForecast.asCurrentWindDirectionName
        windDirectionArrowLabel.text = "↓"
        windDirectionArrowLabel.transform = CGAffineTransform.init(rotationAngle: spotForecast.asCurrentWindDirection)
        temperatureLabel.text = spotForecast.asCurrentTemperature
        locationLabel.text = spotForecast.asCurrentLocation
        windSpeedLabel.text = spotForecast.asCurrentWindSpeed
        hourLabel.text = spotForecast.asHourString
        
        showWeatherInfo()
    }


    private func observeNotification()
    {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kWDForecastUpdated), object: nil, queue: OperationQueue.main) {
            [weak self] (note) in
            if let object: SpotForecast = note.object as? SpotForecast {
                self?.spotForecast = object
                self?.updateForecastView()
            }}
    }
    
    private func unobserveNotification()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kWDForecastUpdated), object: nil)
        
    }
    
    private func hideWeatherInfo()
    {
        toolbarView.alpha = 0
        topView.alpha = 0
        middleView.alpha = 0
        bottomView.alpha = 0
    }
    
    private func showWeatherInfo()
    {
        UIView.animate(withDuration: kWDAnimationDuration) { [weak self] () -> Void in
            self?.toolbarView.alpha = 1
            self?.topView.alpha = 1
            self?.middleView.alpha = 1
            self?.bottomView.alpha = 1
        }
    }
    
    @IBAction func loginButtonAction() {
        loginButton.setTitle("Login", for: .normal)
        
        let alert = UIAlertController(title: "Enter credentials", message: "Please enter Windguru's username/password", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "username"
            textfield.autocorrectionType = .no
            textfield.autocapitalizationType = .none
        }
        alert.addTextField { (textfield) in
            textfield.placeholder = "password"
            textfield.autocorrectionType = .no
            textfield.autocapitalizationType = .none
            textfield.isSecureTextEntry = true
        }
        
        let failureBlock : ForecastWindguruService.FailureType = {
            [weak self] (error) in
            self?.showError(title: "Error on login", error: error)
        }
        
        let block : ((UIAlertAction) -> Void)? = { [weak self]  (action) in
            let username = alert.textFields?[0] ?? nil
            let password = alert.textFields?[1] ?? nil
            ForecastWindguruService.instance.login(withUsername: username?.text,
                                                   password: password?.text,
                                                   failure: failureBlock,
                                                   success: { [weak self] (user) in
                                                    self?.user = user
                                                    var name = "Anonymous"
                                                    if let user = user {
                                                        name = user.name()
                                                        self?.passwordTextField = password
                                                    }
                                                    let alert = UIAlertController(title: "You are in!", message: "Welcome Windguru user \(name)", preferredStyle: .alert)
                                                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                                        self?.performSegue(withIdentifier: "ApiListViewController", sender: self)
                                                    }))
                                                    self?.present(alert, animated: true, completion:nil)

                                                    self?.loginButton.setTitle("Logged in as: \(name)", for: .normal)
            })
        }

        let login = UIAlertAction.init(title: "Login", style: .default, handler: block)
        alert.addAction(login)
        let loginAnon = UIAlertAction.init(title: "Login as Anonymous", style: .default, handler: block)
        alert.addAction(loginAnon)
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showError(title: String, error: WGError?) {
        let message = error?.title() ?? ""
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ApiListViewController {
            if let user = user {
                vc.title = "Logged in as:" + user.name()
                vc.user = user
                vc.password = passwordTextField?.text
            }
        }
    }
}
