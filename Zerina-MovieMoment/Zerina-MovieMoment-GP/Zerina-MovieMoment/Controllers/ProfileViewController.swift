//
//  ProfileViewController.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 01/04/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    // MARK: - IBOutlets / class properties
    @IBOutlet weak var tableView: UITableView!
    var usr : User!
    var firebaseServiceManager: FirebaseServiceManager!
    var imagePicker: UIImagePickerController!

    // MARK: - Lifecycle mtehods
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseServiceManager = FirebaseServiceManager()
        setupTableView()
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
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60

        let profilePhotoCell = UINib(nibName: "ProfilePhotoCell", bundle: nil)
        let genericCell = UINib(nibName: "GenericCell", bundle: nil)
        tableView.register(profilePhotoCell, forCellReuseIdentifier: "ProfilePhotoCell")
        tableView.register(genericCell, forCellReuseIdentifier: "GenericCell")
    }

    /// Displays the imagePicker
    private func showImagePicker(withSourceType sourceType: UIImagePickerControllerSourceType) {
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }

    /// Prompts the user whether to pick photo from library or take a new one
    private func showPickPhotoPrompt() {
        let prompt = UIAlertController(title: "Pick photo", message: "", preferredStyle: .actionSheet)
        let library = UIAlertAction(title: "Choose from photo library", style: .default) { [weak self] (alertAction) in
            self?.showImagePicker(withSourceType: .photoLibrary)
        }
        let camera = UIAlertAction(title: "Take a photo", style: .default) { [weak self] (alertAction) in
            self?.showImagePicker(withSourceType: .camera)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        prompt.addAction(library)
        prompt.addAction(camera)
        prompt.addAction(cancel)
        present(prompt, animated: true, completion: nil)
    }
}

// MARK: - UITableView datasource and delegate methods
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profilePhotoCell = tableView.dequeueReusableCell(withIdentifier: "ProfilePhotoCell", for: indexPath) as! ProfilePhotoCell
        let genericCell = tableView.dequeueReusableCell(withIdentifier: "GenericCell", for: indexPath) as! GenericCell
        switch indexPath.row {
        case 0:
            profilePhotoCell.profileNameLabel.isHidden = true
            profilePhotoCell.profilePhoto.image = #imageLiteral(resourceName: "PlaceholderProfileImage")
            profilePhotoCell.setupCell(withContent: usr)
            return profilePhotoCell
        default:
            genericCell.setupCellWith(user: usr, tag: indexPath.row)
            return genericCell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            showPickPhotoPrompt()
        default:
            break
        }
    }
}


// MARK UIImagePickerController delegate methods
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        dismiss(animated: true, completion: nil)
        guard let userID = Auth.auth().currentUser?.uid else {return}

        firebaseServiceManager.uploadProfilePhoto(userID: userID, profilePhoto: image) { [weak self]  (error) in
            if error != nil {
                print("An error occured while uploading profile photo")
            } else {
                print("Profile photo uploaded successfuly")
                self?.tableView.reloadData()
            }
        }
    }
}
