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
import MapKit

class ModifyStudentViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate{
 
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var media: UITextField!
    @IBOutlet weak var location: UITextField!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var coordinate = CLLocationCoordinate2D()
    var annotation = MKPointAnnotation()
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var submit: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        location.delegate = self
        map.delegate = self
        location.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        submit.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField,
                                reason: UITextFieldDidEndEditingReason){
        if reason == UITextFieldDidEndEditingReason.committed {
            indicator.startAnimating()
            geocodeAddress(){
                (success) in
                if success {
                    self.indicator.stopAnimating()
                    self.submit.isEnabled = true
                }
            }
        }
    }
    func geocodeAddress(completionHandler: @escaping (_ success: Bool) -> Void){
        if !location.text!.isEmpty {
        CLGeocoder().geocodeAddressString(location.text!) {
                (placemarks, error) in
    
                guard (error == nil) else {
                    UdacityNetworkingMethods.sharedInstance().showErrorOnMain(self, "Geocoding Error")
                    completionHandler(true)
                    return
                }
    
            if (placemarks?.count)! > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                self.coordinate = (location?.coordinate)!
            
                self.map.removeAnnotation(self.annotation)
                self.annotation = MKPointAnnotation()
                self.annotation.coordinate = CLLocationCoordinate2D(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
                self.annotation.title = "\(self.appDelegate.firstName) \(self.appDelegate.lastName)"
                self.map.addAnnotation(self.annotation)
                let region = MKCoordinateRegion(center: self.coordinate, span: MKCoordinateSpan(latitudeDelta: 20,longitudeDelta: 20))
                self.map.setRegion(region, animated: true)
                completionHandler(true)
            }
        }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    @IBAction func submitStudent(_ sender: Any) {
        if !media.text!.isEmpty {
            let dictionary: [String: Any] =
            ["firstName": self.appDelegate.firstName,
            "lastName": self.appDelegate.lastName,
            "mediaURL": self.media.text!,
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "uniqueKey": self.appDelegate.userID,
            "objectId": self.appDelegate.objectId]
                    
            if (self.appDelegate.objectId == ""){
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
                    }else{
                        UdacityNetworkingMethods.sharedInstance().showErrorOnMain(self, error!)
                        }
                    }
                }
            else{
                    ParseObject.sharedInstance().updateStudentLocation(dictionary, location: self.location.text!){
                        (success, error) in
                        if success {
                            print("student updated")
                            ParseObject.sharedInstance().getStudentLocations(){
                                (success, error) in
                                DispatchQueue.main.async{
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        } else {
                            UdacityNetworkingMethods.sharedInstance().showErrorOnMain(self, error!)
                        }
                    }
                }
        } else {
            UdacityNetworkingMethods.sharedInstance().showErrorOnMain(self, "Please add media url")
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        media.text = ""
        location.text = ""
        dismiss(animated: true, completion: nil)
    }
    
}
