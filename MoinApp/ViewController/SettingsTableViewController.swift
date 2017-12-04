//
//  SettingsTableViewController.swift
//  MoinApp
//
//  Created by Sören Gade on 04.12.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    private static let sourceCodeURL = URL(string: "https://github.com/MoinApp/moinapp-ios")!

    @IBOutlet weak var signedInAsLabel: UILabel!
    
    public weak var dataManager: DataManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.signedInAsLabel.text = "Signed in as ?"
    }

//MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 1): // logout
            // TODO
            break
            
        case (1, 0): // source code
            self.openSourceCodeURL(completion: { (_) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
        case (1, 1): // acknowledgements
            // do not deselect row by hand
            break
        default:
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    private func openSourceCodeURL(completion: ((Bool) -> Void)? = nil) {
        UIApplication.shared.open(SettingsTableViewController.sourceCodeURL, options: [:], completionHandler: completion)
    }
}
