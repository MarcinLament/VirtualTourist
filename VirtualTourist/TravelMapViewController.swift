//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Marcin Lament on 29/07/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import UIKit
import MapKit

class TravelMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(appDelegate.currentMapLocation != nil){
            print("Show saved location: " + String(appDelegate.currentMapLocation!))
            centerMapOnLocation(appDelegate.currentMapLocation!)
        }else{
            print("No saved location")
        }
        
        mapView.delegate = self;
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let zoomLevel = log2(360 * (Double(mapView.frame.size.width/256) / mapView.region.span.longitudeDelta)) + 1
        print("Zoom level: " + String(zoomLevel))
        appDelegate.currentMapLocation = InitialLocation(latitude: mapView.centerCoordinate.latitude, longitude:mapView.centerCoordinate.longitude, zoomLevel: zoomLevel)
    }
    
    func centerMapOnLocation(initialLocation: InitialLocation) {
        let centerCoordinate = CLLocationCoordinate2DMake(initialLocation.latitude, initialLocation.longitude)
        let span = MKCoordinateSpanMake(0, 360 / pow(2, Double(initialLocation.zoomLevel)) * Double(mapView.frame.size.width) / 256)
        mapView.setRegion(MKCoordinateRegionMake(centerCoordinate, span), animated: false)
    }
}

