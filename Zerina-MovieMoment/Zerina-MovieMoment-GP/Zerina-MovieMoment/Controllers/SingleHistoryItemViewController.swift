//
//  SingleHistoryItemViewController.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 05/05/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit

class SingleHistoryItemViewController: UIViewController {

    // MARK: - IBOutlets / class properties
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    // MARK: - Private methods
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        let photoCell = UINib(nibName: "PhotoCell", bundle: nil)
        tableView.register(photoCell, forCellReuseIdentifier: "PhotoCell")
    }
}

// MARK: - UITableview delegate and data source methods
extension SingleHistoryItemViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photoCell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        photoCell.posterImage.image = #imageLiteral(resourceName: "PlaceholderProfileImage")
        return photoCell
    }
}
