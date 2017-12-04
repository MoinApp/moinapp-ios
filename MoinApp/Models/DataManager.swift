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

    func update(image: UIImage, for user: User)
}

extension DataManagerUpdates {
    func needsAuthentication() {
        
    }

    func update(users: [User], from: [User]) {

    }

    func update(image: UIImage, for user: User) {
        
    }
}

class DataManager {

    private let restManager: RestManager
    private let gravatar: Gravatar
    let eventBus: EventBus

    private(set) var users: [User] = []
    func image(for user: User) -> UIImage? {
        let image = self.gravatar.cachedImage(for: user.email_hash)

        if image == nil {
            self.gravatar.image(forHash: user.email_hash, completion: { (result) in
                switch result {
                case .success(let image):
                    self.change(to: image, for: user)
                default:
                    break
                }
            })
        }

        return image
    }

    public var username: String? {
        return self.restManager.username
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

    private func change(to image: UIImage, for user: User) {
        self.eventBus.notify(DataManagerUpdates.self) { (s) in
            s.update(image: image, for: user)
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
                self.onLogin()
            }
        }
    }

    func signUp(as username: String, with password: String, andEmail email: String) {
        self.restManager.signUp(as: username, password: password, withEmail: email) { (result) in
            switch result {
            case .error(let error):
                print("Error signing up: \( error ).")
                self.notifyOfUnauthentication()
            case .success(_):
                self.onLogin()
            }
        }
    }

    private func onLogin() {
        self.updateUsers()

        OperationQueue.main.addOperation {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.setupRemoteNotifications()
            }
        }
    }

    func logout() {
        self.restManager.unauthenticate()
        self.notifyOfUnauthentication()
    }

    func search(for username: String, completion: @escaping (Result<Users>) -> Void) {
        self.restManager.search(for: username, completion: completion)
    }

    func moin(username: String, completion: @escaping (Result<Bool>) -> Void) {
        self.restManager.moin(user: username, completion: { (result: Result<Bool>) in

            switch result {
            case .success(_):
                self.updateUsers()
            default:
                break
            }

            completion(result)
        })
    }
}
