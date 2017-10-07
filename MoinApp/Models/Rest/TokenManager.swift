//
//  TokenManager.swift
//  MoinApp
//
//  Created by Sören Gade on 07.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import Foundation

class TokenManager {
    private let urlSession: URLSession

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    private(set) var sessionToken = ""

    func save(token: String) {
        self.sessionToken = token
    }
}
