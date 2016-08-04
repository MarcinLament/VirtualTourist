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
        
        if (photoAlbum.photos?.count > 0){
            for photo in photoAlbum.photos!{
                sharedContext.deleteObject(photo as! NSManagedObject)
            }
            
            CoreDataStackManager.sharedInstance().saveContext()
            self.delegate?.DownloadManagerDidModifiedData()
        }
        
        let url = "\(FlickrConstants.Endpoint)?method=\(FlickrConstants.Method)&"
            + "api_key=\(FlickrConstants.ApiKey)&lat=\(Double(photoAlbum.latitude!))&lon=\(Double(photoAlbum.longitude!))&extras=url_q&"
            + "per_page=\(FlickrConstants.PerPage)&page=\(photoAlbum.nextCollectionNumber)&format=json&nojsoncallback=1"
        
        FlickrClient.sharedInstance().taskForGETMethod(url, httpBody: nil, headers: nil) { (result, error) in
            
            if error != nil {
                photoAlbum.isDownloading = false
                self.delegate?.DownloadManagerError(error!)
            } else {
                
                let json = result as? [ String : AnyObject ]
                
                let stat = json!["stat"] as! String
                if(stat == "fail"){
                    photoAlbum.isDownloading = false
                    
                    let serverError = json!["message"] as! String
                    let userInfo = [NSLocalizedDescriptionKey : "Server error: \(serverError)"]
                    self.delegate?.DownloadManagerError(NSError(domain: "downloadPhotos", code: 1, userInfo: userInfo))
                }else{
                    let photos = json![ "photos" ] as! [ String : AnyObject ]
                    let pages = photos["pages"] as! Int
                    let photoArray = photos[ "photo" ] as! [[ String : AnyObject ]]
                    
                    dispatch_async( dispatch_get_main_queue() ){
                        for photoInfo in photoArray
                        {
                            _ = Photo(
                                name: (photoInfo["title"] as? String)!,
                                webUrl: (photoInfo["url_q"] as? String)!,
                                photoAlbum: photoAlbum,
                                context: self.sharedContext
                            )
                        }
                        
                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                    
                    //Flickr has limit of 4000 images otherwise it returns duplicates
                    photoAlbum.nextCollectionNumber = Int(arc4random_uniform(UInt32(min(199, pages))) + 1)
                    photoAlbum.isDownloading = false
                    
                    self.delegate?.DownloadManagerDidModifiedData()
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
    func DownloadManagerError(error: NSError)
}