//
//  ParseObject.swift
//  On The Map
//
//  Created by joel johnson on 8/11/17.
//  Copyright © 2017 joel johnson. All rights reserved.
//

import Foundation
import UIKit


class ParseObject: NSObject{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> ParseObject {
        struct Singleton {
            static var sharedInstance = ParseObject()
        }
        return Singleton.sharedInstance
    }
    
    //returns student locations
    func getStudentLocations(completionHandlerSLS: @escaping (_ success: Bool, _ error: String?) -> Void){
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt&limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                completionHandlerSLS(false,"There Was An Error With Your Request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerSLS(false,"Student locations could not be retrieved")
                return
            }
            
            guard let data = data else {
                completionHandlerSLS(false, "No Data Was Returned By The Request!")
                return
            }
            let parsedResult: Any!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                completionHandlerSLS(false,"Could Not Parse The Data As JSON: '\(data)'")
                return
            }
            
            if let results = parsedResult as? [String: Any] {
                if let resultSet = results["results"] as? [[String: Any]]{
                    Student.studentArray = Student.setStudentArray(resultSet)
                    completionHandlerSLS(true, nil)
                }
            } else {
                completionHandlerSLS(false, "error when converting student location data to app usable form")
            }
            
        }
        task.resume()
        }
    
    //returns single location for student
    func getSingleLocation(_ uniqueKey: String, completionHandlerSSL: @escaping (_ success: Bool, _ error: String?) -> Void){
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22\(uniqueKey)%22%3A%221234%22%7D"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                completionHandlerSSL(false, "There Was An Error With Your Request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerSSL(false, "Sorry, could not retrieve student location")
                return
            }
            
            guard let data = data else {
                completionHandlerSSL(false, "No Data Was Returned By The Request!")
                return
            }
            let parsedResult: Any!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                completionHandlerSSL(false, "Could Not Parse The Data As JSON: '\(data)'")
                return
            }
            
            if let results = parsedResult as? [String: Any] {
                if let resultSet = results["results"] as? [[String: Any]]{
                    Student.studentArray = Student.setStudentArray(resultSet)
                    completionHandlerSSL(true, nil)
                }
            } else {
                completionHandlerSSL(false, "error when converting student location data to app usable form")
            }
            
        }

        task.resume()
    }
    
    //add student location
    func addStudentLocation(_ newStudent: [String: Any], location: String, completionHandlerASL: @escaping (_ success: Bool, _ error: String?) -> Void){
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(newStudent["uniqueKey"]!)\", \"firstName\": \"\(newStudent["firstName"]!)\", \"lastName\": \"\(newStudent["lastName"]!)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(newStudent["mediaURL"]!)\",\"latitude\": \(newStudent["latitude"]!), \"longitude\": \(newStudent["longitude"]!)}".data(using: String.Encoding.utf8)
        print(request.url!)
        print(NSString(data: request.httpBody!, encoding: String.Encoding.utf8.rawValue)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                print("There Was An Error With Your Request: \(String(describing: error))")
                completionHandlerASL(false, "There Was An Error With Your Request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your Request Returned A Status Code Other Than 2xx!")
                completionHandlerASL(false, "Could not add student location")
                return
            }
            
            guard let data = data else {
                print("No Data Was Returned By The Request!")
                completionHandlerASL(false, "No Data Was Returned By The Request!")
                return
            }
            
            let parsedResult: Any!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                print("Could Not Parse The Data As JSON")
                completionHandlerASL(false, "Could Not Parse The Data As JSON: '\(data)'")
                return
            }
            
            guard let dictionary = parsedResult as? [String: Any] else {
                print("Cannot Parse")
                completionHandlerASL(false, "Cannot Parse")
                return
            }
            
            
            guard let id = dictionary["objectId"] as? String else {
                print("Cannot Find Key 'user' In \(parsedResult)")
                completionHandlerASL(false, "Cannot Find Key 'user' In \(parsedResult)")
                return
            }
            self.appDelegate.objectId = id
            print(id)
            completionHandlerASL(true, nil)
        }
        task.resume()
    }
    
    //update student location
    func updateStudentLocation(_ student: [String:Any], location: String, completionHandlerUSL: @escaping (_ success: Bool, _ error: String?) -> Void){
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(student["objectId"]!)"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(student["uniqueKey"]!)\", \"firstName\": \"\(student["firstName"]!)\", \"lastName\": \"\(student["lastName"]!)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(student["mediaURL"]!)\",\"latitude\": \(student["latitude"]!), \"longitude\": \(student["longitude"]!)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                completionHandlerUSL(false, "There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completionHandlerUSL(false, "Could not update student location")
                return
            }
            
            guard data != nil else {
                completionHandlerUSL(false, "No Data Was Returned By The Request!")
                return
            }
            completionHandlerUSL(true, nil)
        }
        task.resume()
    }
    }
