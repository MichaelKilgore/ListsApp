//
//  NetworkManager.swift
//  List
//
//  Created by Michael Kilgore on 9/25/21.
//

import SwiftUI

enum NetworkError: Error {
    case badURL
    case unableToComplete
    case invalidResponse
    case invalidData
    case nonConformingData
}

class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    
    /*  Purpose: sends new user information to server
        Return: success or fail.
        Usage: called when user creates a new account, sends info to server, and gets a response on the success of that request.
    */
    func createNewUser(for email: String, username: String, password: String, withCompletion completion: @escaping (Result<Message, NetworkError>) -> Void) {
        guard let url = URL(string: hostURL+"createNewUser") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "email": email,
            "username": username,
            "password": password
        ]
                
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
                        
            do {
                let decoder = JSONDecoder()
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let response = try decoder.decode(Message.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.nonConformingData))
            }
                        
        }
        task.resume()
    } //: CREATE NEW USER
    
    /*  Purpose: sends user login credentials to server.
        Return: success means the user recieves their information, fail means no userinformation sent.
        Usage: called when user attempts to login.
    */
    func login(for email: String, password: String, deviceToken: String, withCompletion completion: @escaping (Result<UserDecodable, NetworkError>) -> Void) {
        guard let url = URL(string: hostURL+"login") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "email": email,
            "password": password,
            "deviceToken": deviceToken
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let response = try decoder.decode(UserDecodable.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.nonConformingData))
            }
            
            /*catch let DecodingError.dataCorrupted(context) {
                    print(context)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Value '\(value)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch let DecodingError.typeMismatch(type, context)  {
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("error: ", error)
                }*/
            
        }
        task.resume()
    } //: LOGIN
    
    func forgotPassword(for email: String, withCompletion completion: @escaping (Result<Message, NetworkError>) -> Void) {
        guard let url = URL(string: hostURL+"forgotPassword/?email=\(email)") else {
            completion(.failure(.badURL))
            return
        }
        
        let request = URLRequest(url: url)
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let response = try decoder.decode(Message.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.nonConformingData))
            }
        }
        task.resume()
    } //: FORGOT PASSWORD
    
    func changeUsername(for email: String, password: String, username: String, withCompletion completion: @escaping (Result<Message, NetworkError>) -> Void) {
        guard let url = URL(string: hostURL+"changeUsername") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "email": email,
            "password": password,
            "username": username
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
                        
            do {
                let decoder = JSONDecoder()
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let response = try decoder.decode(Message.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.nonConformingData))
            }
            
        }
        task.resume()
    } //: CHANGE USERNAME
    
    func createNewList(for email: String, password: String, listName: String, withCompletion completion: @escaping (Result<NewListResponse, NetworkError>) -> Void) {
        guard let url = URL(string: hostURL+"createNewList") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "email": email,
            "password": password,
            "listName": listName
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
                        
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let response = try decoder.decode(NewListResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.nonConformingData))
            }
            
        }
        task.resume()
    } //: CREATE NEW LIST
    
    func deleteList(for email: String, password: String, listID: String, withCompletion completion: @escaping (Result<Message, NetworkError>) -> Void) {
        guard let url = URL(string: hostURL+"deleteList") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "email": email,
            "password": password,
            "listID": listID
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
                        
            do {
                let decoder = JSONDecoder()
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let response = try decoder.decode(Message.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.nonConformingData))
            }
            
        }
        task.resume()
    } //: DELETE LIST
    
    //send body item id back to the user in resp.response
    //also send imagePath back to the user in resp
    //TODO: Need a new object in place of Message.
    func addListItem(for email: String, username: String, password: String, listID: String, text: String, hyperLink: String, image: UIImage, withCompletion completion: @escaping (Result<BodyItemResponse, NetworkError>) -> Void) {
        var urlString = ""
        
        if image == UIImage() {
            urlString = hostURL+"addListItem"
        } else {
            urlString = hostURL+"addListItemWithImage"
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
                
        let parameters = [
            "email": email,
            "username": username,
            "password": password,
            "listID": listID,
            "text": text,
            "hyperLink": hyperLink
        ]
                
        if image != UIImage() {
            print("Sending post request with an image.")
            let boundary = generateBoundaryString()
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let imageData = image.jpegData(compressionQuality: 1)
            request.httpBody = createBodyWithParameters(parameters: parameters, filePathKey: "image", imageDataKey: imageData! as NSData, boundary: boundary, imgKey: "image") as Data
        } else {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(BodyItemResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.nonConformingData))
            }
            
        }
        task.resume()
        
    }
    
    func getImage(for email: String, password: String, imageID: String, withCompletion completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let url = URL(string: hostURL+"getImage/?id=\(imageID)") else {
            completion(.failure(.badURL))
            return
        }
        
        let request = URLRequest(url: url)
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard data != nil else {
                completion(.failure(.invalidData))
                return
            }
            
            print("getting image.")
            completion(.success(data!))
        }
        task.resume()
    }
    
    func clearDeviceToken(for email: String, password: String, withCompletion completion: @escaping (Result<Message, NetworkError>) -> Void) {
        guard let url = URL(string: hostURL+"clearDeviceToken") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
                        
            do {
                let decoder = JSONDecoder()
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let response = try decoder.decode(Message.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.nonConformingData))
            }
        }
        task.resume()
    }
    
    func deleteListItem(for email: String, password: String, listID: String, bodyID: String, withCompletion completion: @escaping (Result<Message, NetworkError>) -> Void) {
        guard let url = URL(string: hostURL+"deleteListItem") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "email": email,
            "password": password,
            "listID": listID,
            "bodyID": bodyID
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
                        
            do {
                let decoder = JSONDecoder()
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let response = try decoder.decode(Message.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.nonConformingData))
            }
            
        }
        task.resume()
        
    }
    
    func inviteUser(for email: String, password: String, invitedUser: String, listID: String, listName: String, withCompletion completion: @escaping (Result<Message, NetworkError>) -> Void) {
        guard let url = URL(string: hostURL+"inviteUser") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "email": email,
            "password": password,
            "invitedUser": invitedUser,
            "listID": listID,
            "listName": listName
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
                        
            do {
                let decoder = JSONDecoder()
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let response = try decoder.decode(Message.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.nonConformingData))
            }
            
        }
        task.resume()
    }
    
    func acceptInvite(for email: String, password: String, listID: String, withCompletion completion: @escaping (Result<Message, NetworkError>) -> Void) {
        guard let url = URL(string: hostURL+"acceptInvite") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "email": email,
            "password": password,
            "listID": listID,
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
                        
            do {
                let decoder = JSONDecoder()
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let response = try decoder.decode(Message.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.nonConformingData))
            }
            
        }
        task.resume()
    }
    
    func declineInvite(for email: String, password: String, listID: String, withCompletion completion: @escaping (Result<Message, NetworkError>) -> Void) {
        guard let url = URL(string: hostURL+"declineInvite") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "email": email,
            "password": password,
            "listID": listID,
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
                        
            do {
                let decoder = JSONDecoder()
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let response = try decoder.decode(Message.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.nonConformingData))
            }
            
        }
        task.resume()
    }
    
    func updateItem(for email: String, password: String, listID: String, bodyID: String, text: String, hyperLink: String, withCompletion completion: @escaping (Result<Message, NetworkError>) -> Void) {
        guard let url = URL(string: hostURL+"updateItem") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "email": email,
            "password": password,
            "listID": listID,
            "bodyID": bodyID,
            "text": text,
            "hyperLink": hyperLink
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
                        
            do {
                let decoder = JSONDecoder()
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let response = try decoder.decode(Message.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.nonConformingData))
            }
            
        }
        task.resume()
    }
    
    func updateItemWithImage(for email: String, password: String, listID: String, bodyID: String, text: String, hyperLink: String, image: UIImage, withCompletion completion: @escaping (Result<Message, NetworkError>) -> Void) {
        guard let url = URL(string: hostURL+"updateItemWithImage") else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
                
        let parameters = [
            "email": email,
            "password": password,
            "listID": listID,
            "bodyID": bodyID,
            "text": text,
            "hyperLink": hyperLink,
        ]
                
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let imageData = image.jpegData(compressionQuality: 1)
        request.httpBody = createBodyWithParameters(parameters: parameters, filePathKey: "image", imageDataKey: imageData! as NSData, boundary: boundary, imgKey: "image") as Data
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
                        
            do {
                let decoder = JSONDecoder()
                let str = String(decoding: data, as: UTF8.self)
                print(str)
                let response = try decoder.decode(Message.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.nonConformingData))
            }
            
        }
        task.resume()
        
        
    }
    
}

//https://gist.github.com/sye8/32b064d2d11437c1463c5923fdf82daf
extension NetworkManager: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.host == "76.121.141.32" {
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}


func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
}

func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String, imgKey: String) -> NSData {
        let body = NSMutableData();

        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }

        let filename = "\(imgKey).jpg"
        let mimetype = "image/jpg"

        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        body.appendString(string: "--\(boundary)--\r\n")

        return body
}
