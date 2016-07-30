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
    
    var newMapRegion: MKCoordinateRegion?
    let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 51.5074,
            longitude: 0.1278
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 15.0,
            longitudeDelta: 15.0
        )
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMap()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        gestureRecognizer.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        mapView.region = newMapRegion!
        mapView.setCenterCoordinate(
            newMapRegion!.center,
            animated: true
        )
    }
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        
        mapView.addAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("selected")
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMap()
    }
    
    func loadMap(){
        let mapLocation = appDelegate.mapLocation
        if(mapLocation != nil){
            newMapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: mapLocation![ "latitude" ]!,
                    longitude: mapLocation![ "longitude" ]!
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: mapLocation![ "latitudeDelta" ]!,
                    longitudeDelta: mapLocation![ "longitudeDelta" ]!
                )
            )
        }else{
            newMapRegion = defaultRegion
        }
        
        mapView.delegate = self;
    }
    
    func saveMap(){
        var mapDictionary = [ String : CLLocationDegrees ]()
        mapDictionary.updateValue( mapView.region.center.latitude, forKey: "latitude" )
        mapDictionary.updateValue( mapView.region.center.longitude, forKey: "longitude" )
        mapDictionary.updateValue( mapView.region.span.latitudeDelta, forKey: "latitudeDelta" )
        mapDictionary.updateValue( mapView.region.span.longitudeDelta, forKey: "longitudeDelta" )
        appDelegate.mapLocation = mapDictionary
    }
}

