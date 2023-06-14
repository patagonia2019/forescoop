//
//  MainViewController.swift
//  Forescoop
//
//  Created by Javier Fuchs on 07/06/2017.
//  Copyright © 2023 Mobile Patagonia. All rights reserved.
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
    
    var apiController: ApiController? = nil
    
    var isUpdated: Bool = false
    
    required convenience init?(coder: NSCoder, forecastService: ForecastWindguruProtocol? = nil) {
        self.init(coder: coder)
        self.apiController = ApiController(forecastService: forecastService, delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateForecast()
        hideWeatherInfo()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ApiListViewController else { return }
        vc.apiController = ApiController(user: apiController?.user, password: apiController?.password, forecastService: apiController?.forecastService, delegate: vc)
        vc.title = "Logged in as:" + (vc.apiController?.userName ?? "Unknown")
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
            showForecastView(spotForecast: try? requestForecastTest())
            isUpdated = true
        } else {
            Task { [weak self] in
                do {
                    await self?.showForecastView(spotForecast: try self?.requestForecast())
                    self?.isUpdated = true
                } catch {
                    self?.showError(title: "Error", error: error)
                }
            }
        }
    }
    
    func requestForecastTest() throws -> SpotForecast? {
        guard try SpotResult(map: Definition().json(jsonFile: "SpotResult")) != nil else {
            return nil
        }
        return try SpotForecast(map: Definition().json(jsonFile: "SpotForecast"))
    }

    func requestForecast() async throws -> SpotForecast? {
        try await apiController?.start()
    }
        
    func hideWeatherInfo() {
        toolbarView.alpha = 0
        topView.alpha = 0
        middleView.alpha = 0
        bottomView.alpha = 0
    }
    
    func showWeatherInfo() {
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
        
        let login = UIAlertAction.init(title: "Login", style: .default) { [weak self] _ in
            self?.apiController?.login(username: alert.textFields?[0].text,
                                       pass: alert.textFields?[1].text)
        }
        alert.addAction(login)
        let loginAnon = UIAlertAction.init(title: "Login as Anonymous", style: .default) { [weak self] _ in
            self?.apiController?.loginAnonymous()
        }
        alert.addAction(loginAnon)
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showError(title: String, error: Error?) {
        let message = (error as? CustomError)?.description ?? error?.localizedDescription ?? "n/a"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension MainViewController: ApiControllerDelegate {
    func showApiInfo(info: String) {
        let userName = apiController?.userName ?? "Unknown"
        let alert = UIAlertController(title: "You are in!", message: "Welcome Windguru user \(userName)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
            self?.performSegue(withIdentifier: "ApiListViewController", sender: self)
        }))
        
        present(alert, animated: true, completion:nil)
        
        loginButton.setTitle("Logged in as: \(userName)", for: .normal)
    }
    
    func showError(service: String?, error: Error?) {
        let title = "Error on \(service ?? "n/a")"
        showError(title: title, error: error)
    }
}
