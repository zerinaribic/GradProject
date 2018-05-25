//
//  RecommendedActivitiesViewController.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 06/03/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import Firebase

class RecommendedActivitiesViewController: UIViewController {

    // MARK: - IBOutlets / class properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emotionLabel: UILabel!
    var movies = [Movie]()
    var movieData = [[String:String]]()
    let dispatchGroup = DispatchGroup()

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationController()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("GEnder \(TemporaryInfo.currentGender) Emotion: \(TemporaryInfo.currentEmotion)")
        DispatchQueue.main.async {
            self.emotionLabel.text = TemporaryInfo.currentEmotion
        }
        getMovieData()
        generateQuery(emotion: TemporaryInfo.currentEmotion, gender: TemporaryInfo.currentGender)
        dispatchGroup.notify(queue: .main) {
            self.collectionView.reloadData()
        }
    }

    // MARK: - IBActions
    @IBAction func didTapCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true) {
            NotificationCenter.default.post(name: .changeAlpha, object: self)
        }
    }


    // MARK: - Private methods
    /// Configures the navigation controller
    private func configureNavigationController() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barStyle = .blackTranslucent
        title = "For you"
    }

    /// Generates a search query based on current emotion and gender
    private func generateQuery(emotion: String, gender: String) {
        switch emotion {
        case "happiness":
            if gender == "male" {
                let query = "\(Genres.action),\(Genres.crime),\(Genres.comedy)"
                fetchMovies(query: query)
            } else {
                let query = "\(Genres.comedy),\(Genres.music),\(Genres.family)"
                fetchMovies(query: query)
            }
        case "neutral":
            if gender == "male" {
                let query = "\(Genres.crime),\(Genres.comedy)"
                fetchMovies(query: query)
            } else {
                let query = "\(Genres.comedy),\(Genres.family),\(Genres.romance)"
                fetchMovies(query: query)
            }
        case "sadness":
            if gender == "male" {
                let query = "\(Genres.animation),\(Genres.drama),\(Genres.comedy)"
                fetchMovies(query: query)
            } else {
                let query = "\(Genres.comedy),\(Genres.family),\(Genres.mistery)"
            }
        default:
            print("Default")
        }
    }

    /// Fetches the movies by the specified queries
    private func fetchMovies(query: String) {
        dispatchGroup.enter()
        Alamofire.request("\(Constants.TMDBAPIEndPoint)\(Constants.TMDBAPIKey)&sort_by=popularity.desc&include_video=true&include_adult=true&with_genres=\(query)").responseJSON { [weak self] (response) in
            if let result = response.result.value {
                self?.movies.removeAll()
                let json = JSON(result)
                for movie in json["results"].arrayValue {
                    let id = movie["id"].stringValue
                    let title = movie["title"].stringValue
                    let plot = movie["overview"].stringValue
                    let voteAverage = movie["vote_average"].doubleValue
                    let posterUrl = movie["poster_path"].stringValue

                    let singleMovie = Movie(id: id, title: title, posterUrl: posterUrl, plot: plot, voteAverage: voteAverage, genreIDs: [1,2,3])
                    self?.movies.append(singleMovie)
                }
                self?.dispatchGroup.leave()
            }
        }
    }

    /// Gets the movie IDs from the watched movies history
    private func getMovieData() {
        dispatchGroup.enter()
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let dbReference = Firestore.firestore().collection("\(userID)/history/watched")
        dbReference.getDocuments { [weak self] (snapShot, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            self?.movieData.removeAll()
            guard let documents = snapShot?.documents else {return}
            for document in documents {
                guard let id = document.data()["movieID"] as? String else {return}
                guard let movieTitle = document.data()["movieTitle"] as? String else {return}

                let movie = [id:movieTitle]
                self?.movieData.append(movie)
            }
            self?.dispatchGroup.leave()
        }
    }

    /// Checks whether the movie has been watched earlier
    private func isMovieWatched(movieID: String) -> Bool {
        for movie in movieData {
            if let id = movie[movieID] {
                print("The movie with ID: \(id) is already watched")
                return true
            } else {
                return false
            }
        }
        return false
    }

    /// Prepares the RecommendedActivitiesViewController for segue
    /// It also transfers a lot of movie data to the SingleActivityViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = collectionView.indexPath(for: sender as! RecommendedCell) else {return}
        let singleActivityVC = segue.destination as! SingleActivity
        let movie = movies[indexPath.item]
        singleActivityVC.movieID = movie.id
        singleActivityVC.movieTitle = movie.title
        singleActivityVC.moviePlot = movie.plot
        singleActivityVC.posterUrl = movie.posterUrl
        singleActivityVC.averageRating = movie.voteAverage
    }
}

// MARK: - UICollectionView delegate and dataSource methods
extension RecommendedActivitiesViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedCell", for: indexPath) as! RecommendedCell
        let movie = movies[indexPath.item]
        let posterUrl = "\(Constants.TMDBImageBaseUrl)\(movie.posterUrl)"
        cell.watchedLabel.isHidden = true
        for watchedMovie in movieData {
            if let movieTitle = watchedMovie[movie.id] {
                print("\(movieTitle) at indexPath: \(indexPath.item)")
                cell.watchedLabel.isHidden = false
            }
        }
        cell.activityTitle.text = movie.title
        cell.activityImage.sd_setImage(with: URL(string: posterUrl)) { (image, error, cache, url) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        return cell
    }

}
