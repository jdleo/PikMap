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
import FirebaseStorage
import Firebase

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var topBanner: UIView!
    @IBOutlet weak var imagePickerImg: UIImageView!
    @IBOutlet weak var dropPikBtn: UIButton!
    @IBOutlet weak var pikPop: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    var imageData: Any?
    
    let locationManager = CLLocationManager()
    var mapCentered = false
    var geoFire: GeoFire!
    var geoFireReference: FIRDatabaseReference!
    let imagePick = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        imagePick.delegate = self
        
        //auth user for uploading
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if error != nil {
                print(error)
                return
            } else {
                print("logged in")
                let anon = user!.isAnonymous
                let uid = user!.uid
            }
        })
        
        
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImg = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerImg.contentMode = .scaleAspectFit
            
            imagePickerImg.image = pickedImg
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func dropPik(forLocation location:CLLocation, withImage imageId: String) {
        
        
        geoFire.setLocation(location, forKey: imageId)
    }
    
    @IBAction func postPik(_ sender: AnyObject) {
        topBanner.isHidden = true
        pikPop.isHidden = false
        dropPikBtn.isHidden = true
    }

    @IBAction func closePikPop(_ sender: AnyObject) {
        topBanner.isHidden = false
        pikPop.isHidden = true
        dropPikBtn.isHidden = false
        imagePickerImg.image = UIImage(named: "photobtn.png")
    }
    @IBAction func imagePickerBtn(_ sender: AnyObject) {
        imagePick.allowsEditing = false
        imagePick.sourceType = .photoLibrary
        
        present(imagePick, animated: true, completion: nil)
    }
    
    @IBAction func uploadPik(_ sender: AnyObject) {
        if imagePickerImg.image != UIImage(named: "photobtn.png") {
            
            if let uploadData = UIImagePNGRepresentation(imagePickerImg.image!) {
                let iid = NSUUID().uuidString.lowercased()
                let imageRef = storageRef.child(iid)
                imageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error)
                        return
                    } else {
                        print(metadata)
                    }
                })
            }
            
            pikPop.isHidden = true
            topBanner.isHidden = false
            dropPikBtn.isHidden = false
        }
    
    }
    

}








