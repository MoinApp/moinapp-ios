//
//  UsersTableViewController.swift
//  MoinApp
//
//  Created by Sören Gade on 01.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {

    private let mockData = [
        User(id: "1", name: "sgade", password: nil, email: "58a3ac45170c5815f333fce4d9158696"),
        User(id: "2", name: "jhbruhn", password: nil, email: "7b0ad26f7447ed5e4f9e0ac671f07057"),
        User(id: "3", name: "Gerrits Puff", password: nil, email: ""),
    ]

    private var restManager: RestManager!

    override func viewDidLoad() {
        self.restManager = RestManager(urlSession: URLSession.shared)
    }

//MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mockData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as! UserTableViewCell

        let user = self.mockData[indexPath.row]
        cell.configure(withUser: user)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipient = self.mockData[indexPath.row]

        let alertController = UIAlertController(title: "Moin", message: "Sending moin to \(recipient.name)...", preferredStyle: .alert)
        self.present(alertController, animated: true) {
            self.restManager.moin(user: recipient.name, completion: { (result: Result<Bool>) in

                OperationQueue.main.addOperation {
                    switch result {
                    case .error(let error):
                        alertController.message = "Failed to moin \( recipient.name ): \( error )."
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
