//
//  UserTableViewCell.swift
//  MoinApp
//
//  Created by Sören Gade on 01.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    static let identifier = "UserTableViewCell"

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    func configure(withUser user: User, gravatar: Gravatar) {
        self.usernameLabel.text = user.username

        gravatar.image(forHash: user.email_hash) { (result) in
            switch result {
            case .error(let error):
                print("Error loading avatar for \( user.username ): \( error ).")

            case .success(let image):
                OperationQueue.main.addOperation {
                    self.avatarImageView.image = image
                }
            }
        }
    }
}
