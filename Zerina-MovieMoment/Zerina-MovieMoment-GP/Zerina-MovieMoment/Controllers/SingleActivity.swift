//
//  SingleActivity.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 08/03/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//


import UIKit
import Alamofire
import SDWebImage
import SwiftyJSON
import Firebase

class SingleActivity: UIViewController {

    // MARK: - IBOutlets / class properties
    @IBOutlet weak var tableView: UITableView!
    var fbServiceManager : FirebaseServiceManager!
    var movieID = ""
    var movieTitle = ""
    var moviePlot = ""
    var posterUrl = ""
    var averageRating = 0.0
    var videos = [Video]()
    var genres = [String]()

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureTableView()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(displayActionSheet))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        title = movieTitle
        fetchMovie(id: movieID)
        fbServiceManager = FirebaseServiceManager()
    }

    // Mark: - Private methods
    /// Configures the tableview
    private func ConfigureTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        // Register cells with tableView
        let photoCell = UINib(nibName: "PhotoCell", bundle: nil)
        let videoCell = UINib(nibName: "VideoCell", bundle: nil)
        let overviewCell = UINib(nibName: "OverviewCell", bundle: nil)
        let detailsCell = UINib(nibName: "DetailsCell", bundle: nil)
        tableView.register(photoCell, forCellReuseIdentifier: "PhotoCell")
        tableView.register(videoCell, forCellReuseIdentifier: "VideoCell")
        tableView.register(overviewCell, forCellReuseIdentifier: "OverviewCell")
        tableView.register(detailsCell, forCellReuseIdentifier: "DetailsCell")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }

    /// Returns a current date and time as a string
    private func getDateTime() -> String {
        let dateTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d/M/yy/hh/mm"
        let dateTimeString = dateFormatter.string(from: dateTime)
        return dateTimeString
    }

    /// Provides a suttle haptic feedback
    private func provideHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Saves the relevant data to the history when the "Mark as Watched" button gets pressed
    private func saveToHistory() {
        let dateTime = getDateTime()
        let historyData = History(date: dateTime, movieTitle: movieTitle, movieID: movieID, currentMood: TemporaryInfo.currentEmotion, imageUrl: TemporaryInfo.currentImageUrl)
        guard let userID = Auth.auth().currentUser?.uid else {return}
        fbServiceManager.saveToHistory(userID: userID, movieID: movieID, historyData: historyData) { [weak self] (error) in
            if let error = error {
                print(error)
            } else {
                print("Data saved to history")
                self?.provideHapticFeedback()
            }
        }
    }

    /// Displays the action sheet for the movie actions button
    @objc private func displayActionSheet() {
        let sheet = UIAlertController(title: movieTitle, message: "What would you like to do?", preferredStyle: .actionSheet)
        let markAsWatched = UIAlertAction(title: "Mark as watched", style: .default) { (alertAction) in
            self.saveToHistory()
        }
        let recommend = UIAlertAction(title: "Recommend this movie", style: .default) { (alertAction) in
            let dataToShare = "Hi, I have just found an interesting movie called \(self.movieTitle)\nIt's rating is: \(self.averageRating)\nPlot: \(self.moviePlot)"
            let activityController = UIActivityViewController(activityItems: [dataToShare], applicationActivities: nil)
            activityController.excludedActivityTypes = [UIActivityType.postToFacebook]
            self.present(activityController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        sheet.addAction(markAsWatched)
        sheet.addAction(recommend)
        sheet.addAction(cancel)
        present(sheet, animated: true, completion: nil)
    }

    /// Fetches a single movie by it's ID
    private func fetchMovie(id: String) {
        Alamofire.request("\(Constants.TMDBMovieBaseUrl)\(id)?api_key=\(Constants.TMDBAPIKey)&append_to_response=videos").responseJSON { [weak self] (response) in
            if let result = response.result.value {
                let json = JSON(result)
                self?.videos.removeAll()
                self?.genres.removeAll()
                for genre in json["genres"].arrayValue {
                    let name = genre["name"].stringValue
                    self?.genres.append(name)
                }
                for video in json["videos"]["results"].arrayValue {
                    let id = video["id"].stringValue
                    let key = video["key"].stringValue
                    let site = video["site"].stringValue
                    let type = video["type"].stringValue
                    let singleVideo = Video(id: id, key: key, site: site, type: type)
                    self?.videos.append(singleVideo)
                }
                self?.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableView dataSource and delegate methods
extension SingleActivity: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detailsCell = tableView.dequeueReusableCell(withIdentifier: "DetailsCell", for: indexPath) as! DetailsCell
        if indexPath.row == 0 {
            let photoCell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
            photoCell.posterImage.sd_setImage(with: URL(string: "\(Constants.TMDBImageBaseUrl)\(posterUrl)"), completed: { (image, error, cacheType, url) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
            return photoCell
        }
        if indexPath.row == 1 {
            let videoCell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
            guard let videoID = videos.first?.key else {return videoCell}
            videoCell.setupVideoCellWith(videoID: videoID)
            return videoCell
        }
        if indexPath.row == 2 {
            let overviewCell = tableView.dequeueReusableCell(withIdentifier: "OverviewCell", for: indexPath) as! OverviewCell
            overviewCell.setupOverviewCellWith(content: moviePlot)
            return overviewCell
        }
        if indexPath.row == 3 {
            detailsCell.setGenres(genres: genres)
            return detailsCell
        }
        let rating = String(averageRating)
        detailsCell.setupDetailsCellWithContent(title: "Rating", content: rating)
        return detailsCell
    }
}
