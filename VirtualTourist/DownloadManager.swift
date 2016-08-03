//
//  DownloadManager.swift
//  VirtualTourist
//
//  Created by Marcin Lament on 02/08/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DownloadManager{
    
    var delegate: DownloadPhotosDelegate?
    
    class func sharedInstance() -> DownloadManager {
        struct Static {
            static let instance = DownloadManager()
        }
        
        return Static.instance
    }
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func downloadPhotos(photoAlbum: PhotoAlbum) -> Void{
        
        photoAlbum.isDownloading = true
        
        //remove any existing photos
        if (photoAlbum.photos?.count > 0){
            for photo in photoAlbum.photos!{
                sharedContext.deleteObject(photo as! NSManagedObject)
            }
            
            CoreDataStackManager.sharedInstance().saveContext()
            if(self.delegate != nil){
                self.delegate?.DownloadManagerDidModifiedData()
            }
        }
        
        print("Starting new download, current items count: \(photoAlbum.photos?.count)")
        
        let url = "\(FlickrConstants.Endpoint)?method=\(FlickrConstants.Method)&"
            + "api_key=\(FlickrConstants.ApiKey)&lat=\(Double(photoAlbum.latitude!))&lon=\(Double(photoAlbum.longitude!))&extras=url_q&"
            + "per_page=\(FlickrConstants.PerPage)&page=\(photoAlbum.collectionNumber)&format=json&nojsoncallback=1"
        
        print("URL: " + url)
        
        FlickrClient.sharedInstance().taskForGETMethod(url, httpBody: nil, headers: nil) { (result, error) in
            
            if error != nil {
                photoAlbum.isDownloading = false
                print("Error:")
            } else {
                
                let json = result as? [ String : AnyObject ]
                
                let stat = json!["stat"] as! String
                if(stat == "fail"){
                    photoAlbum.isDownloading = false
                    print("Error: " + (json!["message"] as! String))
                }else{
                    print("downloaded list of photos, started parsing the objects...")
                    let photos = json![ "photos" ] as! [ String : AnyObject ]
                    let photoArray = photos[ "photo" ] as! [[ String : AnyObject ]]
                    
                    for photoInfo in photoArray
                    {
                        _ = Photo(
                            name: (photoInfo["title"] as? String)!,
                            webUrl: (photoInfo["url_q"] as? String)!,
                            photoAlbum: photoAlbum,
                            context: self.sharedContext
                        )
                    }
                    
                    photoAlbum.collectionNumber += 1
                    
                    CoreDataStackManager.sharedInstance().saveContext()
                    
                    photoAlbum.isDownloading = false
                    print("album is now ready...")
                    if(self.delegate != nil){
                        self.delegate?.DownloadManagerDidModifiedData()
                    }
                }
            }
        }
    }
    
    func downloadImage(photo: Photo, completionHandlerForDownloadImage: (resultData: NSData!, error: NSError?) -> Void){
        photo.isDownloading = true
        let url = NSURL(string: photo.webUrl!)
        FlickrClient.sharedInstance().taskForImage(url!) { (imageData, imageError) in
            photo.image = imageData
            photo.isDownloading = false
            completionHandlerForDownloadImage(resultData: imageData, error: nil)
        }
    }
}

protocol DownloadPhotosDelegate {
    func DownloadManagerDidModifiedData()
}