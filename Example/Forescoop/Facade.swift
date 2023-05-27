//
//  Facade.swift
//  Forescoop
//
//  Created by javierfuchs on 7/9/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import Foundation
import Forescoop

/*
 *  WDFacade
 *
 *  Discussion:
 *    Manager of synchronization between the watch/iphone/ipad it shares plist files using a common group.
 *    It is subscribed to notifications of the LocationManager to update the plist file with the new location/country.
 */


public class Facade: NSObject {
    
    //
    // Attributes only modified by this class
    //
    private var currentLocality: String?
    private var currentCountry: String?
    
    //
    // Singleton
    //
    static let instance = Facade()
    
    
    /// start service manager
    func start() {
        startForecastServices()
    }
    
    /// stop service manager
    func stop() {
        stopForecastServices()
    }
    
    /// current locality
    var currentLocation: String? {
        currentLocality
    }
}

private extension Facade {
    /// Return the absolute file path of the group
    var absoluteFilePath: URL? {
        #if false
            guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: kWDGroup) else {
                return nil
            }
            let filePath = url.appendingPathComponent(kWDWatchPlist)
        #else
            let url = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
            let filePath = url.appendingPathComponent(kWDWatchPlist)
        #endif
        print(filePath)
        return filePath
    }
    
    /// Write the file
    func writeNote(note: String, location: [String: String?]) {
        guard let filePath = absoluteFilePath else {
            return
        }
        let dict: NSDictionary = [note : location]
        if dict.write(to: filePath, atomically: true) {
        }
    }
    
    
    /// Forecast group of code
    func startForecastServices() {
        let locality = "Bariloche"
        let country = "AR"
        currentLocality = locality
        currentCountry = country
        
        updateForecast()
    }
    
    func stopForecastServices() {
    }
    
    func updateForecast() {
        guard let location = currentLocation else {
            return
        }
        ForecastWindguruService.instance.searchSpots(byLocation: location, failure: { (error) in
            print("error = \(String(describing: error))")
        }) { (spotResult) in
            
            guard let spotResult = spotResult,
                  let spot = spotResult.lastSpot,
                  let spotId = spot.id else {
                return
            }
            ForecastWindguruService.instance.forecast(bySpotId: spotId, failure: { (error) in
                print("error = \(String(describing: error))")
            }, success: { (spotForecast) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kWDForecastUpdated), object: spotForecast)
            })
       }
    }
}
