//
//  SettingsCell.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 29/03/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    // MARK: - Public methods
    /// Setts up the content based on the current indexPath
    func setupCellWithContentAt(index: Int) {
        switch index {
        case 1:
            titleLabel.text = "Your mood history"
        case 2:
            titleLabel.text = "Notifications"
        case 3:
            titleLabel.text = "Third-party notices"
        case 4:
            titleLabel.text = "About the app"
        case 5:
            titleLabel.text = "Log out"
        default:
            titleLabel.text = ""
        }
    }

}
