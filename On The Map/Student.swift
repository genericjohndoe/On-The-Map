//
//  Student.swift
//  On The Map
//
//  Created by joel johnson on 8/11/17.
//  Copyright © 2017 joel johnson. All rights reserved.
//

import Foundation


struct Student{
    
    let firstName: String
    let lastName: String
    let mediaURL: String
    let lat: Double
    let long: Double
    let objectId: String
    let uniqueKey: String
    static var studentArray : [Student] = []
    
    init?(dictionary: [String:Any]) {
        guard let firstName = dictionary["firstName"] as? String,
            let lastName = dictionary["lastName"] as? String,
            let mediaURL = dictionary["mediaURL"] as? String,
            let lat = dictionary["latitude"] as? Double,
            let long = dictionary["longitude"] as? Double,
            let objectId = dictionary["objectId"] as? String,
            let uniqueKey = dictionary["uniqueKey"] as? String else {
                return nil
        }
        self.firstName = firstName
        self.lastName = lastName
        self.mediaURL = mediaURL
        self.lat = lat
        self.long = long
        self.objectId = objectId
        self.uniqueKey = uniqueKey
    }
    
    static func setStudentArray(_ results: [[String:Any]]) -> [Student] {
        var studentList = [Student]()
        
        for result in results {
            if let student = Student(dictionary: result) {
                studentList.append(student)
            }
        }
        return studentList
    }
    
}
