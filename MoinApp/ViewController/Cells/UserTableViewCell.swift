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

    func configure(with user: User, dataManager: DataManager) {
        self.usernameLabel.text = user.username

        self.avatarImageView.image = dataManager.image(for: user)
    }
}
