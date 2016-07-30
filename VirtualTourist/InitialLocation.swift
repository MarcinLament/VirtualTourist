//
//  InitialLocation.swift
//  VirtualTourist
//
//  Created by Marcin Lament on 29/07/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation

class InitialLocation: NSObject, NSCoding{
    
    var latitude: Double!
    var longitude: Double!
    var latitudeDelta: Double!
    var longitudeDelta: Double!
    
    init(latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let latitude = aDecoder.decodeDoubleForKey("latitude")
        let longitude = aDecoder.decodeDoubleForKey("longitude")
        let latitudeDelta = aDecoder.decodeDoubleForKey("latitudeDelta")
        let longitudeDelta = aDecoder.decodeDoubleForKey("longitudeDelta")
        self.init(latitude: latitude, longitude: longitude, latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(latitude, forKey: "latitude")
        aCoder.encodeDouble(longitude, forKey: "longitude")
        aCoder.encodeDouble(latitudeDelta, forKey: "latitudeDelta")
        aCoder.encodeDouble(longitudeDelta, forKey: "longitudeDelta")
    }
}