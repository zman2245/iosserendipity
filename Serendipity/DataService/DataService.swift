//
//  DataService.swift
//  Serendipity
//
//  Created by Zachary Foster on 5/30/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//

import CoreData

class DataService {
    
    var apiService: ApiService = ApiService()
    
    func fetchAllMemories() {
        apiService.getDataWith(path: "memories") { (result) in
            switch result {
            case .Success(let data):
                self.saveInCoreDataWith(array: data, mapper: self.createMemoryEntityFrom)
                print(data)
            case .Error(let message):
                DispatchQueue.main.async {
                    print(message)
//                    self.showAlertWith(title: "Error", message: message)
                }
            }
        }
    }
    
    func fetchAllHotspots() {
        apiService.getDataWith(path: "hotspots") { (result) in
            switch result {
            case .Success(let data):
                self.saveInCoreDataWith(array: data, mapper: self.createHotspotEntityFrom)
                print(data)
            case .Error(let message):
                DispatchQueue.main.async {
                    print(message)
                    //                    self.showAlertWith(title: "Error", message: message)
                }
            }
        }
    }
    
    private func saveInCoreDataWith(array: [[String: AnyObject]],
                                    mapper: (_ dictionary:[String: AnyObject]) -> NSManagedObject?) {
        _ = array.map{mapper($0)}
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    // MARK: - entity mapping functions
    
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
    
    private func createHotspotEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let hotspotEntity = NSEntityDescription.insertNewObject(forEntityName: "Hotspot", into: context) as? Hotspot {
            hotspotEntity.id = (dictionary["id"] as? Int64)!
            hotspotEntity.title = dictionary["title"] as? String
            hotspotEntity.about = dictionary["about"] as? String
            hotspotEntity.latitude = (dictionary["latitude"] as? NSNumber)!.floatValue
            hotspotEntity.longitude = (dictionary["longitude"] as? NSNumber)!.floatValue
            hotspotEntity.radiusInFeet = (dictionary["radiusInFeet"] as? Int32)!
            hotspotEntity.createdAt = serverDateToNSDate(dictionary["createdAt"] as! String)
            hotspotEntity.updatedAt = serverDateToNSDate(dictionary["updatedAt"] as! String)
            
            print("Hotspot Entity:", hotspotEntity)
            
            //            memoryEntity.creator = dictionary["imageLink"] as? String
            //            memoryEntity.owner = dictionary["imageLink"] as? String
            //            memoryEntity.currentHotspot = dictionary["imageLink"] as? String
            //            memoryEntity.originalHotspot = dictionary["imageLink"] as? String
            return hotspotEntity
        }
        return nil
    }
    
    private func createUserEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let userEntity = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User {
            userEntity.id = (dictionary["id"] as? Int64)!
            userEntity.name = dictionary["name"] as? String
            userEntity.bio = dictionary["bio"] as? String
            userEntity.latitude = (dictionary["latitude"] as? NSNumber)!.floatValue
            userEntity.longitude = (dictionary["longitude"] as? NSNumber)!.floatValue
            userEntity.createdAt = serverDateToNSDate(dictionary["createdAt"] as! String)
            userEntity.updatedAt = serverDateToNSDate(dictionary["updatedAt"] as! String)
            
            print("User Entity:", userEntity)
            
            //            memoryEntity.creator = dictionary["imageLink"] as? String
            //            memoryEntity.owner = dictionary["imageLink"] as? String
            //            memoryEntity.currentHotspot = dictionary["imageLink"] as? String
            //            memoryEntity.originalHotspot = dictionary["imageLink"] as? String
            return userEntity
        }
        return nil
    }
    
    // MARK: - data field helpers
    
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
