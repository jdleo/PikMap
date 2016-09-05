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
    @IBOutlet weak var textField: CustomTextField!
    
    var imageData: Any?
    
    let locationManager = CLLocationManager()
    var mapCentered = false
    var geoFire: GeoFire!
    var geoFireReference: FIRDatabaseReference!
    let imagePick = UIImagePickerController()
    var tempId: String?
    

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        imagePick.delegate = self
        
        //to dismiss the keyboard when we tap away from it
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //auth user for uploading
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if error != nil {
                print("starterror \(error) enderror")
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
    
    //authorize us for using user location
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // pointless boilerplate code
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
        let annoIdentifier = "Pikz"
        var annotationImg: MKAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self) {
            annotationImg = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationImg?.image = UIImage(named: "add_feeling_btn.png")
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: "Pikz") {
            annotationImg = deqAnno
            annotationImg?.annotation = annotation
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .custom)
            annotationImg = av
        }
        
        if let annotationImg = annotationImg, let anno = annotation as? PikAnnotation {
            
            //if annotation is NOT user, then make it have these properties
            annotationImg.canShowCallout = true
            annotationImg.image = UIImage(named: "annoimg2.png")
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.setImage(UIImage(named: "searchbutton.png"), for: .normal)
            annotationImg.rightCalloutAccessoryView = btn
        
        }
        
        return annotationImg
    }
    
    //passing the segue ID over to the next VC, so it knows which pic/caption to display
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPik" {
            var svc = segue.destination as! PikController
            svc.segId = tempId
            
        }
    }
    
    //boilerplate imagepicker stuff
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
    
    //when region changes, show piks in radius
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        showPiks(location: loc)
    }
    
    //GeoFire in action. this creates a database entry with the long/lat
    func dropPik(forLocation location:CLLocation, withImage imageId: String) {
        
        
        geoFire.setLocation(location, forKey: imageId)
        
    }
    
    //when callout is tapped, segue over to vc that has the pik/caption
    //set tempId to the iid from the annotation
    //this tells us which pic were actually viewing
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let anno = view.annotation as? PikAnnotation {

            tempId = anno.iid
            self.performSegue(withIdentifier: "goToPik", sender: self)
        }
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
        //first, we're gonna check if it has an image selected, and caption isnt nil
        if imagePickerImg.image != UIImage(named: "photobtn.png") && textField.text != "" {
            
            if let uploadData = UIImageJPEGRepresentation(imagePickerImg.image!, 0.2) {
                //create a random UID for the image. helps SO much.
                let iid = NSUUID().uuidString.lowercased()
                
                //setting customMetadata to hold our caption in the photo
                var meta = FIRStorageMetadata()
                meta.customMetadata = ["caption" : self.textField.text!]
                
                //uploading photo to Firebase. It will name the photo the ID that it gen'd
                let imageRef = storageRef.child(iid)
                imageRef.put(uploadData, metadata: meta, completion: { (metadata, error) in
                    if error != nil {
                        print(error)
                        return
                    } else {
                        let loc: CLLocation?
                        
                        /*** Okay, I know this is some really weird error handling,
                        but basically were gonna try to get the current user location
                         and for some reason if it fails, were just gonna get the map center and use that as the location. if lat isnt nil, then we know long wont be either, so that's what that's all about***/
                        
                        let lat = self.locationManager.location?.coordinate.latitude
                        let lon = self.locationManager.location?.coordinate.longitude
                        if lat != nil {
                            loc = CLLocation(latitude: lat!, longitude: lon!)
                        } else {
                            loc = CLLocation(latitude: self.mapView.centerCoordinate.latitude, longitude: self.mapView.centerCoordinate.longitude)
                        }
                        self.dropPik(forLocation: loc!, withImage: iid)
                        print(metadata)
                        
                    }
                })
            }
            
            //revert UI back to defaults when were done uploading, and close popup
            self.textField.text = ""
            imagePickerImg.image = UIImage(named: "photobtn.png")
            pikPop.isHidden = true
            topBanner.isHidden = false
            dropPikBtn.isHidden = false
        } else {
            //if user doesnt have text or pic
            let aC1 = UIAlertController(title: "Oops", message: "You need to have a picture and a caption! :(", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title:"K", style: .cancel) { (action) in
                //idk...
            }
            aC1.addAction(okAction)
            self.present(aC1, animated: true, completion: nil)
            
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //showing piks in the radius defined, and making a query using GeoFire 
    func showPiks(location: CLLocation) {
        let circleQuery = geoFire!.query(at: location, withRadius: 2.5)
        
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (iid, location) in
            
            if let iid = iid, let location = location {
               let anno = PikAnnotation(coordinate: location.coordinate, iid: iid)
                self.mapView.addAnnotation(anno)
            }
            
        })
    }
    
    

}








