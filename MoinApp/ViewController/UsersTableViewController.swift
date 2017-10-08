//
//  UsersTableViewController.swift
//  MoinApp
//
//  Created by Sören Gade on 01.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit
import Swift_EventBus

class UsersTableViewController: UITableViewController, DataManagerUpdates {

    private let eventBus = EventBus()
    private var dataManager: DataManager!
    private var users: [User] = []

    override func viewDidLoad() {
        self.eventBus.add(subscriber: self, for: DataManagerUpdates.self)

        self.dataManager = DataManager(eventBus: self.eventBus)
        self.dataManager.begin()
    }

    private func presentLogin() {
        let loginController = UIAlertController(title: "Login", message: nil, preferredStyle: .alert)
        loginController.addAction(UIAlertAction(title: "Login", style: .default, handler: { (_) in
            guard let textFields = loginController.textFields else {
                return
            }

            let textFieldUsername = textFields[0]
            let textFieldPassword = textFields[1]

            self.dataManager.login(as: textFieldUsername.text!, with: textFieldPassword.text!)
        }))
        loginController.addTextField { (textField) in
            textField.placeholder = "Username"
        }
        loginController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }

        self.present(loginController, animated: true, completion: nil)
    }

//MARK: DataManagerUpdates
    func needsAuthentication() {
        OperationQueue.main.addOperation {
            self.presentLogin()
        }
    }

    func update(users: [User], from: [User]) {
        self.users = users
        OperationQueue.main.addOperation {
            self.tableView.reloadData()
        }
    }

//MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as! UserTableViewCell

        let user = self.users[indexPath.row]
        cell.configure(with: user, dataManager: self.dataManager)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipient = self.users[indexPath.row]

        let alertController = UIAlertController(title: "Moin", message: "Sending moin to \(recipient.username)...", preferredStyle: .alert)
        self.present(alertController, animated: true) {
            self.dataManager.restManager.moin(user: recipient.username, completion: { (result: Result<Bool>) in

                OperationQueue.main.addOperation {
                    switch result {
                    case .error(let error):
                        alertController.message = "Failed to moin \( recipient.username ): \( error )."
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    default:
                        alertController.dismiss(animated: true) {
                            tableView.deselectRow(at: indexPath, animated: true)
                        }
                    }
                }
            })
        }
    }
}
