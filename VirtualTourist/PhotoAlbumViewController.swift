//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Marcin Lament on 31/07/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, DownloadPhotosDelegate{
    
    internal var photoAlbum: PhotoAlbum?
    
    let numberOfItemsPerRow: Int = 3
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadNewCollectionButton: UIButton!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var mainActivityView: UIActivityIndicatorView!
    
    enum ButtonState{
        case LoadNew
        case Remove
    }
    
    override func viewDidLoad() {
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = self
        collectionView.delegate = self
        
        DownloadManager.sharedInstance().delegate = self
        
        toggleButton(.LoadNew, selectedItemsCount: 0)
        mainActivityView.transform = CGAffineTransformMakeScale(2.5, 2.5);
    }
    
    override func viewWillAppear(animated: Bool) {
        showPhotoAlbumLocation()
        
        if(photoAlbum?.photos?.count > 0){
            print("There are some downloaded photos already")
        }else{
            print("No photos, started downloading...")
            downloadPhotosForLocation()
        }
    }
    
    @IBAction func loadNewCollection(sender: AnyObject) {
        downloadPhotosForLocation()
    }
    
    @IBAction func removeSelectedItems(sender: AnyObject) {
        let selectedIndexPaths = collectionView.indexPathsForSelectedItems()
        for indexPath in selectedIndexPaths!{
            let photo = photoAlbum!.photos![indexPath.item]
            CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject( photo as! NSManagedObject )
        }
        CoreDataStackManager.sharedInstance().saveContext()
        collectionView.deleteItemsAtIndexPaths(selectedIndexPaths!)
        toggleButton(.LoadNew, selectedItemsCount: 0)
    }
    
    func downloadPhotosForLocation(){
        self.infoTextView.hidden = true
        self.mainActivityView.startAnimating()
        loadNewCollectionButton.userInteractionEnabled = false
        DownloadManager.sharedInstance().downloadPhotos(photoAlbum!)
    }
    
    func showPhotoAlbumLocation(){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance((photoAlbum?.coordinate)!, 20000, 20000)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(photoAlbum!)
    }
    
    func numberOfSectionsInCollectionView( collectionView: UICollectionView ) -> Int{
        return 1
    }
    
    func collectionView(collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int{
        let count = (photoAlbum!.photos?.count)!
        print("available photos: \(count)")
        return count
    }
    
    func collectionView(collectionView: UICollectionView,didSelectItemAtIndexPath indexPath: NSIndexPath){
        processCellSelection(indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        processCellSelection(indexPath)
    }
    
    func processCellSelection(indexPath: NSIndexPath){
        let cell = collectionView.cellForItemAtIndexPath( indexPath ) as! PhotoAlbumCell
        
        // toggle button if necessary
        let count = collectionView.indexPathsForSelectedItems()!.count
        if (count > 0){
            toggleButton(.Remove, selectedItemsCount: count)
        }else{
            toggleButton(.LoadNew, selectedItemsCount: count)
        }
        
        // set cell selected state
        updateCellSelectionAppearance(cell)
    }
    
    func updateCellSelectionAppearance(cell: PhotoAlbumCell){
        cell.alpha = cell.selected == true ? 0.35 : 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoAlbumCell",forIndexPath: indexPath) as! PhotoAlbumCell
        let photo = photoAlbum?.photos![indexPath.item] as! Photo
        
        cell.activityIndicator.startAnimating()
        cell.photoImageView.image = nil
        
        //check if there is an image in core data
        if(photo.image != nil){
            print("loading image from core data")
            let cachedImage = UIImage(data: photo.image!)
            cell.photoImageView.image = cachedImage
            cell.activityIndicator.stopAnimating()
        }
        //there is no image in core data so download it from the web
        else if(photo.webUrl != nil && !photo.isDownloading){
            print("no image, start downloading the image")
            photo.isDownloading = true
            DownloadManager.sharedInstance().downloadImage(photo, completionHandlerForDownloadImage: { (resultData, error) in
                dispatch_async( dispatch_get_main_queue() ){
                    photo.image = resultData
                    CoreDataStackManager.sharedInstance().saveContext()
                    print("downloaded image... reloading the data")
                    photo.isDownloading = false
                    collectionView.reloadData()
                }
            })
        }else{
            print("image is downloading...")
        }
        
        updateCellSelectionAppearance(cell)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
        return CGSize(width: size, height: size)
    }
    
    func DownloadManagerDidModifiedData(){
        dispatch_async( dispatch_get_main_queue() ){
            self.loadNewCollectionButton.userInteractionEnabled = true
            self.collectionView.reloadData()
            
            
            if(self.photoAlbum?.photos?.count == 0){
                if(self.photoAlbum!.isDownloading){
                    self.infoTextView.hidden = true
                    self.mainActivityView.startAnimating()
                }else{
                    self.mainActivityView.stopAnimating()
                    self.infoTextView.hidden = false
                }
            }else{
                self.infoTextView.hidden = true
                self.mainActivityView.stopAnimating()
            }
        }
    }
    
    func toggleButton(buttonState: ButtonState, selectedItemsCount: Int){
        
        switch buttonState {
        case .LoadNew:
            loadNewCollectionButton.setTitle("Load New Collection", forState: UIControlState.Normal)
            loadNewCollectionButton.removeTarget(
                self,
                action: #selector(PhotoAlbumViewController.removeSelectedItems(_:)),
                forControlEvents: .TouchUpInside
            )
            loadNewCollectionButton.addTarget(
                self,
                action: #selector(PhotoAlbumViewController.loadNewCollection(_:)),
                forControlEvents: .TouchUpInside
            )
            
        case .Remove:
            loadNewCollectionButton.removeTarget(
                self,
                action: #selector(PhotoAlbumViewController.loadNewCollection(_:)),
                forControlEvents: .TouchUpInside
            )
            loadNewCollectionButton.addTarget(
                self,
                action: #selector(PhotoAlbumViewController.removeSelectedItems(_:)),
                forControlEvents: .TouchUpInside
            )
            
            loadNewCollectionButton.setTitle("Remove Selected Items (\(selectedItemsCount))", forState: UIControlState.Normal)
        }
        
    }
}