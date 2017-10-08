//
//  UserTableViewCell.swift
//  MoinApp
//
//  Created by Sören Gade on 01.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell, DataManagerUpdates {
    static let identifier = "UserTableViewCell"

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    private(set) var representedUser: User?

    func configure(with user: User, dataManager: DataManager) {
        self.representedUser = user
        dataManager.eventBus.add(subscriber: self, for: DataManagerUpdates.self)

        self.usernameLabel.text = user.username

        self.avatarImageView.image = dataManager.image(for: user)
    }

    func update(image: UIImage, for user: User) {
        guard let repUser = self.representedUser,
            repUser == user else {
                return
        }

        self.avatarImageView.image = image
    }
}
