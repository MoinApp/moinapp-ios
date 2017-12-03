//
//  UsersTableViewController.swift
//  MoinApp
//
//  Created by Sören Gade on 01.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit
import Swift_EventBus

class UsersTableViewController: UITableViewController, DataManagerUpdates, UISearchResultsUpdating, LoginViewControllerDelegate, SignUpViewControllerDelegate {

    private let eventBus = EventBus()
    private var dataManager: DataManager!
    private var users: [User] = []

    override func viewDidLoad() {
        self.eventBus.add(subscriber: self, for: DataManagerUpdates.self)

        self.dataManager = DataManager(eventBus: self.eventBus)
        self.dataManager.begin()

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }

    @IBAction func logout(_ sender: UIBarButtonItem) {
        self.dataManager.logout()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let loginVC = segue.destination as? LoginViewController {
            loginVC.setDelegates(forLogin: self, andSignup: self)
        }
    }

//MARK: LoginViewControllerDelegate

    func loginViewController(_ viewController: LoginViewController, provides username: String, and password: String) {
        viewController.dismiss(animated: true, completion: nil)

        self.dataManager.login(as: username, with: password)
    }

//MARK:

    func signUpViewController(_ viewController: SignUpViewController, provides username: String, password: String, email: String) {
        if let loginVC = viewController.presentingViewController as? LoginViewController {
            viewController.dismiss(animated: false) {
                loginVC.dismiss(animated: false, completion: nil)
            }
        }

        self.dataManager.signUp(as: username, with: password, andEmail: email)
    }

//MARK: UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let search = searchController.searchBar.text?.lowercased(),
            !search.isEmpty else {
                self.users = self.dataManager.users
                self.tableView.reloadData()
                return
        }

        self.users = self.dataManager.users.filter { (user) -> Bool in
            return user.username.lowercased().contains(search)
        }
        self.tableView.reloadData()

        self.dataManager.search(for: search) { (result) in
            switch result {
            case .error(let error):
                print("Error searching for \(search): \(error).")
            case .success(let users):
                self.users = users.elements
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
//MARK: DataManagerUpdates
    func needsAuthentication() {
        OperationQueue.main.addOperation {
            self.performSegue(withIdentifier: "showLoginSegue", sender: self)
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

        let areWeInSearch = Users(elements: self.users) != Users(elements: self.dataManager.users)

        let alertController = UIAlertController(title: "Moin", message: "Sending moin to \(recipient.username)...", preferredStyle: .alert)
        self.present(alertController, animated: true) {
            self.dataManager.moin(username: recipient.username, completion: { (result) in
                OperationQueue.main.addOperation {
                    switch result {
                    case .error(let error):
                        alertController.message = "Failed to moin \( recipient.username ): \( error )."
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    default:
                        alertController.dismiss(animated: true) {
                            tableView.deselectRow(at: indexPath, animated: true)

                            if areWeInSearch {
                                self.navigationItem.searchController?.dismiss(animated: true) {
                                    self.navigationItem.searchController?.searchBar.text = ""
                                }

                                self.users = self.dataManager.users
                                self.tableView.reloadData()
                            }

                        }
                    }
                }
            })
        }
    }
}
