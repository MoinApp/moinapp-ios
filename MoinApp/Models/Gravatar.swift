//
//  Gravatar.swift
//  MoinApp
//
//  Created by Sören Gade on 07.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit

enum GravatarError : Error {
    case invalidImageData
}

class Gravatar {
    private static let baseURL = URL(string: "https://www.gravatar.com/avatar")!

    private let urlSession: URLSession

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    func image(forHash hash: String, completion: @escaping (Result<UIImage>) -> Void) {
        let url = Gravatar.baseURL.appendingPathComponent(hash)

        let task = self.urlSession.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                return completion(.error(error!))
            }
            guard let data = data,
                let image = UIImage(data: data) else {
                    return completion(.error(GravatarError.invalidImageData))
            }

            completion(.success(image))
        }
        task.resume()
    }
}
