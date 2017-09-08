//
//  HistoryController.swift
//  SampleForSwift
//
//  Created by INNOISDF700278 on 9/5/17.
//  Copyright © 2017 INNOISDF700278. All rights reserved.
//

import UIKit
import CoreData
class HistoryController: UIViewController, UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate {
    
    @IBOutlet var historytable: UITableView!
    var chats = [] as! [NSDictionary]
    var context: NSManagedObjectContext?
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
            (cell?.contentView.viewWithTag(3) as! UIImageView).image = UIImage(data:cellContact.image! as Data)
        
        
        return cell!
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
