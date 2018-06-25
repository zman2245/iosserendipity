//
//  DataService.swift
//  Serendipity
//
//  Created by Zachary Foster on 5/30/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//

import Foundation
import CoreData
import UIKit

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
                }
            }
        }
    }
    
    func fetchAllHotspots() {
        apiService.getDataWith(path: "hotspots") { (result) in
            switch result {
            case .Success(let data):
                _ = self.saveCollectionInCoreDataWith(data: data, mapper: self.mappers.createHotspotEntityFrom)
                print(data)
            case .Error(let message):
                DispatchQueue.main.async {
                    print(message)
                }
            }
        }
    }
    
    func fetchHotspots(latitude: Double, longitude: Double, radius: Int, completion: @escaping (ApiService.Result<[Hotspot]>) -> Void) {
        let path = "hotspots?latitude=" + String(latitude) + "&longitude=" + String(longitude) + "&radius=" + String(radius)
        apiService.getDataWith(path: path) { (result) in
            switch result {
            case .Success(let data):
                let mappedData = self.saveCollectionInCoreDataWith(data: data, mapper: self.mappers.createHotspotEntityFrom)
                return completion(.Success(mappedData as! [Hotspot]))
            case .Error(let message):
                DispatchQueue.main.async {
                    completion(.Error(message))
                }
            }
        }
    }
    
    // TODO: image caching
    func fetchImage(url: String, completion: @escaping (Bool, Data?) -> Void) {
        apiService.getDataWith(path: url) { (result) in
            switch result {
            case .Success(let data):
                // decode the image for consumer code
                let base64String: String = data["base64Image"] as! String
                let decodedData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)
                
                DispatchQueue.main.async {
                    completion(true, decodedData)
                }
            case .Error(_):
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        }
    }
    
    func saveNewMemory(hotspot: Int, message: String, image: UIImage?) {
        var params: [String:AnyObject] =
            ["hotspotId": hotspot as AnyObject,
             "message": message as AnyObject]
        
        if (image != nil) {
            let imageData = UIImagePNGRepresentation(image!)!
            let encodedImage = imageData.base64EncodedString()
            params["base64Image"] = encodedImage as AnyObject
        }
        
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
                                    mapper: (_ dictionary:[String: AnyObject]) -> NSManagedObject?) -> NSManagedObject? {
        let mappedItem = mapper(data)
        
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
        
        return mappedItem
    }
    
    private func saveCollectionInCoreDataWith(data: [String: AnyObject],
                                              mapper: (_ dictionary:[String: AnyObject]) -> NSManagedObject?) -> [NSManagedObject] {
        guard let items = data["items"] as? [[String: AnyObject]] else {
            // prob should throw an error here
            print("items was expected but not found in data: " + data.description)
            return []
        }
        
        let mappedItems = items.map{mapper($0)}
        
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error {
            print(error)
        }
        
        return mappedItems as! [NSManagedObject]
    }
}
