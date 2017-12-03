//
//  SignUpViewController.swift
//  MoinApp
//
//  Created by Sören Gade on 03.12.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
    @IBOutlet weak var signUpTapped: UIButton!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.usernameTextField.becomeFirstResponder()
        self.passwordTextField.text = ""
        self.passwordConfirmTextField.text = ""
    }
    
}
