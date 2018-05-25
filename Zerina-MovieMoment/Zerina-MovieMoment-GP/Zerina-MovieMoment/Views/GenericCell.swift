//
//  GenericCell.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 01/04/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit

class GenericCell: UITableViewCell {

    // MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    // MARK: - Public methods
    func setupCellWith(user: User, tag: Int) {
        switch tag {
            case 1:
            textLabel?.text = user.profileName
        case 2:
            textLabel?.text = user.email
        default:
            print("")
        }
    }

}
