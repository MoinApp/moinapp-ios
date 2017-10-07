//
//  UsersTableViewController.swift
//  MoinApp
//
//  Created by Sören Gade on 01.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {

    private var users = [User]()

    private var restManager: RestManager!
    private var gravatar: Gravatar!

    override func viewDidLoad() {
        let urlSession = URLSession.shared
        self.restManager = RestManager(urlSession: urlSession)
        self.gravatar = Gravatar(urlSession: urlSession)

        self.restManager.recentUsers { (result) in
            switch result {
            case .error(let error):
                switch error {
                case RestManagerError.unauthenticated:
                    OperationQueue.main.addOperation {
                        self.presentLogin()
                    }
                default:
                    print("Error getting users: \( error ).")
                }

            case .success(let users):
                self.users = users.elements
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
        }
    }

    private func presentLogin() {
        let loginController = UIAlertController(title: "Login", message: nil, preferredStyle: .alert)
        loginController.addAction(UIAlertAction(title: "Login", style: .default, handler: { (_) in
            guard let textFields = loginController.textFields else {
                return
            }

            let textFieldUsername = textFields[0]
            let textFieldPassword = textFields[1]

            self.restManager.authenticate(as: textFieldUsername.text!, password: textFieldPassword.text!, completion: { (result) in
                switch result {
                case .error(let error):
                    print("Could not login: \(error).")
                default:
                    break
                }
            })
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
        cell.configure(withUser: user, gravatar: self.gravatar)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipient = self.users[indexPath.row]

        let alertController = UIAlertController(title: "Moin", message: "Sending moin to \(recipient.username)...", preferredStyle: .alert)
        self.present(alertController, animated: true) {
            self.restManager.moin(user: recipient.username, completion: { (result: Result<Bool>) in

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
