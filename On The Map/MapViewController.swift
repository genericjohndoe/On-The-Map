//
//  MapViewController.swift
//  On The Map
//
//  Created by joel johnson on 8/8/17.
//  Copyright © 2017 joel johnson. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate{
    
    var annotations = [MKPointAnnotation]()
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMap()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let mediaLink = view.annotation?.subtitle! {
                if app.canOpenURL(URL(string: mediaLink)!){
                    app.openURL(URL(string: mediaLink)!)
                } else {
                    UdacityNetworkingMethods.sharedInstance().showError(self, "Invalid Link")
                }
            }
        }
    }
    
    func initMap(){
        map.removeAnnotations(annotations)
        annotations = [MKPointAnnotation]()
        
        for student in Student.studentArray {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: student.lat, longitude: student.long)
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            annotations.append(annotation)
        }
        map.addAnnotations(annotations)
    }
    
    
    @IBAction func logout(_ sender: Any) {
        UdacityNetworkingMethods.sharedInstance().logout(){
            (success, error) in
            if success {
                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            } else {
                UdacityNetworkingMethods.sharedInstance().showErrorOnMain(self, error)
            }
        }
    }

}
