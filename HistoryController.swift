//
//  HistoryController.swift
//  SampleForSwift
//
//  Created by INNOISDF700278 on 9/5/17.
//  Copyright © 2017 INNOISDF700278. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices
import AssetsLibrary
import AVFoundation
import AVKit
import MediaPlayer

class HistoryController: UIViewController, UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate {
    
    @IBOutlet var historytable: UITableView!
    var chats = [] as! [NSDictionary]
    var context: NSManagedObjectContext?
    var circleLayer: CAShapeLayer!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?

    override func viewDidLoad() {
        super.viewDidLoad()
        historytable.delegate=self
        historytable.dataSource = self
        historytable.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(deleteAllObjects))
        self.automaticallyAdjustsScrollViewInsets = true;
        // To fetch
        context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let sortDescriptor = NSSortDescriptor(key: "categaryoption", ascending: true)

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate=self
        try! fetchedResultsController?.performFetch()
        if let quotes = self.fetchedResultsController?.fetchedObjects {
            if quotes.count > 0 {
                print(quotes.count)
            }
        }


        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Entity", in: context!)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try context?.fetch(fetchRequest)
            //chats = result as! [N]
            //print("chat", chats)
            if (result?.count)! > 0 {
                historytable.isHidden = false
            }else{
                let actionSheetController: UIAlertController = UIAlertController(title: "", message: "No history available!", preferredStyle: .alert)
                
                //Create and add the Cancel action
                let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .default) { action -> Void in
                    //Just dismiss the action sheet
                    self.navigationController?.popViewController(animated: true)
                }
                actionSheetController.addAction(cancelAction)
                self.present(actionSheetController, animated: true, completion: nil)
            }
            print(result as Any)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func deleteAllObjects(){
        context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

        let fetchRequestdelete = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequestdelete)
        
        do {
            try (UIApplication.shared.delegate as! AppDelegate).persistentStoreCoordinator.execute(deleteRequest, with: context!)
            print("delete")
            let result = try context?.fetch(fetchRequestdelete)
            print(result as Any)
            let actionSheetController: UIAlertController = UIAlertController(title: "", message: "No history available!", preferredStyle: .alert)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Okay", style: .default) { action -> Void in
                //Just dismiss the action sheet
                self.navigationController?.popViewController(animated: true)
            }
            actionSheetController.addAction(cancelAction)
            self.present(actionSheetController, animated: true, completion: nil)
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController?.sections {
            return sections.count
        }
        
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewRowCell")
        let cellContact = fetchedResultsController?.object(at: indexPath) as! Entity
            (cell?.contentView.viewWithTag(1) as! UILabel).text = cellContact.location
            (cell?.contentView.viewWithTag(2) as! UILabel).text = cellContact.comments
            (cell?.contentView.viewWithTag(4) as! UILabel).text = cellContact.categaryoption
            if cellContact.image != nil{
            (cell?.contentView.viewWithTag(3) as! UIImageView).image = UIImage(data:cellContact.image! as Data)
            }
        if(cellContact.videourl != nil){
            let videoName = NSString(format:"%ld, %@",indexPath.row, "video.mp4")

            let videoPath = getDocumentsDirectory().appendingPathComponent(videoName as String)
            (cellContact.videourl!).write(toFile: videoPath, atomically: true)
            
            let asset : AVAsset = AVAsset(url:NSURL(fileURLWithPath:videoPath) as URL) as AVAsset
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            let time = CMTimeMakeWithSeconds(0.5, 1000)
            var actualTime = kCMTimeZero
            var thumbnail : CGImage?
            do {
                thumbnail = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
                let image:UIImage = UIImage( cgImage: thumbnail! )
                (cell?.contentView.viewWithTag(3) as! UIImageView).image = image
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }

        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
       let cellContact = fetchedResultsController?.object(at: indexPath) as! Entity
        if(cellContact.videourl != nil){
            let videoName = NSString(format:"%ld, %@",indexPath.row, "video.mp4")
            
            let videoPath = getDocumentsDirectory().appendingPathComponent(videoName as String)
            
            let player = AVPlayer(url: NSURL(fileURLWithPath:videoPath) as URL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.showsPlaybackControls = true
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }else if(cellContact.image != nil){
            let singleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector(("singleTapGestureCaptured:")))
            singleTap.numberOfTapsRequired = 1
            let aSelector : Selector = #selector(self.removeSubview)
            let tapGesture = UITapGestureRecognizer(target:self, action: aSelector)
            
            let screenRect = UIScreen.main.bounds
            let coverView: UIView = UIView(frame: screenRect)

            coverView.frame = screenRect
            coverView.tag = 200
            coverView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            
            let singleview: UIImageView = UIImageView(frame: CGRect(x: 12, y: 18, width: self.view.frame.size.width - 25, height: self.view.frame.size.height - 92.0))
            singleview.image = UIImage(data:cellContact.image! as Data)
            singleview.isMultipleTouchEnabled = true
            singleview.isUserInteractionEnabled = true
            
            let testLabel: UILabel = UILabel(frame: CGRect(x: 352, y: 11, width: 20, height: 20))
            testLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
            testLabel.textColor = UIColor.red
            testLabel.text = " X"
            testLabel.addGestureRecognizer(tapGesture)
            testLabel.tag = 100
            testLabel.isMultipleTouchEnabled = true
            testLabel.isUserInteractionEnabled = true
            
            
            circleLayer = CAShapeLayer()
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: 10,y: 10), radius: CGFloat(10), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)

            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = UIColor.red.cgColor
            circleLayer.lineWidth = 2.0
            testLabel.layer.addSublayer(circleLayer)
            
            
            coverView.addSubview(singleview)
            coverView.addSubview(testLabel)
            self.view.addSubview(coverView)
            
            
            
        }
 
        //your code...
    }
   
    func removeSubview(){
            //print(sender.view?.tag as Any)
        if self.view.viewWithTag(100) != nil {
            let viewtoremove = self.view.viewWithTag(200)
            viewtoremove?.removeFromSuperview()
        }else{
            print("No!")
        }
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
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
