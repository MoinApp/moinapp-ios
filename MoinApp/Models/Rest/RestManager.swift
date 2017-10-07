//
//  RestManager.swift
//  MoinApp
//
//  Created by Sören Gade on 07.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import Foundation

enum RestManagerError : Error {
    case invalidState
    case invalidPayload
    case invalidResponse
    case unauthenticated

    case endpointError(Int, RestError?)
}

class RestManager {
    private let baseURL = URL(string: "https://moinapp.herokuapp.com/api")!

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let urlSession: URLSession
    private let tokenManager: TokenManager

    init(urlSession: URLSession) {
        self.urlSession = urlSession

        self.tokenManager = TokenManager()
    }

    func authenticate(as username: String, password: String, completion: @escaping (Result<Bool>) -> Void) {
        let userLogin = UserLogin(username: username, password: password)

        self.request(endpoint: "/auth", withData: userLogin) { (result) in
            switch result {
            case .error(let error):
                completion(.error(error))
            case .success(let data):
                do {
                    let session = try self.decoder.decode(Session.self, from: data)
                    self.tokenManager.save(token: session.token)
                } catch {
                    return completion(.error(RestManagerError.invalidResponse))
                }

                completion(.success(true))
            }
        }
    }

    func recentUsers(completion: @escaping (Result<Users>) -> Void) {
        self.get(endpoint: "/user/recents") { (result) in
            switch result {
            case .error(let error):
                completion(.error(error))
            case .success(let data):
                guard let users = try? self.decoder.decode([User].self, from: data) else {
                    return completion(.error(RestManagerError.invalidResponse))
                }
                let usersObject = Users(elements: users)
                completion(.success(usersObject))
            }
        }
    }

    func moin(user username: String, completion: @escaping (Result<Bool>) -> Void) {
        let moinReceiver = MoinReceiver(username: username)

        self.request(endpoint: "/moin", withData: moinReceiver) { result in
            switch ( result ) {
            case .error(let error):
                completion(.error(error))

            case .success(_):
                completion(.success(true))
            }
        }
    }

    private func get(endpoint: String, completion: @escaping (Result<Data>) -> Void) {
        let value: String? = nil
        self.request(endpoint: endpoint, withData: value, completion: completion)
    }
    private func request<T>(endpoint: String, withData payload: T?, completion: @escaping (Result<Data>) -> Void) where T : Encodable {
        let endpointURL = self.baseURL.appendingPathComponent(endpoint)

        var urlRequest = URLRequest(url: endpointURL)
        urlRequest.addValue("Moin-iOS", forHTTPHeaderField: "User-Agent")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        if let sessionToken = self.tokenManager.sessionToken {
            urlRequest.addValue(sessionToken, forHTTPHeaderField: "Authorization")
        }

        if let payload = payload {
            guard let payloadData = try? self.encoder.encode(payload) else {
                return completion(.error(RestManagerError.invalidPayload))
            }

            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = payloadData
        }

        let task = self.urlSession.dataTask(with: urlRequest) { (data: Data?, urlResponse: URLResponse?, error: Error?) in
            guard error == nil else {
                return completion(.error(error!))
            }

            guard let response = urlResponse as? HTTPURLResponse,
                let data = data else {
                    return completion(.error(RestManagerError.invalidState))
            }

            guard response.statusCode == 200 else {
                if response.statusCode == 403 {
                    self.tokenManager.clear()
                    return completion(.error(RestManagerError.unauthenticated))
                }

                let errorInfo = try? self.decoder.decode(RestError.self, from: data)

                return completion(.error(RestManagerError.endpointError(response.statusCode, errorInfo)))
            }

            completion(.success(data))
        }
        task.resume()
    }
}

struct RestError : Decodable {
    let code: String
    let message: String
    let fields: String?
}

struct UserLogin : Encodable {
    let username: String
    let password: String
}

struct Session : Decodable {
    let token: String
}

struct MoinReceiver : Encodable {
    let username: String
}
