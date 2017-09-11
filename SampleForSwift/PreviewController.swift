//
//  PreviewController.swift
//  SampleForSwift
//
//  Created by INNOISDF700278 on 8/25/17.
//  Copyright © 2017 INNOISDF700278. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices
import AssetsLibrary
import AVFoundation
import MediaPlayer

class PreviewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var locationbutton: UIButton!
    @IBOutlet weak var msgtext: UITextView!
    @IBOutlet weak var locationlabel: UILabel!
    @IBOutlet weak var captureImageview: UIImageView! 
    var selectedimage: UIImageView! = nil
    let imagePicker = UIImagePickerController()

    var context: NSManagedObjectContext?

    var setstr: NSString!
    var videodataselected: NSURL!
    var address: NSString!
    var captureImage: UIImage!
    var imageData: NSData!
    var videoData: NSData!
  @IBAction func locationbuttonaction(_ sender: AnyObject) {
    let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Do you want to change your current location!", preferredStyle: .alert)
    let okayaction: UIAlertAction = UIAlertAction(title: "Yes, please", style: .default) { action -> Void in
        //Just dismiss the action sheet
        self.navigationController?.popViewController(animated: true)
    }
    //Create and add the Cancel action
    let cancelAction: UIAlertAction = UIAlertAction(title: "No, thanks", style: .cancel) { action -> Void in
        //Just dismiss the action sheet
    }
    actionSheetController.addAction(okayaction)
    actionSheetController.addAction(cancelAction)
    self.present(actionSheetController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.msgtext.delegate=self;
        imagePicker.delegate = self
        self.msgtext.text = "Write your thoughts..."
        self.msgtext.textColor = UIColor.lightGray //optional
        self.locationlabel.text = self.address as String?
        self.msgtext.returnKeyType = UIReturnKeyType.done
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if captureImage != nil{
            self.captureImageview.image = captureImage
        }else if videodataselected != nil{
            let asset : AVAsset = AVAsset(url:videodataselected as URL) as AVAsset
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            let time = CMTimeMakeWithSeconds(0.5, 1000)
            var actualTime = kCMTimeZero
            var thumbnail : CGImage?
            do {
                thumbnail = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
                let image:UIImage = UIImage( cgImage: thumbnail! )
                self.captureImageview.image = image
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write your thoughts..." {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        textView.becomeFirstResponder()
    }
     func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Write your thoughts..."
            textView.textColor = UIColor.lightGray
        }
        textView.becomeFirstResponder()
    }
    
    func textView(txtView: UITextView, shouldChangeCharactersInRange range: NSRange, replacementText text: NSString) -> Bool
    {
        if text.rangeOfCharacter(from: NSCharacterSet.newlines).location != NSNotFound {
            return false
        }
        txtView.becomeFirstResponder()
        return true
    }
     @IBAction func submittaction(_ sender: AnyObject) {
        
       context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Entity", in: context!)
        
        let transc = NSManagedObject(entity: entity!, insertInto: context)
        //videoData = [NSData dataWithContentsOfURL:videodataselected];
        if(videodataselected != nil){
            videoData = try? NSData(contentsOf: videodataselected as URL)
            //videoData = NSData(data:content)

        }
        if captureImage != nil {
         imageData = NSData(data: UIImageJPEGRepresentation(captureImage, 1.0)!)
        }
        //set the entity values
        transc.setValue(self.title, forKey: "categaryoption")
        transc.setValue(msgtext.text, forKey: "comments")
        transc.setValue(locationlabel.text, forKey: "location")
        transc.setValue(imageData, forKey: "image")
        transc.setValue(videoData, forKey: "videourl")
        //save the object
        do {
            try context?.save()
            print("saved!")
            let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Successfully submitted!", preferredStyle: .alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .default) { action -> Void in
                //Just dismiss the action sheet
            }
            actionSheetController.addAction(cancelAction)
            self.present(actionSheetController, animated: true, completion: nil)

        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
        // To fetch
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Entity", in: context!)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try context?.fetch(fetchRequest)
            print(result as Any)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
     }
    @IBAction func selectphotoOption(_ sender: AnyObject) {
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Select any photo source!!", preferredStyle: .alert)
        let cameraButton: UIAlertAction = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            //Just dismiss the action sheet
            self.selectCamera()
        }
        let galleryButton: UIAlertAction = UIAlertAction(title: "Gallery", style: .default) { action -> Void in
            //Just dismiss the action sheet
            self.selectGallery()
        }
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cameraButton)
        actionSheetController.addAction(galleryButton)
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)

    }
    func selectCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            print("Button capture")
            
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.mediaTypes = [kUTTypeImage as String]
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
    func selectGallery() {
        
        imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        imagePicker.allowsEditing = false
        imagePicker.videoMaximumDuration = 120.0
        imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        self.present(imagePicker, animated: true, completion: nil)

    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediatype = info[UIImagePickerControllerMediaType] as! String;
        if(mediatype == kUTTypeImage as String){
        /// chcek if you can return edited image that user choose it if user already edit it(crop it), return it as image
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            /// if user update it and already got it , just return it to 'self.imgView.image'
            self.captureImage = editedImage
            self.captureImageview.image = editedImage
            videodataselected = nil
            /// else if you could't find the edited image that means user select original image same is it without editing .
        } else if let orginalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            /// if user update it and already got it , just return it to 'self.imgView.image'.
            self.captureImage = orginalImage
            self.captureImageview.image = orginalImage
            videodataselected = nil
            
        }
        else { print ("error") }
        }else{
            videodataselected = info[UIImagePickerControllerMediaURL] as! NSURL
            self.captureImage = nil
        }
        /// if the request successfully done just dismiss
        picker.dismiss(animated: true, completion: nil)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
