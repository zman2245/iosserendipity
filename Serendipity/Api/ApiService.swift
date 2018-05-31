//
//  ApiService.swift
//  Serendipity
//
//  Created by Zachary Foster on 5/27/18.
//  Copyright © 2018 Big Z Industries, LLC. All rights reserved.
//

import Foundation

// Looked at Tron/Alamofire libraries, but it seems plain old NSURLSession might be fine nowadays
class ApiService {
    
    let baseUrl: String = "http://localhost:8080/"
    
    enum Result <T>{
        case Success(T)
        case Error(String)
    }
    
    func getDataWith(path: String, completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        
        guard let url = URL(string: baseUrl + path) else {
            return completion(.Error("Invalid URL"))
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                return completion(.Error(error!.localizedDescription))
            }
            
            guard let data = data else {
                return completion(.Error(error?.localizedDescription ?? "There are no new Items to show"))
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                    
                    guard let itemsJsonArray = json["items"] as? [[String: AnyObject]] else {
                        print("json nil or items not found")
                        return
                    }
                    
                    // run handler on main thread because consumer would like it I guess?
                    DispatchQueue.main.async {
                        completion(.Success(itemsJsonArray))
                    }
                } else {
                    return completion(.Error(error?.localizedDescription ?? "json serialization failed. Maybe API returned Json array instead of obj or something?"))
                }
            } catch let error {
                return completion(.Error(error.localizedDescription))
            }
        }.resume()
    }
    
    func getMyMemories() {
        
    }
}
