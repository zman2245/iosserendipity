//
//  HotspotListController.swift
//  Serendipity
//
//  Created by Zachary Foster on 5/30/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class HotspotListController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    let DEFAULT_RADIUS_M: Double = 100000
    
    @IBOutlet weak var hotspotTable: UITableView!
    @IBOutlet weak var nearbyMap: MKMapView!
    
    var locationService: LocationService = LocationService.sharedLocation
    var dataService: DataService = DataService()
    var hotspots: [Hotspot] = []
    
    // for help passing data into HotspotDetailsController
    var selectedHotspot: Hotspot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hotspotTable.delegate = self
        self.hotspotTable.dataSource = self
        
        self.initMap()
        NotificationCenter.default.addObserver(forName: LocationService.LOCATION_UPDATE_NOTIFICATION, object: nil, queue: nil) { (notification) in
            print("location updated. new lat:", self.locationService.currentLat as Any)
            self.initMap()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is HotspotDetailsController {
            let vc = segue.destination as? HotspotDetailsController
            vc?.hotspot = self.selectedHotspot
        }
    }
    
    // MARK: - Map handling
    
    func initMap() {
        guard let currentLat = self.locationService.currentLat else {
            return
        }
        
        guard let currentLong = self.locationService.currentLong else {
            return
        }
        
        let center = CLLocation(latitude: currentLat, longitude: currentLong)
        
        // in meters
        let regionRadius: CLLocationDistance = DEFAULT_RADIUS_M
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(center.coordinate,
                                                                  regionRadius, regionRadius)
        nearbyMap.setRegion(coordinateRegion, animated: true)
        nearbyMap.delegate = self
        
        self.lookupHotspots(latitude: currentLat, longitude: currentLong, radius: Int(regionRadius))
    }
    
    func lookupHotspots(latitude: Double, longitude: Double, radius: Int) {
        
        dataService.fetchHotspots(latitude: latitude, longitude: longitude, radius: radius) { (result) in
            switch result {
            case .Success(let data):
                self.hotspots = data
                self.hotspotTable.reloadData()
                self.addAnnotationsToMap()
            case .Error(let message):
                // TODO: something user friendly
                print(message)
            }
        }
    }
    
    func addAnnotationsToMap() {
        let annotations = buildAnnotations()
        nearbyMap.removeAnnotations(nearbyMap.annotations)
        nearbyMap.addAnnotations(annotations)
    }
    
    func buildAnnotations() -> [MKAnnotation] {
        var annotations: [MKAnnotation] = []
        var a: MKPlacemark
        
        for hotspot in self.hotspots {
            let coordinates = CLLocationCoordinate2DMake(Double(hotspot.latitude), Double(hotspot.longitude))
            a = MKPlacemark(coordinate: coordinates)
            
            annotations.append(a)
        }
        
        return annotations
    }
    
    // MARK: - MKMapViewDelegate methods
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("map changed", mapView.userLocation, mapView.region)
        let span = mapView.region.span
        let center = mapView.region.center
        
        let loc1 = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc2 = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc3 = CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta * 0.5)
        let loc4 = CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta * 0.5)
        
        let metersInLatitude = loc1.distance(from: loc2)
        let metersInLongitude = loc3.distance(from: loc4)
        
        let radius = min(metersInLatitude, metersInLongitude)
        
        self.lookupHotspots(latitude: center.latitude, longitude: center.longitude, radius: Int(radius))
    }
    
    // MARK: - UITableView delegate and dataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hotspots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HotspotCell", for: indexPath) as! HotspotCell
        let hotspot = hotspots[indexPath.row]

        cell.textLabel?.text = hotspot.title ?? "No title"

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hotspot = hotspots[indexPath.row]
        self.selectedHotspot = hotspot
        self.performSegue(withIdentifier: "ShowHotspotDetails", sender: self)
    }
}
