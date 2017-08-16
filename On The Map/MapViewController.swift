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
                if UIApplication.shared.canOpenURL(URL(string: mediaLink)!){
                    app.openURL(URL(string: mediaLink)!)
                } else {
                    let AlertController = UIAlertController(title: "", message: "Invalid Link", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel) {
                        action in AlertController.dismiss(animated: true, completion: nil)
                    }
                    AlertController.addAction(cancelAction)
                    present(AlertController, animated: true, completion: nil)
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

}
