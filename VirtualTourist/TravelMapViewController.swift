//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Marcin Lament on 29/07/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var selectedPhotoAlbum: PhotoAlbum?
    
    lazy var sharedContext: NSManagedObjectContext = {
            return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
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
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TravelMapViewController.addAnnotation(_:)))
        self.view.addGestureRecognizer(gestureRecognizer)
        
        PhotoAlbum.fetchAllPhotoAlbums { (fetchError, fetchedPhotoAlbums) in
            if fetchError != nil{
                self.showAlert("Error", message: "Error fetching data from local storage", completion: nil)
            }else{
                if(fetchedPhotoAlbums?.count > 0){
                    self.mapView.addAnnotations(fetchedPhotoAlbums!)
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        mapView.region = newMapRegion!
        mapView.setCenterCoordinate(
            newMapRegion!.center,
            animated: true
        )
        
        self.navigationController?.navigationBarHidden = true
    }
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        
        let recognizer = self.view.gestureRecognizers?.first as! UILongPressGestureRecognizer
        switch recognizer.state{
        case .Began:
            let touchPoint = gestureRecognizer.locationInView(mapView)
            let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            let photoAlbum = PhotoAlbum(mapCoordinates: newCoordinates, context: sharedContext)
            
            dropPin(photoAlbum)
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            return
        default:
            return
        }
    }
    
    func dropPin(photoAlbum: PhotoAlbum){
        mapView.addAnnotation(photoAlbum)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        selectedPhotoAlbum = view.annotation as? PhotoAlbum
        performSegueWithIdentifier("photoAlbumSegue", sender: nil)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "photoAlbumSegue"{
            if let destinationVC = segue.destinationViewController as? PhotoAlbumViewController {
                destinationVC.photoAlbum = selectedPhotoAlbum
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool){
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
}

