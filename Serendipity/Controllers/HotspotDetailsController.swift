//
//  HotspotDetailsController.swift
//  Serendipity
//
//  Created by Zachary Foster on 5/31/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//

import UIKit
import MapKit

class HotspotDetailsController: UIViewController {
    var hotspot: Hotspot?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var latlongLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = hotspot?.title
        aboutLabel.text = hotspot?.about
        latlongLabel.text = String(format: "%f, %f", (hotspot?.latitude)!, (hotspot?.longitude)!)
        
        configMap()
    }
    
    private func configMap() {
//        let location = CLLocation(latitude: Double((hotspot?.latitude)!), longitude: Double((hotspot?.longitude)!))
        let location = CLLocation(latitude: 21.282778, longitude: -157.829444)
        
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
