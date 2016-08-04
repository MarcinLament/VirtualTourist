//
//  Photo.swift
//  VirtualTourist
//
//  Created by Marcin Lament on 30/07/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

    var isDownloading: Bool = false
    
    convenience init(name: String, webUrl: String, photoAlbum: PhotoAlbum, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.name = name
            self.webUrl = webUrl
            self.photoAlbum = photoAlbum
        }else{
            fatalError("Unable to find Entity name!")
        }
    }
}
