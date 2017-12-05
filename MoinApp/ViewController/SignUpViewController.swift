//
//  SignUpViewController.swift
//  MoinApp
//
//  Created by Sören Gade on 03.12.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, DataManagerUpdates {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var haveAccountButton: UIButton!
    
    public weak var dataManager: DataManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataManager.eventBus.add(subscriber: self, for: DataManagerUpdates.self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.dataManager.eventBus.add(subscriber: self, for: DataManagerUpdates.self)
    }

    private func setUI(toState enabled: Bool) {
        self.usernameTextField.isEnabled = enabled
        self.passwordTextField.isEnabled = enabled
        self.passwordConfirmTextField.isEnabled = enabled
        self.emailTextField.isEnabled = enabled
        self.signUpButton.isEnabled = enabled
        self.haveAccountButton.isEnabled = enabled
    }

    @IBAction func signUpTapped(_ sender: UIButton) {
        guard let username = self.usernameTextField.text,
            let password = self.passwordTextField.text,
            let passwordConfirm = self.passwordConfirmTextField.text,
            password == passwordConfirm,
            let email = self.emailTextField.text else {
                return
        }

        self.setUI(toState: false)
        self.dataManager.signUp(as: username, with: password, andEmail: email) { (result) in
            OperationQueue.main.addOperation {
                self.setUI(toState: true)

                if case let Result.error(error) = result {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.usernameTextField.becomeFirstResponder()
        self.passwordTextField.text = ""
        self.passwordConfirmTextField.text = ""
    }

//MARK: DataManagerUpdates
    func isAuthenticated() {
        // dismissed by parent
    }

    func needsAuthentication() {
        // failed
    }
    
}
