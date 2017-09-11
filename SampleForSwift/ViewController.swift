//
//  ViewController.swift
//  SampleForSwift
//
//  Created by INNOISDF700278 on 8/23/17.
//  Copyright © 2017 INNOISDF700278. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import MobileCoreServices
import AssetsLibrary

//typedef; void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset, *asset);
//typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError, *error);
class ViewController: UIViewController , MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var selectOptionValue: NSString!
    var address: NSString!
    var videoURL: NSURL!
    var selectedimage: UIImageView! = nil
    let imagePicker = UIImagePickerController()
    var new_placemark: MKPlacemark! = nil
    let annotationpin = MKPointAnnotation()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var camButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    @IBAction func selectOption(_ sender: AnyObject) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Category", message: "Select relatively one of below list!", preferredStyle: .actionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Traffic", style: .default) { action -> Void in
             self.selectOptionValue="Traffic"
            //Code for launching the camera goes here
        }
        actionSheetController.addAction(takePictureAction)
        //Create and add a second option action
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Pollution", style: .default) { action -> Void in
             self.selectOptionValue="Pollution"
            //Code for picking from camera roll goes here
        }
        actionSheetController.addAction(choosePictureAction)
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
    }
    @IBAction func selectCamera(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            print("Button capture")
            
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let actionSheetController: UIAlertController = UIAlertController(title: "No Device", message: "Camera is not available!", preferredStyle: .alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .default) { action -> Void in
                //Just dismiss the action sheet
            }
            actionSheetController.addAction(cancelAction)
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
    @IBAction func selectGallery(_ sender: AnyObject) {
        
        imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        imagePicker.allowsEditing = false
        imagePicker.videoMaximumDuration = 120.0
        imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        self.present(imagePicker, animated: true, completion: nil)
        

    }
    @IBAction func selectPreview(_ sender: AnyObject) {
    }
    @IBAction func selectHistory(_ sender: AnyObject) {
    }
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.selectedimage = UIImageView(frame:CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0));
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        /// chcek if you can return edited image that user choose it if user already edit it(crop it), return it as image
        let mediatype = info[UIImagePickerControllerMediaType] as! String;
        if(mediatype == kUTTypeImage as String){
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            /// if user update it and already got it , just return it to 'self.imgView.image'
            self.selectedimage.image = editedImage
            
            /// else if you could't find the edited image that means user select original image same is it without editing .
        } else if let orginalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            /// if user update it and already got it , just return it to 'self.imgView.image'.
            self.selectedimage.image = orginalImage
        }
        else { print ("error") }
        }else{
            videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
        }
        /// if the request successfully done just dismiss
        picker.dismiss(animated: true, completion: nil)
        
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLoction: CLLocation = locations[0]
        let latitude = userLoction.coordinate.latitude
        let longitude = userLoction.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.05
        let lonDelta: CLLocationDegrees = 0.05
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        getLocationAddress(location: userLoction)
    }
    func dropPinZoomIn(placemark: MKPlacemark){   // This function will "poste" the dialogue bubble of the pin.
        var selectedPin: MKPlacemark?
        
        // cache the pin
        selectedPin = placemark    // MKPlacemark() give the details like location to the dialogue bubble. Place mark is initialize in the function getLocationAddress (location: ) who call this function.
        
        // clear existing pins to work with only one dialogue bubble.
        mapView.removeAnnotations(mapView.annotations)
        //let annotation = MKPointAnnotation()    // The dialogue bubble object.
        annotationpin.coordinate = placemark.coordinate
        annotationpin.title = "hey"// Here you should test to understand where the location appear in the dialogue bubble.
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotationpin.subtitle = String((city))+String((state));
        } // To "post" the user's location in the bubble.
        
        mapView.addAnnotation(annotationpin)     // To initialize the bubble.
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)   // To update the map with a center and a size.
    }
    
    func getLocationAddress(location:CLLocation) {    // This function give you the user's address from a location like locationManager.coordinate (it is usually the user's location).
        let geocoder = CLGeocoder()
        
        //print("-> Finding user address...")
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            var placemark:CLPlacemark!
            
            if error == nil && placemarks!.count > 0 {
                placemark = placemarks![0] as CLPlacemark
                
                
                var addressString : String = ""
                if placemark.isoCountryCode == "TW" /*Address Format in Chinese*/ {
                    if placemark.country != nil {  // To have the country
                        addressString = placemark.country!
                    }
                    if placemark.subAdministrativeArea != nil {  // To have the subAdministrativeArea.
                        addressString = addressString + placemark.subAdministrativeArea! + ", "
                    }
                    if placemark.postalCode != nil {   // To ...
                        addressString = addressString + placemark.postalCode! + " "
                    }
                    if placemark.locality != nil {
                        addressString = addressString + placemark.locality!
                    }
                    if placemark.thoroughfare != nil {
                        addressString = addressString + placemark.thoroughfare!
                    }
                    if placemark.subThoroughfare != nil {
                        addressString = addressString + placemark.subThoroughfare!
                    }
                } else {
                    if placemark.subThoroughfare != nil {
                        addressString = placemark.subThoroughfare! + " "
                    }
                    if placemark.thoroughfare != nil {
                        addressString = addressString + placemark.thoroughfare! + ", "
                    }
                    if placemark.postalCode != nil {
                        addressString = addressString + placemark.postalCode! + " "
                    }
                    if placemark.locality != nil {
                        addressString = addressString + placemark.locality! + ", "
                    }
                    if placemark.administrativeArea != nil {
                        addressString = addressString + placemark.administrativeArea! + " "
                    }
                    if placemark.country != nil {
                        addressString = addressString + placemark.country!
                    }
                    //print("addressString==\(addressString)")
                    self.address = addressString as NSString
                     self.new_placemark = MKPlacemark (placemark: placemark)
                    
                    // new_placemark initialize a variable of type MKPlacemark () from geocoder to use the function dropPinZoomIn (placemark:).
                    
                    
                    //self.dropPinZoomIn (placemark: self.new_placemark)
                    
                    //print (placemark.description)   // You can see the place mark's details like the country.
                    
                }
                
                
            }
        })
        
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("userLocation/")
        //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
        //[self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate,
                                                                  800, 800)
        mapView.setRegion(coordinateRegion, animated: true)
        // Add an annotatioz
        
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        myAnnotation.title = "Current location"
        self.mapView.addAnnotation(myAnnotation)
        
//        self.point = [[MKPointAnnotation alloc] init];
//        
//        self.point.coordinate = userLocation.coordinate;
//        self.point.title = @"Where am I?";
//        self.point.subtitle = @"I'm here!!!";
//        
//        [self.mapView addAnnotation:self.point];
        // Not getting called
        //self.dropPinZoomIn (placemark: self.new_placemark)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
       if annotation is MKPointAnnotation {
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
    
        pinAnnotationView.pinTintColor = UIColor.purple
        pinAnnotationView.animatesDrop = true
        pinAnnotationView.isDraggable = true
    
        return pinAnnotationView
       }
      return nil
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if segue.identifier == "previewSegue",
            let controller = segue.destination as! PreviewController
            if selectOptionValue != nil {
            controller.title = self.selectOptionValue as String
            }
            if selectedimage.image != nil {
               let image:UIImage = self.selectedimage.image!
               controller.captureImage = image
            }
            if address != nil {
            controller.address = self.address
            }
            if(videoURL != nil){
            controller.videodataselected = self.videoURL;
            }
    }

}

