//
//  DataMappers.swift
//  Serendipity
//
//  Created by Zachary Foster on 6/6/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//

import CoreData

class DataMappers {
    func createMemoryEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
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
    
    func createHotspotEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let hotspotEntity = NSEntityDescription.insertNewObject(forEntityName: "Hotspot", into: context) as? Hotspot {
            let location = parseLocation(dictionary: dictionary["location"] as! [String: AnyObject])
            
            hotspotEntity.id = (dictionary["id"] as? Int64)!
            hotspotEntity.title = dictionary["title"] as? String
            hotspotEntity.about = dictionary["about"] as? String
            hotspotEntity.latitude = location.0
            hotspotEntity.longitude = location.1
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
    
    func createUserEntityFrom(dictionary: [String: AnyObject]) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let userEntity = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User {
            let location = parseLocation(dictionary: dictionary["location"] as! [String: AnyObject])
            
            userEntity.id = (dictionary["id"] as? Int64)!
            userEntity.name = dictionary["name"] as? String
            userEntity.bio = dictionary["bio"] as? String
            userEntity.latitude = location.0
            userEntity.longitude = location.1
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
    
    // returns location in the form: (lat, long)
    func parseLocation(dictionary: [String: AnyObject]) -> (Float, Float) {
        guard let coordinates = dictionary["coordinates"] as! [NSNumber]? else {
            print("Failed to parse location")
            return (0.0, 0.0)
            //            throw DataServiceErrors.ParseError("Failed to parse location")
        }
        
        if (coordinates.count != 2) {
            print("Coordinates is not the correct length. Length is " + String(coordinates.count))
            return (0.0, 0.0)
        }
        
        return (coordinates[1].floatValue, coordinates[0].floatValue)
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
