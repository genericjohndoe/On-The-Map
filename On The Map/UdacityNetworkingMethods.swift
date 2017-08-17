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
    
    func login(_ email: String,_ password: String,_ vc: UIViewController, completionHandlerForLogin: @escaping (_ success: Bool, _ error: String?) -> Void){
        
        
        print("\nIn UdacityNetworkingMethods.login():")
        print("\temail: \(email)")
        print("\tpassword: \(password)")
        
        getSessionID(email, password){ (success, error, result) in
            if success {
                print("Session ID recieved")
                self.getUserInfo( result!){ (success, error) in
                    if success {
                        print("User data received")
                        completionHandlerForLogin(success, nil)
                    } else {
                        self.showErrorOnMain(vc, error!)
                    }
                }
            } else {
                self.showErrorOnMain(vc, error!)
            }
        }
    }
    
    func getSessionID(_ email: String,_ password: String, completionHandlerForSession: @escaping (_ success: Bool, _ error: String?, _ result: String?) -> Void){
        
        
        print("\nIn UdacityNetworkingMethods.getSessionID():")
        print("\temail: \(email)")
        print("\tpassword: \(password)")
        
        let httpBodyString = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        print("\n\thttpBodyString: \(httpBodyString)")
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBodyString.data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                completionHandlerForSession(false, "Network Connection Is Offline!",nil)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForSession(false, "Invalid Email Or Password!",nil)
                return
            }
            
            guard let data = data else {
                completionHandlerForSession(false, "Network Connection Is Offline!",nil)
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            var parsedResult:  AnyObject! = nil
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
            } catch {
                completionHandlerForSession(false, "No serialization",nil)
                return
            }
            
            guard let dictionary = parsedResult as? [String: Any] else {
                completionHandlerForSession(false, "Network Connection Is Offline!",nil)
                return
            }
            
            guard let account = dictionary["account"] as? [String:Any] else {
                completionHandlerForSession(false, "Network Connection Is Offline!",nil)
                return
            }
            
            //Utilize Data
            
            guard let userID = account["key"] as? String else {
                completionHandlerForSession(false, "Network Connection Is Offline!",nil)
                return
            }
            
            self.appDelegate.userID = userID
            completionHandlerForSession(true, nil, userID)
        }
        task.resume()
    }
    
    func getUserInfo(_ userId: String, completetionHandlerForUserId: @escaping (_ success: Bool, _ error: String?) -> Void){
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.udacity.com/api/users/\(userId)")! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                completetionHandlerForUserId(false,"There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completetionHandlerForUserId(false,"Your Request Returned A Status Code Other Than 2xx!")
                return
            }
            
            guard let data = data else {
                completetionHandlerForUserId(false,"No Data Was Returned By The Request!")
                return
            }
            
            //Parse Data
            
            let newData = data.subdata(in: Range(uncheckedBounds: (5, data.count)))
            
            let parsedResult: Any!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments)
            } catch {
                completetionHandlerForUserId(false, "Could Not Parse The Data As JSON: '\(data)'")
                return
            }
            
            guard let dictionary = parsedResult as? [String: Any] else {
                completetionHandlerForUserId(false, "Cannot Parse")
                return
            }
            
            
            guard let user = dictionary["user"] as? [String: Any] else {
                completetionHandlerForUserId(false, "Cannot Find Key 'user' In \(parsedResult)")
                return
            }
            
            guard let lastName = user["last_name"] as? String else {
                completetionHandlerForUserId(false, "Cannot Find Key 'last_name' In \(user)")
                return
            }
            
            //Utilize Data
            
            guard let firstName = user["first_name"] as? String else {
                completetionHandlerForUserId(false, "Cannot Find Key 'first_name' In \(user)")
                return
            }
            self.appDelegate.lastName = lastName
            self.appDelegate.firstName = firstName
            completetionHandlerForUserId(true, nil)
        }
        task.resume()
    }
    
    func logout(completetionHandlerForLogout: @escaping (_ success: Bool,_ error: String) -> Void){
        let request = NSMutableURLRequest(url: NSURL(string: "https://www.udacity.com/api/session")! as URL)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                completetionHandlerForLogout(false, "There Was An Error With Your Request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completetionHandlerForLogout(false, "Your Request Returned A Status Code Other Than 2xx!")
                return
            }
            
            guard data != nil else {
                completetionHandlerForLogout(false, "No Data Was Returned By The Request!")
                return
            }
        }
        completetionHandlerForLogout(true, "")
        task.resume()
    }
    
    func showError(_ vc: UIViewController,_ error: String){
        let AlertController = UIAlertController(title: "", message: error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel) {
            action in AlertController.dismiss(animated: true, completion: nil)
        }
        AlertController.addAction(cancelAction)
        vc.present(AlertController, animated: true, completion: nil)
    }
    
    func showErrorOnMain(_ vc: UIViewController,_ error: String){
        DispatchQueue.main.async{
            let AlertController = UIAlertController(title: "", message: error, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel) {
                action in AlertController.dismiss(animated: true, completion: nil)
            }
            AlertController.addAction(cancelAction)
            vc.present(AlertController, animated: true, completion: nil)
        }
    }
}
