//
//  VideoCell.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 08/03/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class VideoCell: UITableViewCell {

    // MARK: - IBOutlets / class properties
    @IBOutlet var youtubePlayer: YTPlayerView!
    
    // MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        youtubePlayer.translatesAutoresizingMaskIntoConstraints = false
        youtubePlayer.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Public methods
    func setupVideoCellWith(videoID: String) {
        youtubePlayer.load(withVideoId: videoID)
    }
}
