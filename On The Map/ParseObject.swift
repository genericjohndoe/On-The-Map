//
//  ParseObject.swift
//  On The Map
//
//  Created by joel johnson on 8/11/17.
//  Copyright © 2017 joel johnson. All rights reserved.
//

import Foundation


class ParseObject: NSObject{
    
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
    func getStudentLocations(completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void){
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt&limit=100")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(error: String) {
                print(error)
                let errorSent = [NSLocalizedDescriptionKey: error]
                completionHandler(false, NSError(domain: "getStudentData", code: 1, userInfo: errorSent))
            }
            
            guard (error == nil) else {
                sendError(error: "There Was An Error With Your Request: \(String(describing: error))")
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
            let parsedResult: Any!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                sendError(error: "Could Not Parse The Data As JSON: '\(data)'")
                return
            }
            
            if let results = parsedResult as? [String: Any] {
                if let resultSet = results["results"] as? [[String: Any]]{
                    Student.studentArray = Student.setStudentArray(resultSet)
                    completionHandler(true, nil)
                }
            } else {
                sendError(error: "error when converting student location data to app usable form")
            }
            
        }
        task.resume()
        }
    
    //returns single location for student
    func getSingleLocation(_ uniqueKey: String, completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void){
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22\(uniqueKey)%22%3A%221234%22%7D"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(error: String) {
                print(error)
                let errorSent = [NSLocalizedDescriptionKey: error]
                completionHandler(false, NSError(domain: "getStudentData", code: 1, userInfo: errorSent))
            }
            
            guard (error == nil) else {
                sendError(error: "There Was An Error With Your Request: \(String(describing: error))")
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
            let parsedResult: Any!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                sendError(error: "Could Not Parse The Data As JSON: '\(data)'")
                return
            }
            
            if let results = parsedResult as? [String: Any] {
                if let resultSet = results["results"] as? [[String: Any]]{
                    Student.studentArray = Student.setStudentArray(resultSet)
                    completionHandler(true, nil)
                }
            } else {
                sendError(error: "error when converting student location data to app usable form")
            }
            
        }

        task.resume()
    }
    
    //add student location
    func addStudentLocation(_ newStudent: Student, location: String, completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void){
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(newStudent.uniqueKey)\", \"firstName\": \"\(newStudent.firstName)\", \"lastName\": \"\(newStudent.lastName)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(newStudent.mediaURL)\",\"latitude\": \(newStudent.lat), \"longitude\": \(newStudent.long)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            func sendError(error: String) {
                print(error)
                let errorSent = [NSLocalizedDescriptionKey: error]
                completionHandler(false, NSError(domain: "getStudentData", code: 1, userInfo: errorSent))
            }
            
            guard (error == nil) else {
                sendError(error: "There Was An Error With Your Request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your Request Returned A Status Code Other Than 2xx!")
                return
            }
            
            guard data != nil else {
                sendError(error: "No Data Was Returned By The Request!")
                return
            }
            completionHandler(true, nil)
        }
        task.resume()
    }
    
    //update student location
    func updateStudentLocation(_ student: Student, location: String, completionHandler: @escaping (_ success: Bool, _ error: NSError?) -> Void){
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(student.objectId)"
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.lat), \"longitude\": \(student.long)}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandler(false, NSError(domain: "updateStudentData", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error: "There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your Request Returned A Status Code Other Than 2xx!")
                return
            }
            
            guard data != nil else {
                sendError(error: "No Data Was Returned By The Request!")
                return
            }
            completionHandler(true, nil)
        }
        task.resume()
    }
    }
