//
//  ProfilePhotoCell.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 31/03/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit
import SDWebImage

class ProfilePhotoCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!

    // MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2
    }

    /// Sets up profile photo cell with content
    func setupCell(withContent content: User) {
        if let imageUrl = content.imageUrl {
            profilePhoto.sd_setImage(with: imageUrl) { (image, error, cacheType, url) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        profileNameLabel.text = content.profileName
    }


}
