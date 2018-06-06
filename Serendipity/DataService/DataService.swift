//
//  DataService.swift
//  Serendipity
//
//  Created by Zachary Foster on 5/30/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//

import Foundation
import CoreData

class DataService {
    
    var apiService: ApiService = ApiService()
    var mappers: DataMappers = DataMappers()
    
    func fetchAllMemories() {
        apiService.getDataWith(path: "memories") { (result) in
            switch result {
            case .Success(let data):
                self.saveCollectionInCoreDataWith(data: data, mapper: self.mappers.createMemoryEntityFrom)
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
                self.saveCollectionInCoreDataWith(data: data, mapper: self.mappers.createHotspotEntityFrom)
                print(data)
            case .Error(let message):
                DispatchQueue.main.async {
                    print(message)
                    //                    self.showAlertWith(title: "Error", message: message)
                }
            }
        }
    }
    
    func saveNewMemory(hotspot: Int, message: String, image: NSData) {
        let params: [String:AnyObject] =
            ["hotspotId": hotspot as AnyObject,
             "message": message as AnyObject]
        
        apiService.post(path: "memories", params: params) { (result) in
            switch result {
            case .Success(let data):
                self.saveInCoreDataWith(data: data, mapper: self.mappers.createMemoryEntityFrom)
                print("New memory saved: " + data.description)
            case .Error(let message):
                DispatchQueue.main.async {
                    print(message)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func saveInCoreDataWith(data: [String: AnyObject],
                                    mapper: (_ dictionary:[String: AnyObject]) -> NSManagedObject?) {
        _ = mapper(data)
        
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
    
    private func saveCollectionInCoreDataWith(data: [String: AnyObject],
                                              mapper: (_ dictionary:[String: AnyObject]) -> NSManagedObject?) {
        guard let items = data["items"] as? [[String: AnyObject]] else {
            // prob should throw an error here
            print("items was expected but not found in data: " + data.description)
            return
        }
        
        _ = items.map{mapper($0)}
        
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
    }
}
