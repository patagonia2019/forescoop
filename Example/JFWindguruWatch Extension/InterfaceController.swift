//
//  InterfaceController.swift
//  JFWindguruWatch Extension
//
//  Created by javierfuchs on 7/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
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
    @IBOutlet var slider: WKInterfaceSlider!
    @IBOutlet var weatherImage: WKInterfaceImage!
    @IBOutlet var windImage: WKInterfaceImage!
    @IBOutlet var temperatureLabel: WKInterfaceLabel!
    @IBOutlet var unitLabel: WKInterfaceLabel!
    @IBOutlet var locationLabel: WKInterfaceLabel!
    @IBOutlet var windSpeedLabel: WKInterfaceLabel!
    @IBOutlet var hourLabel: WKInterfaceLabel!
    
    var forecastResult: ForecastResult!
    var sliderHeight: Float!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.observeNotification()
        
        self.hideWeatherInfo()
        
        if self.forecastResult != nil
        {
            self.updateForecastView()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        self.unobserveNotification()
        
    }
    
    @IBAction func sliderAction(_ value: Float) {
        
    }
    
    
    
    fileprivate func updateForecastView()
    {
        if self.forecastResult != nil
        {
            self.weatherImage.setImageNamed(self.forecastResult.asCurrentWeatherImagename)
            self.windImage.setImageNamed(self.forecastResult.asCurrentWindDirectionImagename)
            self.temperatureLabel.setText(self.forecastResult.asCurrentTemperature)
            self.unitLabel.setText(self.forecastResult.asCurrentUnit)
            self.locationLabel.setText(self.forecastResult.asCurrentLocation)
            self.windSpeedLabel.setText(self.forecastResult.asCurrentWindSpeed)
            self.hourLabel.setText(self.forecastResult.asHourString)
            
            self.showWeatherInfo()
        }
        
    }
    
    
    fileprivate func observeNotification()
    {
        self.unobserveNotification()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kWDForecastUpdated), object: nil, queue: OperationQueue.main, using: {
            note in if let object: ForecastResult = note.object as? ForecastResult {
                self.forecastResult = object
                self.updateForecastView()
            }})
    }
    
    fileprivate func unobserveNotification()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kWDForecastUpdated), object: nil);
    }
    
    fileprivate func hideWeatherInfo()
    {
        self.toolbarGroup.setAlpha(0)
        self.topGroup.setAlpha(0)
        self.middleGroup.setAlpha(0)
        self.bottomGroup.setAlpha(0)
    }
    
    fileprivate func showWeatherInfo()
    {
        self.animate(withDuration: 1.0) { () -> Void in
            self.toolbarGroup.setAlpha(1)
            self.topGroup.setAlpha(1)
            self.middleGroup.setAlpha(1)
            self.bottomGroup.setAlpha(1)
        }
    }
    
    
}
