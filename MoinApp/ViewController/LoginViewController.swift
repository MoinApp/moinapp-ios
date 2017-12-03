//
//  LoginViewController.swift
//  MoinApp
//
//  Created by Sören Gade on 08.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: class {
    func loginViewController(_ viewController: LoginViewController, provides username: String, and password: String)
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    public weak var delegate: LoginViewControllerDelegate?
    public weak var signUpDelegate: SignUpViewControllerDelegate?

    public func setDelegates(forLogin loginDelegate: LoginViewControllerDelegate?, andSignup signupDelegate: SignUpViewControllerDelegate?) {
        self.delegate = loginDelegate
        self.signUpDelegate = signupDelegate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.usernameTextField.becomeFirstResponder()
        self.passwordTextField.text = ""
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        guard let username = self.usernameTextField.text,
            let password = self.passwordTextField.text else {
                return
        }

        self.delegate?.loginViewController(self, provides: username, and: password)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let signUpVC = segue.destination as? SignUpViewController {
            signUpVC.delegate = self.signUpDelegate
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
}
