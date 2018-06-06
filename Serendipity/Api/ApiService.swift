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
    
    func getDataWith(path: String, completion: @escaping (Result<[String: AnyObject]>) -> Void) {
        
        guard let url = URL(string: baseUrl + path) else {
            return completion(.Error("Invalid URL"))
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.resultHandler(data, response, error, completion: completion)
//            guard error == nil else {
//                return completion(.Error(error!.localizedDescription))
//            }
//
//            guard let data = data else {
//                return completion(.Error(error?.localizedDescription ?? "There's no response"))
//            }
//
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
//
//                    // run handler on main thread because consumer would like it I guess?
//                    DispatchQueue.main.async {
//                        completion(.Success(json))
//                    }
//                } else {
//                    return completion(.Error(error?.localizedDescription ?? "json serialization failed. Maybe API returned Json array instead of obj or something?"))
//                }
//            } catch let error {
//                return completion(.Error(error.localizedDescription))
//            }
        }.resume()
    }
    
    func post(path: String, params: [String: AnyObject], completion: @escaping (Result<[String: AnyObject]>) -> Void) {
        guard let url = URL(string: baseUrl + path) else {
            return completion(.Error("Invalid URL"))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody
        request.timeoutInterval = 5

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            self.resultHandler(data, response, error, completion: completion)
        }
    }
    
    // All requests handle results the same
    // Note that POST requests are designed to return the item that was POSTed
    private func resultHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?, completion: @escaping (Result<[String: AnyObject]>) -> Void) {
        guard error == nil else {
            return completion(.Error(error!.localizedDescription))
        }
        
        guard let data = data else {
            return completion(.Error(error?.localizedDescription ?? "There's no response"))
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                
                // run handler on main thread because consumer would like it I guess?
                DispatchQueue.main.async {
                    completion(.Success(json))
                }
            } else {
                return completion(.Error(error?.localizedDescription ?? "json serialization failed. Maybe API returned Json array instead of obj or something?"))
            }
        } catch let error {
            return completion(.Error(error.localizedDescription))
        }
    }
}
