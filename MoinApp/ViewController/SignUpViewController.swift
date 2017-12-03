//
//  SignUpViewController.swift
//  MoinApp
//
//  Created by Sören Gade on 03.12.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit

protocol SignUpViewControllerDelegate: class {
    func signUpViewController(_ viewController: SignUpViewController, provides username: String, password: String, email: String)
}

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!

    public weak var delegate: SignUpViewControllerDelegate?

    @IBAction func signUpTapped(_ sender: UIButton) {
        guard let username = self.usernameTextField.text,
            let password = self.passwordTextField.text,
            let passwordConfirm = self.passwordConfirmTextField.text,
            password == passwordConfirm,
            let email = self.emailTextField.text else {
                return
        }

        self.delegate?.signUpViewController(self, provides: username, password: password, email: email)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.usernameTextField.becomeFirstResponder()
        self.passwordTextField.text = ""
        self.passwordConfirmTextField.text = ""
    }
    
}
