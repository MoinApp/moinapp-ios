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
    private static let tokenKey = "token"

    private let keychain: KeychainSwift

    init() {
        self.keychain = KeychainSwift()
    }

    var sessionToken: String? {
        return self.keychain.get(TokenManager.tokenKey)
    }

    func save(token: String) {
        self.keychain.set(token, forKey: TokenManager.tokenKey)
    }
}
