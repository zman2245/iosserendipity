//
//  ViewController.swift
//  Serendipity
//
//  Created by Zachary Foster on 3/5/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
            memoryEntity.artworkLink = dictionary["artworkLink"] as? String
            memoryEntity.bgColor = (dictionary["bgColor"] as? Int32)!
            memoryEntity.imageLink = dictionary["imageLink"] as? String
            memoryEntity.message = dictionary["message"] as? String
            memoryEntity.createdAt = serverDateToNSDate(dictionary["createdAt"] as! String)
            memoryEntity.updatedAt = serverDateToNSDate(dictionary["updatedAt"] as! String)
            
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

