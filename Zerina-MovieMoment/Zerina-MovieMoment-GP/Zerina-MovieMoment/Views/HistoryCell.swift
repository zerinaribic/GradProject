//
//  HistoryCell.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 29/04/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit
import SDWebImage

class HistoryCell: UITableViewCell {

    // MARK: - IBOutlets / class properties
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var historyImageView: UIImageView!


    // MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Public ethods
    func setupCell(withContent content: History) {
        movieTitleLabel.text = content.movieTitle
        moodLabel.text = content.currentMood
        dateTimeLabel.text = content.date

        let imageUrl = URL(string: content.imageUrl)
        let options = SDWebImageOptions()
        historyImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "PlaceholderProfileImage"), options: options, completed: { (image, error, cacheType, url) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }
}
