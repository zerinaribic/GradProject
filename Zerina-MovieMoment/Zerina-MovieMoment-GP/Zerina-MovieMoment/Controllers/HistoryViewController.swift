//
//  HistoryViewController.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 29/04/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit
import Firebase

class HistoryViewController: UIViewController {

    // MARK: - IBOutlets / class properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var historyModePicker: UISegmentedControl!
    var watchedMovies = [History]()

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        fetchHistoryData()
    }

    // MARK: - IBActions
    @IBAction func historyModeChanged(_ sender: UISegmentedControl) {
        let segmentIndex = sender.selectedSegmentIndex
        title = sender.titleForSegment(at: segmentIndex)
    }

    // MARK: - Private methods
    /// Sets up the tableView
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        let historyCell = UINib(nibName: "HistoryCell", bundle: nil)
        tableView.register(historyCell, forCellReuseIdentifier: "HistoryCell")
    }

    /// Sets up the navigation bar
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        let segmentIndex = historyModePicker.selectedSegmentIndex
        title = historyModePicker.titleForSegment(at: segmentIndex)
    }

    /// Fetches the history data
    private func fetchHistoryData() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let dbReference = Firestore.firestore().collection("\(userID)/history/watched")
        dbReference.getDocuments { [weak self] (snapShot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self?.watchedMovies.removeAll()
                guard let documents = snapShot?.documents else {return}
                for document in documents {
                    guard let movieTitle = document.data()["movieTitle"] as? String else {return}
                    guard let movieID = document.data()["movieID"] as? String else {return}
                    guard let dateTime = document.data()["dateTime"] as? String else {return}
                    guard let imageUrl = document.data()["imageUrl"] as? String else {return}
                    guard let emotion = document.data()["currentMood"] as? String else {return}
                    let historyItem = History(date: dateTime, movieTitle: movieTitle, movieID: movieID, currentMood: emotion, imageUrl: imageUrl)
                    self?.watchedMovies.append(historyItem)
                }
                self?.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableView delegate and data source methods
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchedMovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let historyCell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        let historyData = watchedMovies[indexPath.row]
        historyCell.setupCell(withContent: historyData)
        return historyCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let historyData = watchedMovies[indexPath.row]
        print(historyData.movieTitle)
        performSegue(withIdentifier: "ToSingleHistoryItemViewController", sender: nil)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let movieData = watchedMovies[indexPath.row]
        if editingStyle == .delete {
            print("History item deleted \(movieData.movieTitle)")

            guard let userID = Auth.auth().currentUser?.uid else {return}
            let dbReference = Firestore.firestore().collection("\(userID)/history/watched")
            dbReference.document(movieData.movieID).delete { [weak self] (error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self?.watchedMovies.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}
