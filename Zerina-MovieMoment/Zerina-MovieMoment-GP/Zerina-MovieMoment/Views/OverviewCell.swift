//
//  OverviewCell.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 08/03/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit

class OverviewCell: UITableViewCell {

    // MARK: - IBOutlets / class properties
    @IBOutlet weak var overviewText: UITextView!

    // MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Public methods
    func setupOverviewCellWith(content: String) {
        overviewText.text = content
    }

}
