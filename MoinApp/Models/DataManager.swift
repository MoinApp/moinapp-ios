//
//  DataManager.swift
//  MoinApp
//
//  Created by Sören Gade on 07.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit
import Swift_EventBus

protocol DataManagerUpdates {
    func needsAuthentication()
    func update(users: [User], from: [User])
}

class DataManager {

    let restManager: RestManager
    private let gravatar: Gravatar
    private let eventBus: EventBus

    private(set) var users: [User] = []
    func image(for user: User) -> UIImage? {
        return self.gravatar.cachedImage(for: user.email_hash)
    }

    private func notifyOfUnauthentication() {
        self.eventBus.notify(DataManagerUpdates.self) { (s) in
            s.needsAuthentication()
        }
    }

    private func change(to newUsers: [User]) {
        let oldValue = self.users
        self.users = newUsers

        self.eventBus.notify(DataManagerUpdates.self) { s in
            s.update(users: newUsers, from: oldValue)
        }
    }

    init(eventBus: EventBus) {
        let urlSession = URLSession.shared
        self.restManager = RestManager(urlSession: urlSession)
        self.gravatar = Gravatar(urlSession: urlSession)
        self.eventBus = eventBus
    }

    func begin() {
        self.updateUsers()
    }

    func stop() {
        
    }

    private func updateUsers() {
        self.restManager.recentUsers { (result) in
            switch result {
            case .error(let error):
                switch error {
                case RestManagerError.unauthenticated:
                    self.notifyOfUnauthentication()
                    break
                default:
                    print("Error getting users: \( error ).")
                }

            case .success(let users):
                self.change(to: users.elements)
            }
        }
    }

    func login(as username: String, with password: String) {
        self.restManager.authenticate(as: username, password: password) { (result) in
            switch result {
            case .error(let error):
                print("Error authenticating: \( error ).")
                self.notifyOfUnauthentication()
            case .success(_):
                self.updateUsers()
            }
        }
    }
}
