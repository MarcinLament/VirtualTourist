//
//  RestClient.swift
//  OnTheMap
//
//  Created by Marcin Lament on 04/06/2016.
//  Copyright © 2016 Marcin Lament. All rights reserved.
//

import Foundation

class FlickrClient : NSObject {

    var session = NSURLSession.sharedSession()
    
    var userId: String? = nil
    var user: NSDictionary? = nil
    
    func taskForGETMethod(){
        
    }
    
    func taskForGETMethod(url: String, httpBody: String?, headers: [String: String]?, completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "GET"
        
        if (httpBody != nil) {
            request.HTTPBody = httpBody!.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        if (headers != nil) {
            for (key, value) in headers! {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String, statusCode: Int) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForPOSTMethod", code: statusCode, userInfo: userInfo))
            }
        
            guard (error == nil) else {
                if(error?.code == -1009){
                    sendError("Connection problem. Please try again", statusCode: 1)
                }else{
                    sendError("There was an error with your request: \(error)", statusCode: 1)
                }
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)?.statusCode
            if(statusCode >= 300 && statusCode <= 499){
                sendError("Server error. Please try again later", statusCode: statusCode!)
                return
            }else if(statusCode < 200 && statusCode > 299){
                sendError("Problem contacting server. Please try again later.", statusCode: statusCode!)
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!", statusCode: 1)
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        task.resume()
    }
    
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            completionHandlerForConvertData(result: json, error: nil)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Cannot parse json response"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
        }
    }
    
    func taskForImage(imageURL: NSURL, completionHandler: ( imageData: NSData?, imageError: NSError? ) -> Void){
        
        let imageTask = session.dataTaskWithURL( imageURL )
        {
            imageData, imageResponse, imageError in
            
            if imageError != nil
            {
                completionHandler(
                    imageData: nil,
                    imageError: imageError
                )
            }
            else
            {
                completionHandler(
                    imageData: imageData,
                    imageError: nil
                )
            }
        }
        imageTask.resume()
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}