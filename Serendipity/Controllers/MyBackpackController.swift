//
//  ViewController.swift
//  Serendipity
//
//  Created by Zachary Foster on 3/5/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//

import UIKit
import CoreData

class MyBackpackController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var messageTable: UITableView!
    
    lazy var fetchedhResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Memory.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "message", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.messageTable.delegate = self
        self.messageTable.dataSource = self
        
        let service = ApiService()
        service.getDataWith { (result) in
            switch result {
            case .Success(let data):
                self.saveInCoreDataWith(array: data)
                print(data)
            case .Error(let message):
                DispatchQueue.main.async {
                    self.showAlertWith(title: "Error", message: message)
                }
            }
        }
        
        do {
            try self.fetchedhResultController.performFetch()
            print("COUNT FETCHED FIRST: \(String(describing: self.fetchedhResultController.sections?[0].numberOfObjects))")
        } catch let error  {
            print("ERROR: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView delegate and dataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedhResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryCell", for: indexPath) as! MemoryCell
        if let memory = fetchedhResultController.object(at: indexPath) as? Memory {
            cell.textLabel?.text = memory.message
        }
        return cell
    }

    // MARK: - Helpers
    
    func showAlertWith(title: String, message: String, style: UIAlertControllerStyle = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: title, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func saveInCoreDataWith(array: [[String: AnyObject]]) {
        _ = array.map{self.createMemoryEntityFrom(dictionary: $0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    // TODO: how to handle IDs?
    private func createMemoryEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let memoryEntity = NSEntityDescription.insertNewObject(forEntityName: "Memory", into: context) as? Memory {
            memoryEntity.id = (dictionary["id"] as? Int64)!
            memoryEntity.artworkLink = dictionary["artworkLink"] as? String
            memoryEntity.bgColor = (dictionary["bgColor"] as? Int32)!
            memoryEntity.imageLink = dictionary["imageLink"] as? String
            memoryEntity.message = dictionary["message"] as? String
            memoryEntity.createdAt = serverDateToNSDate(dictionary["createdAt"] as! String)
            memoryEntity.updatedAt = serverDateToNSDate(dictionary["updatedAt"] as! String)
            
            print("Memory Entity:", memoryEntity)
            
//            memoryEntity.creator = dictionary["imageLink"] as? String
//            memoryEntity.owner = dictionary["imageLink"] as? String
//            memoryEntity.currentHotspot = dictionary["imageLink"] as? String
//            memoryEntity.originalHotspot = dictionary["imageLink"] as? String
            return memoryEntity
        }
        return nil
    }
    
    private func serverDateToNSDate(_ serverDate: String) -> NSDate? {
        let dateFor: DateFormatter = DateFormatter()
        dateFor.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS+Y"
        
        guard let date = dateFor.date(from: serverDate) else {
            print("Problem parsing date: " + serverDate)
            return nil
        }
        
        return NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
    }
}

extension MyBackpackController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.messageTable.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.messageTable.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.messageTable.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        messageTable.beginUpdates()
    }
}

