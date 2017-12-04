//
//  TokenManager.swift
//  MoinApp
//
//  Created by Sören Gade on 07.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import Foundation
import KeychainSwift

class TokenManager {
    private static let usernameToken = "username"
    private static let tokenKey = "token"

    private let keychain: KeychainSwift

    init() {
        self.keychain = KeychainSwift()
    }

    var sessionToken: String? {
        return self.keychain.get(TokenManager.tokenKey)
    }

    var username: String? {
        return self.keychain.get(TokenManager.usernameToken)
    }

    func save(token: String, for username: String) {
        self.keychain.set(username, forKey: TokenManager.usernameToken)
        self.keychain.set(token, forKey: TokenManager.tokenKey)
    }

    func clear() {
        self.keychain.delete(TokenManager.usernameToken)
        self.keychain.delete(TokenManager.tokenKey)
    }
}
