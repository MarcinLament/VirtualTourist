//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Marcin Lament on 02/08/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var name: String?
    @NSManaged var webUrl: String?
    @NSManaged var image: NSData?
    @NSManaged var photoAlbum: PhotoAlbum?

}
