//
//  ModifyStudentViewController.swift
//  On The Map
//
//  Created by joel johnson on 8/16/17.
//  Copyright © 2017 joel johnson. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class ModifyStudentViewController: UIViewController{
 
    
    @IBOutlet weak var media: UITextField!
    @IBOutlet weak var location: UITextField!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBAction func submitStudent(_ sender: Any) {
        if !media.text!.isEmpty || !location.text!.isEmpty {
            CLGeocoder().geocodeAddressString(location.text!) {
                (placemarks, error) in
                
                guard (error == nil) else {
                    UdacityNetworkingMethods.sharedInstance().showErrorOnMain(self, "Geocoding Error")
                    return
                }
                print(((placemarks?.count)!))
                if (placemarks?.count)! > 0 {
                    let placemark = placemarks?[0]
                    let location = placemark?.location
                    let coordinate = location?.coordinate
                    
                    var dictionary: [String: Any] =
                    ["firstName": self.appDelegate.firstName,
                     "lastName": self.appDelegate.lastName,
                     "mediaURL": self.media.text!,
                     "latitude": coordinate!.latitude,
                     "longitude": coordinate!.longitude,
                     "uniqueKey": self.appDelegate.userID]
                    
                    for (key, value) in dictionary {
                        print("Dictionary key \(key) -  Dictionary value \(value)")
                    }
                    ParseObject.sharedInstance().addStudentLocation(dictionary, location: self.location.text!){
                        (success, error) in
                        if success {
                            print("student added")
                            ParseObject.sharedInstance().getStudentLocations(){
                                (success, error) in
                                DispatchQueue.main.async{
                                self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                }
            }
        }
    }
    }
}
