//
//  FirebaseServiceManager.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 03/03/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class FirebaseServiceManager  {

    // MARK: - Typealiases
    typealias Result = String
    typealias ErrorMessage = String
    typealias UserEmail = String

    // MARK: - Plain registration and login methods
    /// Registers a user using email and password
    func registerWith(firstName: String, lastName: String, email: String, password: String, completion: @escaping (AuthDataResult?, ErrorMessage?) -> Void) {
        Auth.auth().createUserAndRetrieveData(withEmail: email, password: password) { [weak self] (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error.localizedDescription)
            } else {
                self?.addDisplayName(firstName: firstName, lastName: lastName)
                completion(authResult, nil)
                let userDefaults = UserDefaults.standard
                userDefaults.set(true, forKey: Constants.googleSignInString)
            }
        }
    }

    /// Signs in registered users
    func signInUserWith(email: String, password: String, completion: @escaping (UserEmail?, ErrorMessage?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error.localizedDescription)
            } else {
                guard let userEmail = user?.email else {return}
                completion(userEmail, nil)
                let userDefaults = UserDefaults.standard
                userDefaults.set(true, forKey: Constants.googleSignInString)
            }
        }
    }

    // MARK: - Private methods
    /// Updates the profile photo URL
    private func updatePhotoUrl(photoUrl: String) {
        guard let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() else {return}
        changeRequest.photoURL = URL(string: photoUrl)
        changeRequest.commitChanges { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Photo URL updated successfuly")
            }
        }
    }


    private func getCurrentDateAndTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second

        let dateString = String(year!) + String(month!) + String(day!) + String(hour!) + String(minute!) + String(second!)
        return dateString
    }

    private func addDisplayName(firstName: String, lastName: String) {
        let displayName = "\(firstName) \(lastName)"
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges(completion: { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Display name set successfuly!")
            }
        })
    }

    /// Uploads a photo to Firebase storage
    func uploadPhotoToFirebaseStorage(userID: String, photo: UIImage, completion: @escaping (Result?, ErrorMessage?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        var data = Data()
        data = UIImageJPEGRepresentation(photo, 0.5)!
        let meta = StorageMetadata()
        meta.contentType = "image/jpg"

        let currentDateAndTime = getCurrentDateAndTime()

        storageRef.child("\(userID)/photos/\(currentDateAndTime)").putData(data, metadata: meta) { (storageData, error) in
            if let error = error {
                completion(nil, error.localizedDescription)
            } else {
                guard let imageUrl = storageData?.downloadURL()?.absoluteString else {return}
                completion(imageUrl, nil)
            }
        }
    }

    /// Uploads a photo to the firebase and updates a URL for that photo
    func uploadProfilePhoto(userID: String, profilePhoto: UIImage, completion: @escaping (ErrorMessage?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        var data = Data()
        data = UIImageJPEGRepresentation(profilePhoto, 0.8)!
        let meta = StorageMetadata()
        meta.contentType = "image/jpg"

        storageRef.child("\(userID)/profilephoto").putData(data, metadata: meta) { (storageMetaData, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(error.localizedDescription)
            } else {
                guard let photoUrl = storageMetaData?.downloadURL()?.absoluteString else {return}
                self.updatePhotoUrl(photoUrl: photoUrl)
                completion(nil)
            }
        }
    }


    /// Initiates a password reset procedure
    func resetPasswordWith(email: String, completion: @escaping (Result?, ErrorMessage?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                completion(nil, error.localizedDescription)
            } else {
                completion("Password reset!", nil)
            }
        }
    }

    /// Gets all the user data
    func getUser(completion: @escaping (User?) -> Void) {
        guard let displayName = Auth.auth().currentUser?.displayName else {completion(nil); return}
        guard let email = Auth.auth().currentUser?.email else {completion(nil); return}
        let imageUrl = Auth.auth().currentUser?.photoURL

        let user = User(profileName: displayName, imageUrl: imageUrl, email: email)
        completion(user)
    }

/// Saves the data to the Firestore database for the history
    func saveToHistory(userID: String, movieID: String, historyData: History, completion: @escaping (ErrorMessage?) -> Void) {
        let documentPath = "\(userID)/history/watched/\(movieID)"
        let dbReference = Firestore.firestore().document(documentPath)
        let dataToSave = [
            "dateTime":historyData.date,
            "movieTitle":historyData.movieTitle,
            "movieID":historyData.movieID,
            "imageUrl":historyData.imageUrl,
            "currentMood":historyData.currentMood
        ]
        dbReference.setData(dataToSave) { (error) in
            if let error = error {
                print(error.localizedDescription)
                completion(error.localizedDescription)
            } else {
                completion(nil)
            }
        }
    }

    /// Logs out the currently logged in user from all signin providers
    func  logOut(completion: @escaping () -> Void) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(false, forKey: Constants.googleSignInString)
        GIDSignIn.sharedInstance().signOut()
        do {
            try Auth.auth().signOut()
            completion()
        } catch {
            print(error)
        }
    }
}
