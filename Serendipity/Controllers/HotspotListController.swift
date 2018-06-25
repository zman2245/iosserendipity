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

class HotspotListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        
        self.lookupHotspots()
        NotificationCenter.default.addObserver(forName: LocationService.LOCATION_UPDATE_NOTIFICATION, object: nil, queue: nil) { (notification) in
            print("location updated. new lat:", self.locationService.currentLat)
            self.lookupHotspots()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is HotspotDetailsController {
            let vc = segue.destination as? HotspotDetailsController
            vc?.hotspot = self.selectedHotspot
        }
    }
    
    // MARK: - Map handling
    func lookupHotspots() {
        guard let currentLat = self.locationService.currentLat else {
            return
        }
        
        guard let currentLong = self.locationService.currentLong else {
            return
        }
        
        dataService.fetchHotspots(latitude: currentLat, longitude: currentLong, radius: Int(DEFAULT_RADIUS_M)) { (result) in
            switch result {
            case .Success(let data):
                self.hotspots = data
                self.initMap()
                self.hotspotTable.reloadData()
            case .Error(let message):
                // TODO: something user friendly
                print(message)
            }
        }
    }
    
    func initMap() {
        let center = CLLocation(latitude: locationService.currentLat!, longitude: locationService.currentLong!)
        let annotations = buildAnnotations()
        
        // in meters
        let regionRadius: CLLocationDistance = DEFAULT_RADIUS_M
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(center.coordinate,
                                                                  regionRadius, regionRadius)
        nearbyMap.setRegion(coordinateRegion, animated: true)
        
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
