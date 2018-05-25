//
//  SettingsViewController.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 24/03/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    var usr : User!
    var firebaseServiceManager :  FirebaseServiceManager!

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        configureNavigationController()
        firebaseServiceManager = FirebaseServiceManager()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        firebaseServiceManager.getUser { [weak self] (user) in
            if let user = user {
                self?.usr = user
            }
        }
    }

    // MARK: - Private methods
    /// Sets up the tableview
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        // Configure the row height
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension

        // Register cells
        let profilePhotoCell = UINib(nibName: "ProfilePhotoCell", bundle: nil)
        let settingsCell = UINib(nibName: "SettingsCell", bundle: nil)
        tableView.register(settingsCell, forCellReuseIdentifier: "SettingsCell")
        tableView.register(profilePhotoCell, forCellReuseIdentifier: "ProfilePhotoCell")
    }

    /// Configures the navigation bar (e.g. adds the title and bar buttons)
    private func configureNavigationController() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Settings"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissSettingsVC))
    }

    /// Dismisses the SettingsViewController
    @objc private func dismissSettingsVC() {
        dismiss(animated: true, completion: nil)
    }

    /// Displays the action sheet when logging out
    private func logOut() {
        let sheet = UIAlertController(title: "Log out?", message: "You are about to log out from your account.", preferredStyle: .actionSheet)
        let continueAction = UIAlertAction(title: "Continue", style: .default) { (alertAction) in
            self.firebaseServiceManager.logOut {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                self.present(loginViewController, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(continueAction)
        sheet.addAction(cancel)
        present(sheet, animated: true, completion: nil)
    }
}

// MARK: - UITableView delegate and data source methods
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profilePhotoCell = tableView.dequeueReusableCell(withIdentifier: "ProfilePhotoCell", for: indexPath) as! ProfilePhotoCell
        let settingsCell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        switch indexPath.row {
        case 0:
            profilePhotoCell.profilePhoto.image = #imageLiteral(resourceName: "PlaceholderProfileImage")
            profilePhotoCell.setupCell(withContent: usr)
            return profilePhotoCell
        default:
            settingsCell.setupCellWithContentAt(index: indexPath.row)
            return settingsCell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "ToProfileViewController", sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        case 1:
            performSegue(withIdentifier: "ToHistoryViewController", sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        case 5:
            logOut()
        default:
            print("TODO")
        }
    }
}
