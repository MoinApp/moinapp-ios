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

    case endpointError(Int, RestError?)
}

class RestManager {
    private let baseURL = URL(string: "https://moinapp.herokuapp.com/api")!

    private let urlSession: URLSession

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    func moin(user username: String, completion: @escaping (Result<Bool>) -> Void) {
        let moinReceiver = MoinReceiver(username: username)

        self.request(endpoint: "/moin", withData: moinReceiver) { result in
            switch ( result ) {
            case .error(let error):
                completion(.error(error))

            case .success(let data):
                print("data: \(data)")
                completion(.success(true))
            }
        }
    }

    private func request<T>(endpoint: String, withData payload: T, completion: @escaping (Result<Data>) -> Void) where T : Encodable {
        let endpointURL = self.baseURL.appendingPathComponent(endpoint)

        let jsonEncoder = JSONEncoder()
        guard let payloadData = try? jsonEncoder.encode(payload) else {
            return completion(.error(RestManagerError.invalidPayload))
        }

        var urlRequest = URLRequest(url: endpointURL)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = payloadData
        let task = self.urlSession.dataTask(with: urlRequest) { (data: Data?, urlResponse: URLResponse?, error: Error?) in
            guard error == nil else {
                return completion(.error(error!))
            }

            guard let response = urlResponse as? HTTPURLResponse,
                let data = data else {
                    return completion(.error(RestManagerError.invalidState))
            }

            guard response.statusCode == 200 else {
                let jsonDecoder = JSONDecoder()
                let errorInfo = try? jsonDecoder.decode(RestError.self, from: data)

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

struct MoinReceiver : Encodable {
    let username: String
}
