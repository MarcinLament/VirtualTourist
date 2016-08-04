//
//  PhotoAlbum.swift
//  VirtualTourist
//
//  Created by Marcin Lament on 30/07/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class PhotoAlbum: NSManagedObject, MKAnnotation {

    var isDownloading: Bool = false
    var collectionNumber: Int = 1
    
    var coordinate: CLLocationCoordinate2D
    {
        return CLLocationCoordinate2D(
            latitude: Double(latitude!),
            longitude: Double(longitude!)
        )
    }
    
    convenience init(mapCoordinates: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("PhotoAlbum", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.latitude = mapCoordinates.latitude
            self.longitude = mapCoordinates.longitude
        }else{
            fatalError("Unable to find Entity name!")
        }
    }
    
    class func fetchAllPhotoAlbums( completionHandler: ( fetchError: NSErrorPointer, fetchedPhotoAlbums: [ PhotoAlbum ]? ) -> Void )
    {
        let fetchError: NSErrorPointer = nil
        let photoAlbumsFetchRequest = NSFetchRequest( entityName: "PhotoAlbum" )
        
        let photoAlbums: [PhotoAlbum]?
        do{
            photoAlbums = try CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(photoAlbumsFetchRequest) as? [ PhotoAlbum ]
        }catch{
            completionHandler(fetchError: fetchError, fetchedPhotoAlbums: nil)
            return
        }
        
        return ( photoAlbums!.count > 0 ) ?
            completionHandler( fetchError: nil, fetchedPhotoAlbums: photoAlbums ) :
            completionHandler( fetchError: nil, fetchedPhotoAlbums: nil )
    }
}
