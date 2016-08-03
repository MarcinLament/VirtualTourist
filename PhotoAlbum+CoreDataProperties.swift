//
//  PhotoAlbum+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Marcin Lament on 30/07/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PhotoAlbum {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var photos: NSOrderedSet?

}
