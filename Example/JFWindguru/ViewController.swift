//
//  ViewController.swift
//  JFWindguru
//
//  Created by southfox on 07/06/2017.
//  Copyright (c) 2017 southfox. All rights reserved.
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
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var windImage: UIImageView!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    
    var forecastResult: ForecastResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        observeNotification()
        
        hideWeatherInfo()
        
        if forecastResult != nil
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
        guard let forecastResult = forecastResult else {
            return
        }
        let weatherImageName = forecastResult.asCurrentWeatherImagename
        let image = UIImage(named: weatherImageName)
        weatherImage.image = image
        windImage.image = UIImage(named: forecastResult.asCurrentWindDirectionImagename)
        temperatureLabel.text = forecastResult.asCurrentTemperature
        unitLabel.text = forecastResult.asCurrentUnit
        locationLabel.text = forecastResult.asCurrentLocation
        windSpeedLabel.text = forecastResult.asCurrentWindSpeed
        hourLabel.text = forecastResult.asHourString
        
        showWeatherInfo()
    }


    private func observeNotification()
    {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kWDForecastUpdated), object: nil, queue: OperationQueue.main) {
            [weak self] (note) in
            if let object: ForecastResult = note.object as? ForecastResult {
                self?.forecastResult = object
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
    
    
}
