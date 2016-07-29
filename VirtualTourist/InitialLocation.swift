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
    var zoomLevel: Double!
    
    init(latitude: Double, longitude: Double, zoomLevel: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.zoomLevel = zoomLevel
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let latitude = aDecoder.decodeDoubleForKey("latitude")
        let longitude = aDecoder.decodeDoubleForKey("longitude")
        let zoomLevel = aDecoder.decodeDoubleForKey("zoomLevel")
        self.init(latitude: latitude, longitude: longitude, zoomLevel: zoomLevel)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(latitude, forKey: "latitude")
        aCoder.encodeDouble(longitude, forKey: "longitude")
        aCoder.encodeDouble(zoomLevel, forKey: "zoomLevel")
    }
}