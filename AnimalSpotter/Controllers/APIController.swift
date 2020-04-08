//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Scott Gardner on 4/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

final class APIController {
    typealias GetAnimalNamesCompletion = (Result<[String], NetworkError>) -> Void
    typealias GetAnimalCompletion = (Result<Animal, NetworkError>) -> Void
    typealias GetImageCompletion = (Result<UIImage, NetworkError>) -> Void
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum NetworkError: Error {
        case failedSignUp, failedSignIn, noData, badData
        case notSignedIn, failedFetch, badURL
    }
    
    private enum LoginStatus {
        case notLoggedIn
        case loggedIn(Bearer)
        
        static var isLoggedIn: Self {
            if let bearer = APIController.bearer {
                return loggedIn(bearer)
            } else {
                return notLoggedIn
            }
        }
    }
    
    static var bearer: Bearer?
    
    private let baseURL = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    private lazy var signUpURL = baseURL.appendingPathComponent("/users/signup")
    private lazy var signInURL = baseURL.appendingPathComponent("/users/login")
    private lazy var allAnimalNamesURL = baseURL.appendingPathComponent("/animals/all")
    
    private lazy var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    
    private lazy var jsonDecoder = JSONDecoder()
    
    func signUp(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        var request = postRequest(for: signUpURL)
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            print(String(data: jsonData, encoding: .utf8)!)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    print("Sign up failed with error: \(error.localizedDescription)")
                    completion(.failure(.failedSignUp))
                    return
                }
                
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200
                    else {
                        print("Sign up was unsuccessful")
                        return completion(.failure(.failedSignUp))
                }
                
                completion(.success(true))
            }
            .resume()
        } catch {
            print("Error encoding user: \(error.localizedDescription)")
            completion(.failure(.failedSignUp))
        }
    }
    
    func signIn(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        var request = postRequest(for: signInURL)
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Sign in failed with error: \(error.localizedDescription)")
                    completion(.failure(.failedSignIn))
                    return
                }
                
                guard let response = response as? HTTPURLResponse,
                    response.statusCode == 200
                    else {
                        print("Sign in was unsuccessful")
                        return completion(.failure(.failedSignIn))
                }
                
                guard let data = data else {
                    print("Data was not received")
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    Self.bearer = try self.jsonDecoder.decode(Bearer.self, from: data)
                    completion(.success(true))
                } catch {
                    print("Error decoding bearer: \(error.localizedDescription)")
                    completion(.failure(.failedSignIn))
                }
            }
            .resume()
        } catch {
            print("Error encoding user: \(error.localizedDescription)")
            completion(.failure(.failedSignIn))
        }
    }
    
    func getAnimalNames(completion: @escaping GetAnimalNamesCompletion) {
        guard case let .loggedIn(bearer) = LoginStatus.isLoggedIn else {
            return completion(.failure(.notSignedIn))
        }
        
        let request = getRequest(for: allAnimalNamesURL, bearer: bearer)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch animal names with error \(error.localizedDescription)")
                completion(.failure(.failedFetch))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200
                else {
                    print("Fetch animal names received bad response")
                    completion(.failure(.failedFetch))
                    return
            }
            
            guard let data = data else {
                return completion(.failure(.badData))
            }
            
            do {
                let animalNames = try self.jsonDecoder.decode([String].self, from: data)
                completion(.success(animalNames))
            } catch {
                print("Error decoding animal names: \(error.localizedDescription)")
                completion(.failure(.badData))
            }
        }
        .resume()
    }
    
    func getAnimal(for animalName: String, completion: @escaping GetAnimalCompletion) {
        guard case let .loggedIn(bearer) = LoginStatus.isLoggedIn else {
            return completion(.failure(.notSignedIn))
        }
        
        let animalURL = baseURL.appendingPathComponent("animals/\(animalName)")
        let request = getRequest(for: animalURL, bearer: bearer)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch animal with error \(error.localizedDescription)")
                completion(.failure(.failedFetch))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200
                else {
                    print(#file, #function, #line, "Fetch animal received bad response")
                    completion(.failure(.failedFetch))
                    return
            }
            
            guard let data = data else {
                return completion(.failure(.badData))
            }
            
            do {
                let animal = try self.jsonDecoder.decode(Animal.self, from: data)
                completion(.success(animal))
            } catch {
                print("Error decoding animal: \(error.localizedDescription)")
                completion(.failure(.badURL))
            }
        }
        .resume()
    }
    
    func getImage(at urlString: String, completion: @escaping GetImageCompletion) {
        guard let imageURL = URL(string: urlString) else {
            return completion(.failure(.badURL))
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let error = error {
                print("Failed to fetch animal image with error \(error.localizedDescription)")
                completion(.failure(.failedFetch))
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200
                else {
                    print(#file, #function, #line, "Fetch animal image received bad resopnse")
                    completion(.failure(.failedFetch))
                    return
            }
            
            guard let data = data,
                let image = UIImage(data: data)
                else {
                return completion(.failure(.badData))
            }
            
            completion(.success(image))
        }
        .resume()
    }
    
    private func postRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func getRequest(for url: URL, bearer: Bearer) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
