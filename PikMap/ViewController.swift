//
//  ViewController.swift
//  PikMap
//
//  Created by John Leonardo on 8/29/16.
//  Copyright © 2016 John Leonardo. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var pikPop: UIView!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var mapCentered = false
    var geoFire: GeoFire!
    var geoFireReference: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        geoFireReference = FIRDatabase.database().reference()
        geoFire = GeoFire(firebaseRef: geoFireReference)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if !mapCentered {
                centerMapOnLocation(location: loc)
                mapCentered = true
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationImg: MKAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self) {
            annotationImg = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationImg?.image = UIImage(named: "add_feeling_btn.png")
        }
        
        return annotationImg
    }
    
    func dropPik(forLocation location:CLLocation, image: UIImage) {
        //todo: select image to assign to pin
    }
    
    @IBAction func postPik(_ sender: AnyObject) {
        pikPop.isHidden = false
    }

    @IBAction func closePikPop(_ sender: AnyObject) {
        pikPop.isHidden = true
    }

}








