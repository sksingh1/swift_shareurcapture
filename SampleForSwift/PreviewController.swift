//
//  PreviewController.swift
//  SampleForSwift
//
//  Created by INNOISDF700278 on 8/25/17.
//  Copyright © 2017 INNOISDF700278. All rights reserved.
//

import UIKit

class PreviewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var locationbutton: UIButton!
    @IBOutlet weak var msgtext: UITextView!
    @IBOutlet weak var locationlabel: UILabel!
    @IBOutlet weak var captureImageview: UIImageView!
    var setstr: NSString!
    var address: NSString!
    var captureImage: UIImage!
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
        self.msgtext.text = "Write your thoughts..."
        self.msgtext.textColor = UIColor.lightGray //optional
        self.locationlabel.text = self.address as String?
        self.msgtext.returnKeyType = UIReturnKeyType.done
        self.captureImageview.image = captureImage
        // Do any additional setup after loading the view.
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
