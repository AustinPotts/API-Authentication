//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Ben Gohlke on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error{
    case ecodingError
    case responseError
    case otherError(Error)
    case noData
    case noDecode
    case noToken
}

class APIController {
    
    
    var bearer: Bearer?
    
    private let baseUrl = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    
    // create function for sign up
    func signUp(with user: User, completion: @escaping(NetworkError?)-> Void){
        
        //Build the URL
        let requestURL = baseUrl.appendingPathComponent("users").appendingPathComponent("signup")
        
        //Build the request
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.post.rawValue
        
        //Turn request into JSON
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //Perform the request
        let encoder = JSONEncoder()
        
        do {
           let userJSON = try encoder.encode(user)
            request.httpBody = userJSON
        } catch {
            NSLog("Error encoding data: \(error)")
            completion(.ecodingError)
            return
            
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.responseError)
                return
            }
            
            if let error = error {
                NSLog("Error Creating user on server: \(error)")
                completion(.otherError(error))
                return
            }
            completion(nil)
        }.resume()
        
    }
    
    
    // create function for log in
    
    func signIn(with user: User, completion: @escaping(NetworkError?)-> Void){
        
        //Build Url
        let loginURL = baseUrl.appendingPathComponent("users").appendingPathComponent("login")
        
        //Build request
        var request = URLRequest(url: loginURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        
        do {
            request.httpBody = try encoder.encode(user)
        } catch {
            NSLog("Error: \(error)")
            completion(.ecodingError)
            return
        }
        
        //Perform the request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200{
                completion(.noData)
                return
            }
            
            if let error = error {
                NSLog("Error fetching data tasks: \(error)")
                completion(.otherError(error))
                return
            }
            
            guard let data = data else {
                completion(.noData)
                return
            }
            
            do {
                let bearer = try JSONDecoder().decode(Bearer.self, from: data)
                
                self.bearer = bearer
            } catch {
                completion(.noData)
                return
                
            }
            
            completion(nil)
            
            
        }.resume()
        
        
    }
    
    
    
    
    
    
    // create function for fetching all animal names
    
    // create function to fetch image
}
