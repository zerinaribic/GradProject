/   /
//  Movie.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 06/03/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import Foundation

// Model for the single movie
struct Movie {
    var id : String
    var title: String
    var posterUrl : String
    var plot : String
    var voteAverage : Double
    var genreIDs : [Int]
}
