//
//  MainViewController.swift
//  Forescoop
//
//  Created by Javier Fuchs on 07/06/2017.
//  Copyright (c) 2017 Mobile Patagonia. All rights reserved.
//

import UIKit
import Forescoop

class MainViewController: UIViewController {
    
    @IBOutlet weak var toolbarView: UIView!
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
    var forecastService: ForecastWindguruProtocol? = ForecastWindguruService()
    
    var user: User?
    var isUpdated: Bool = false
    
    required convenience init?(coder: NSCoder, forecastService: ForecastWindguruProtocol? = nil) {
        self.init(coder: coder)
        self.forecastService = forecastService
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateForecast()
        hideWeatherInfo()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ApiListViewController,
              let user = user else { return }
        vc.forecastService = forecastService
        vc.title = "Logged in as:" + user.name
        vc.user = user
        vc.password = passwordTextField?.text
    }
}

private extension MainViewController {
    
    func showForecastView(spotForecast: SpotForecast?) {
        guard let spotForecast = spotForecast else { return }
        weatherLabel.text = spotForecast.weatherInfo
        windDirectionLabel.text = spotForecast.asCurrentWindDirectionName
        windDirectionArrowLabel.text = "↓"
        windDirectionArrowLabel.transform = CGAffineTransform.init(rotationAngle: CGFloat(spotForecast.asCurrentWindDirection))
        temperatureLabel.text = spotForecast.asCurrentTemperature
        locationLabel.text = spotForecast.asCurrentLocation
        windSpeedLabel.text = spotForecast.asCurrentWindSpeed
        hourLabel.text = spotForecast.asHourString
        showWeatherInfo()
    }

    func updateForecast() {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            showForecastView(spotForecast: requestForecastTest())
            isUpdated = true
        } else {
            Task { [weak self] in
                await self?.showForecastView(spotForecast: try self?.requestForecast())
                self?.isUpdated = true
            }
        }
    }
    
    func requestForecastTest() -> SpotForecast? {
        guard SpotResult(map: Definition().json(jsonFile: "SpotResult")) != nil else { return nil }

        return SpotForecast(map: Definition().json(jsonFile: "SpotForecast"))
    }

    func requestForecast() async throws -> SpotForecast? {
        guard let spotId = try? await forecastService?.searchSpots(byLocation: "Bariloche")?.firstSpot?.identifier else { throw CustomError.cannotFindSpotId }
        let spotForecast = try? await forecastService?.forecast(bySpotId: spotId, model: nil)
        return spotForecast
    }
        
    func hideWeatherInfo() {
        toolbarView.alpha = 0
        topView.alpha = 0
        middleView.alpha = 0
        bottomView.alpha = 0
    }
    
    func showWeatherInfo()
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
        
        let block : ((UIAlertAction) -> Void)? = { [weak self] (action) in
            let username = alert.textFields?[0] ?? nil
            let password = alert.textFields?[1] ?? nil
            self?.forecastService?.login(withUsername: username?.text,
                                         password: password?.text,
                                         failure: failureBlock,
                                         success: { [weak self] (user) in
                self?.user = user
                var name = User.Constant.Anonymous.rawValue
                if let user = user {
                    name = user.name
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
}
