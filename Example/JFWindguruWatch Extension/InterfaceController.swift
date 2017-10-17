//
//  InterfaceController.swift
//  JFWindguruWatch Extension
//
//  Created by javierfuchs on 7/9/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import WatchKit
import Foundation
import JFWindguru


class InterfaceController: WKInterfaceController {
    @IBOutlet var spinner: WKInterfaceActivityRing!
    @IBOutlet var toolbarGroup: WKInterfaceGroup!
    @IBOutlet var topGroup: WKInterfaceGroup!
    @IBOutlet var middleGroup: WKInterfaceGroup!
    @IBOutlet var bottomGroup: WKInterfaceGroup!
    @IBOutlet var temperatureLabel: WKInterfaceLabel!
    @IBOutlet var locationLabel: WKInterfaceLabel!
    @IBOutlet var windSpeedLabel: WKInterfaceLabel!
    @IBOutlet var hourLabel: WKInterfaceLabel!
    @IBOutlet var weatherLabel: WKInterfaceLabel!
    @IBOutlet var windDirectionNameLabel: WKInterfaceLabel!
    @IBOutlet var windDirectionLabel: WKInterfaceLabel!
    
    var spotForecast: SpotForecast!
    var sliderHeight: Float!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        observeNotification()
        
        hideWeatherInfo()
        
        if spotForecast != nil
        {
            updateForecastView()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        unobserveNotification()
        
    }
    
    @IBAction func sliderAction(_ value: Float) {
        
    }
    
    
    
    fileprivate func updateForecastView()
    {
        guard let spotForecast = spotForecast else {
            return
        }
        weatherImage.setImageNamed(spotForecast.asCurrentWeatherImagename)
        windImage.setImageNamed(spotForecast.asCurrentWindDirectionImagename)
        temperatureLabel.setText(spotForecast.asCurrentTemperature)
        unitLabel.setText(spotForecast.asCurrentUnit)
        locationLabel.setText(spotForecast.asCurrentLocation)
        windSpeedLabel.setText(spotForecast.asCurrentWindSpeed)
        hourLabel.setText(spotForecast.asHourString)
            
        showWeatherInfo()
    }
    
    
    fileprivate func observeNotification()
    {
        unobserveNotification()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kWDForecastUpdated), object: nil, queue: OperationQueue.main, using: {
            [weak self]
            note in if let object: SpotForecast = note.object as? SpotForecast {
                self?.spotForecast = object
                self?.updateForecastView()
            }})
    }
    
    fileprivate func unobserveNotification()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kWDForecastUpdated), object: nil);
    }
    
    fileprivate func hideWeatherInfo()
    {
        toolbarGroup.setAlpha(0)
        topGroup.setAlpha(0)
        middleGroup.setAlpha(0)
        bottomGroup.setAlpha(0)
    }
    
    fileprivate func showWeatherInfo()
    {
        animate(withDuration: 1.0) { [weak self] () -> Void in
            self?.toolbarGroup.setAlpha(1)
            self?.topGroup.setAlpha(1)
            self?.middleGroup.setAlpha(1)
            self?.bottomGroup.setAlpha(1)
        }
    }
    
    
}
