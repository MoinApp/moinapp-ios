//
//  LoginViewController.swift
//  MoinApp
//
//  Created by Sören Gade on 08.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, DataManagerUpdates {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var needAccountButton: UIButton!

    public weak var dataManager: DataManager!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.dataManager.eventBus.add(subscriber: self, for: DataManagerUpdates.self)

        self.usernameTextField.becomeFirstResponder()
        self.passwordTextField.text = ""
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.dataManager.eventBus.add(subscriber: self, for: DataManagerUpdates.self)
    }

    private func setUI(toState enabled: Bool) {
        self.usernameTextField.isEnabled = enabled
        self.passwordTextField.isEnabled = enabled
        self.loginButton.isEnabled = enabled
        self.needAccountButton.isEnabled = enabled
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        guard let username = self.usernameTextField.text,
            let password = self.passwordTextField.text else {
                return
        }

        self.setUI(toState: false)
        self.dataManager.login(as: username, with: password) { (_) in
            OperationQueue.main.addOperation {
                self.setUI(toState: true)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signUpVC = segue.destination as? SignUpViewController {
            signUpVC.dataManager = self.dataManager
        }
    }

    @IBAction func backFromSignUp(segue: UIStoryboardSegue) {
        // alright

        // transfer inputs
        if let signUpVC = segue.source as? SignUpViewController {
            guard let username = signUpVC.usernameTextField.text,
                username != "" else {
                    return
            }

            self.usernameTextField.text = username
        }
    }

//MARK: DataManagerUpdates
    func isAuthenticated() {
        if let signUpVC = self.presentedViewController {
            signUpVC.dismiss(animated: false, completion: nil)
        }

        self.dismiss(animated: true, completion: nil)
    }

    func needsAuthentication() {
        // login failed
    }
    
}
