//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Marcin Lament on 29/07/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import UIKit
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
//    var currentMapLocation: InitialLocation?
    var mapLocation: [ String : CLLocationDegrees ]?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        mapLocation = getSavedMapLocation()
        
        
        return true
    }
    
    func getSavedMapLocation() -> [ String : CLLocationDegrees ]?{
    
        
        return NSUserDefaults.standardUserDefaults().dictionaryForKey( "mapLocation" ) as? [ String : CLLocationDegrees ]
//        {
//            
//        }
//        
//        if let savedLocation = defaults.objectForKey("initialLocation") as? NSData {
//            let initialLocation = NSKeyedUnarchiver.unarchiveObjectWithData(savedLocation) as? InitialLocation
//            print("L, lat: " + String(initialLocation!.latitude) + " | lon: " + String(initialLocation?.longitude) + " | latD: " + String(initialLocation!.latitudeDelta) + " | lonD: " + String(initialLocation!.longitudeDelta))
//            return initialLocation
//        }
//        
//        return nil;
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
        if(mapLocation == nil) {
            print("Nothing to save")
            return
        }
        
        NSUserDefaults.standardUserDefaults().setObject( mapLocation, forKey: "mapLocation" )
//        print("S, lat: " + String(currentMapLocation!.latitude) + " | lon: " + String(currentMapLocation?.longitude) + " | latD: " + String(currentMapLocation!.latitudeDelta) + " | lonD: " + String(currentMapLocation!.longitudeDelta))
//
//        let defaults = NSUserDefaults.standardUserDefaults()
//        
//        let savedData = NSKeyedArchiver.archivedDataWithRootObject(currentMapLocation!)
//        defaults.setObject(savedData, forKey: "initialLocation")
//        print("Save location")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

