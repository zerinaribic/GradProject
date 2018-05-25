//
//  SignupViewController.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 03/03/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    // MARK: - IBOutlets / class properties
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reTypedPasswordTextField: UITextField!
    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var firebaseServiceManager : FirebaseServiceManager!
    var loadingIndicator : UIActivityIndicatorView!

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseServiceManager = FirebaseServiceManager()
        setAppearance()
        setupLoadingIndicator()
    }

    // MARK: - IBActions
    @IBAction func didTapRegisterButton(_ sender: UIButton) {
        loadingIndicator.startAnimating()
        resignFirstResponder()
        if !isFormValid() {
            loadingIndicator.stopAnimating()
            return
        } else {
            changeUIElementsStates(enabled: false)
            guard let firstName = firstNameTextField.text else {return}
            guard let lastName = lastNameTextField.text else {return}
            guard let email = emailTextField.text else {return}
            guard let password = passwordTextField.text else {return}
            firebaseServiceManager.registerWith(firstName: firstName, lastName: lastName, email: email, password: password, completion: { [weak self] (authResult, error) in
                if let error = error {
                    print(error)
                    self?.loadingIndicator.stopAnimating()
                    self?.displayErrorAlert(message: error)
                    return
                } else {
                    print(authResult?.user.email as Any)
                    print("User registration successful!")
                    self?.loadingIndicator.stopAnimating()
                    self?.dismiss(animated: true, completion: {
                        NotificationCenter.default.post(name: .goToHomeScreen, object: self)
                        self?.changeUIElementsStates(enabled: true)
                    })
                }
            })
        }
    }

    @IBAction func didTapCancelButton(_ sender: UIButton) {
        resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Private methods
    /// Checks if the registration form is valid
    private func isFormValid() -> Bool {
        guard let firstName = firstNameTextField.text else {return false}
        guard let lastName = lastNameTextField.text else {return false}
        guard  let email = emailTextField.text else {return false}
        guard let password = passwordTextField.text else {return false}
        guard let reTypedPassword = reTypedPasswordTextField.text else {return false}

        if firstName.isEmpty || lastName.isEmpty {
            displayErrorAlert(message: "First and last name are mandatory!")
            return false
        }
        if email.isEmpty {
            displayErrorAlert(message: "Email address is mandatory!")
            return false
        }
        if password != reTypedPassword {
            displayErrorAlert(message: "Passwords do not match!")
            return false
        }
        if password.isEmpty || reTypedPassword.isEmpty {
            displayErrorAlert(message: "You need to enter password!")
            return false
        }
        return true
    }

    /// Displays the error messages
    private func displayErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { [weak self] (alertAction) in
            self?.changeUIElementsStates(enabled: true)
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

    /// Sets the appearance of signup view and it's sub views
    private func setAppearance() {
        signupView.layer.cornerRadius = 15
        signupView.backgroundColor = UIColor.white.withAlphaComponent(0.8)

        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.clear.cgColor
        cancelButton.layer.cornerRadius = 20

        registerButton.layer.borderWidth = 1
        registerButton.layer.borderColor = UIColor.clear.cgColor
        registerButton.layer.cornerRadius = 20
    }

    /// Enables or disables user interface elements
    private func changeUIElementsStates(enabled: Bool) {
        firstNameTextField.isEnabled = enabled
        lastNameTextField.isEnabled = enabled
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        reTypedPasswordTextField.isEnabled = enabled
    }

    /// Sets up a loading indicator
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = .gray
        loadingIndicator.color = UIColor.darkGray
        signupView.addSubview(loadingIndicator)

        // Set constraints
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerXAnchor.constraint(equalTo: signupView.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: signupView.centerYAnchor).isActive = true
    }

    /// Dismisses the keyboard if user touches empty area
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
