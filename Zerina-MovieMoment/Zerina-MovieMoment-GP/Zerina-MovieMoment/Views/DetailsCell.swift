//
//  DetailsCell.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 08/03/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit

class DetailsCell: UITableViewCell {

    // MARK: - IBOutlets / class properties
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var contentDescription: UILabel!


    // MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Public methods
    func setupDetailsCellWithContent(title: String, content: String) {
        contentTitle.text = title
        contentDescription.text = content
    }

    /// Sets up the content when genres are provided
    func setGenres(genres: [String]) {
        contentTitle.text = "Genres"
        contentDescription.text = ""
        for genre in genres {
            contentDescription.text?.append("\(genre), ")
        }
    }

}
