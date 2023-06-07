//
//  InterfaceController.swift
//  Forescoop Extension
//
//  Created by javierfuchs on 10/17/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import WatchKit
import Foundation
import Forescoop


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
    var forecastService: ForecastWindguruService? = nil

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        updateForecast()
        hideWeatherInfo()
    }
}

private extension InterfaceController {
    func showForecastView(spotForecast: SpotForecast?) {
        guard let spotForecast = spotForecast else { return }
        temperatureLabel.setText(spotForecast.asCurrentTemperature)
        locationLabel.setText(spotForecast.asCurrentLocation)
        windSpeedLabel.setText(spotForecast.asCurrentWindSpeed)
        hourLabel.setText(spotForecast.asHourString)
        weatherLabel.setText(spotForecast.weatherInfo)
        windDirectionLabel.setText(spotForecast.asCurrentWindDirectionName)
        windDirectionNameLabel.setText(spotForecast.asCurrentWindDirectionName)
        
        showWeatherInfo()
    }
    
    func updateForecast() {
        Task { [weak self] in
            guard let spotId = try? await forecastService?.searchSpots(byLocation: "Bariloche")?.firstSpot?.id else { throw CustomError.cannotFindSpotId }
            let spotForecast = try? await forecastService?.forecast(bySpotId: spotId)
            self?.showForecastView(spotForecast: spotForecast)
        }
    }
        
    func hideWeatherInfo() {
        toolbarGroup.setAlpha(0)
        topGroup.setAlpha(0)
        middleGroup.setAlpha(0)
        bottomGroup.setAlpha(0)
    }
    
    func showWeatherInfo() {
        animate(withDuration: 1.0) { [weak self] () -> Void in
            self?.toolbarGroup.setAlpha(1)
            self?.topGroup.setAlpha(1)
            self?.middleGroup.setAlpha(1)
            self?.bottomGroup.setAlpha(1)
        }
    }
}
