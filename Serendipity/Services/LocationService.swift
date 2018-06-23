//
//  LocationService.swift
//  Serendipity
//
//  Created by Zachary Foster on 6/18/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//

import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    
    static let LOCATION_UPDATE_NOTIFICATION = Notification.Name("LocationServiceUpdate")
    static let sharedLocation = LocationService()
    
    private var locationManager = CLLocationManager()
    var currentLat: Double?
    var currentLong: Double?
    
    private override init () {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        self.currentLat = userLocation.coordinate.latitude
        self.currentLong = userLocation.coordinate.longitude
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        NotificationCenter.default.post(name: LocationService.LOCATION_UPDATE_NOTIFICATION, object: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}
