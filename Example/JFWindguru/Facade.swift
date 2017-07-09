//
//  Facade.swift
//  JFWindguru
//
//  Created by javierfuchs on 7/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import JFCore
import JFWindguru

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
    public static let instance = Facade()
    
    
    //
    // start service manager
    //
    public func start()
    {
        startLocationServices()
        startForecastServices()
    }
    
    //
    // stop service manager
    //
    public func stop()
    {
        stopLocationServices()
        stopForecastServices()
    }
    
    
    //
    // restore information (used by watch)
    //
    public func restoreInfo() -> Bool
    {
        guard let filePath = absoluteFilePath() else {
            return false
        }
        
        if FileManager.default.fileExists(atPath: filePath.path) {

            guard let dict = NSDictionary.init(contentsOf: filePath) as? Dictionary<String, NSDictionary> else {
                return false
            }
            
            let location : NSDictionary = dict[JFCore.Constants.Notification.locationUpdated]!
            if (location != NSNull())
            {
                // Treat location update
                
                currentLocality = String(describing: location[kWDKeyLocality]!)
                currentCountry = String(describing: location[kWDKeyCountry]!)
                
                return true
            }
        } else {
            print("No last location")
        }
        return false
    }
    
    //
    // Location code
    //
    private func startLocationServices()
    {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: JFCore.Constants.Notification.locationUpdated), object: nil, queue: OperationQueue.main, using: {
            [weak self] note in
//                if (TARGET_OS_WATCH == 1)
//                {
//                    if let ret = self?.restoreInfo(), ret == true {
//                        self?.updateForecast()
//                    }
//                }
//                else
//                {
                    guard let locations = LocationManager.instance.locations,
                          let location = locations.first else {
                        return
                    }
                    LocationManager.instance.reverseLocation(location: location, didFailWithError: { (error) in
                        print("error: \(error)")
                    }, didUpdatePlacemarks: { (placemarks) in
                        guard let placemark = placemarks.first,
                            let locality = placemark.locality,
                            let country = placemark.country else {
                            return
                        }
                        self?.currentLocality = locality
                        self?.currentCountry = country
                        
                        let dict = [kWDKeyLocality: locality, kWDKeyCountry: country]
                        self?.writeNote(note: JFCore.Constants.Notification.locationUpdated, location: dict)
                        self?.updateForecast()
                    })
//                }
        })
        
    }
    
    private func stopLocationServices()
    {
        LocationManager.instance.stop()
    }
    
    
    public func getCurrentLocation() -> String?
    {
        return currentLocality
    }
    
    //
    // Return the absolute file path of the group
    //
    private func absoluteFilePath() -> URL?
    {
        #if false
            guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: kWDGroup) else {
                return nil
            }
            let filePath = url.appendingPathComponent(kWDWatchPlist)
        #else
            let url = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
            let filePath = url.appendingPathComponent(kWDWatchPlist)
        #endif
        if (TARGET_OS_WATCH == 1)
        {
            print("Watch")
        }
        else
        {
            print("iPhone/iPad")
        }
        print(filePath)
        return filePath
    }
    
    //
    // Write the file
    //
    private func writeNote(note: String, location: [String: String?])
    {
        guard let filePath = absoluteFilePath() else {
            return
        }
        let dict: NSDictionary = [note : location]
        if dict.write(to: filePath, atomically: true) {
        }
    }
    
    
    //
    // Forecast group of code
    //
    private func startForecastServices()
    {
        if self.restoreInfo()
        {
            self.updateForecast()
        }
    }
    
    private func stopForecastServices()
    {
    }
    
    private func updateForecast()
    {
        guard let location = getCurrentLocation() else {
            return
        }
        ForecastWindguruService.instance.queryLocation(location: location, updateSpotDidFailWithError: { (error) in
            print("error = \(error)")
        }) { (spotResult) in
            guard let spots = spotResult.spots,
                let spot = spots.last else {
                return
            }
            guard let identity = spot.identity else {
                return
            }
            ForecastWindguruService.instance.queryWeatherSpot(spot: identity, updateForecastDidFailWithError: { (error) in
                print("error = \(error)")
            }, didUpdateForecastResult: { (forecastResult) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kWDForecastUpdated), object: forecastResult)
            })
       }
    }


}
