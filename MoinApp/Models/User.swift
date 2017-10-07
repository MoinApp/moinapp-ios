//
//  User.swift
//  MoinApp
//
//  Created by Sören Gade on 01.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import Foundation

struct User : Decodable {
    let id: String
    let username: String
    let email_hash: String
}

extension User : Equatable {
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id && lhs.username == rhs.username && lhs.email_hash == rhs.email_hash
    }
}

struct Users {
    let elements: [User]
}

extension Users : Equatable {
    static func ==(lhs: Users, rhs: Users) -> Bool {
        guard lhs.elements.count == rhs.elements.count else {
            return false
        }

        for i in 0..<lhs.elements.count {
            if lhs.elements[i] != rhs.elements[i] {
                return false
            }
        }

        return true
    }
}
