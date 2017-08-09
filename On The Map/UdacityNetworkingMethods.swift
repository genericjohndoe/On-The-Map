//
//  UdacityNetworkingMethods.swift
//  On The Map
//
//  Created by joel johnson on 8/7/17.
//  Copyright © 2017 joel johnson. All rights reserved.
//

import Foundation
import UIKit

class UdacityNetworkingMethods: NSObject{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> UdacityNetworkingMethods {
        struct Singleton {
            static var sharedInstance = UdacityNetworkingMethods()
        }
        return Singleton.sharedInstance
    }
    
    func login(_ email: String,_ password: String, completionHandlerForLogin: @escaping (_ success: Bool, _ error: String?) -> Void){
        getSessionID(email, password){ (success, error, result) in
            if success {
                print("Session ID recieved")
                self.getUserInfo( result!){ (success, error) in
                    if success {
                        print("User data received")
                        completionHandlerForLogin(success, nil)
                    }
                }
            }
        }
    }
    
    func getSessionID(_ email: String,_ password: String, completionHandlerForSession: @escaping (_ success: Bool, _ error: String?, _ result: String?) -> Void){
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            func handleError(error: String, errormsg: String) {
                print(error)
                _ = [NSLocalizedDescriptionKey: error]
                completionHandlerForSession(false, errormsg, nil)
            }
            
            guard (error == nil) else {
                handleError(error: "There was an error with your request: \(String(describing: error))", errormsg: "Network Connection Is Offline!")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                handleError(error: "Your request returned a status code other than 2xx!", errormsg: "Invalid Email Or Password!")
                return
            }
            
            guard let data = data else {
                handleError(error: "No Data Was Returned By The Request!", errormsg: "Network Connection Is Offline!")
                return
            }
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            var parsedResult:  AnyObject! = nil
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
            } catch {
                handleError(error: "Could not parse the data as JSON: '\(data)'", errormsg: "No serialization")
                return
            }
            
            guard let dictionary = parsedResult as? [String: Any] else {
                handleError(error: "Can't Parse Dictionary", errormsg: "Network Connection Is Offline!")
                return
            }
            
            guard let account = dictionary["account"] as? [String:Any] else {
                handleError(error: "Cannot Find Key 'Account' In \(parsedResult)", errormsg: "Network Connection Is Offline!")
                return
            }
            
            //Utilize Data
            
            guard let userID = account["key"] as? String else {
                handleError(error: "Cannot Find Key 'Key' In \(account)", errormsg: "Network Connection Is Offline!")
                return
            }
            
            self.appDelegate.userID = userID
            completionHandlerForSession(true, nil, userID)
        }
        task.resume()
    }
    
    func getUserInfo(_ userId: String, completetionHandlerForUserId: @escaping (_ success: Bool, _ error: NSError?) -> Void){
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.udacity.com/api/users/\(userId)")! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completetionHandlerForUserId(false, NSError(domain: "getUserData", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error: "There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your Request Returned A Status Code Other Than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError(error: "No Data Was Returned By The Request!")
                return
            }
            
            //Parse Data
            
            let newData = data.subdata(in: Range(uncheckedBounds: (5, data.count)))
            
            let parsedResult: Any!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments)
            } catch {
                sendError(error: "Could Not Parse The Data As JSON: '\(data)'")
                return
            }
            
            guard let dictionary = parsedResult as? [String: Any] else {
                sendError(error: "Cannot Parse")
                return
            }
            
            
            guard let user = dictionary["user"] as? [String: Any] else {
                sendError(error: "Cannot Find Key 'user' In \(parsedResult)")
                return
            }
            
            guard let lastName = user["last_name"] as? String else {
                sendError(error: "Cannot Find Key 'key' In \(user)")
                return
            }
            
            //Utilize Data
            
            guard let firstName = user["first_name"] as? String else {
                sendError(error: "Cannot Find Key 'key' In \(user)")
                return
            }
            self.appDelegate.lastName = lastName
            self.appDelegate.firstName = firstName
            completetionHandlerForUserId(true, nil)
        }
        task.resume()
    }
}
