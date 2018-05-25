//
//  ViewController.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 03/03/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {

    // MARK: - IBOutlets / class properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var googleSignInButton: UIButton!
    var firebaseServiceManager : FirebaseServiceManager!
    var loadingIndicator : UIActivityIndicatorView!

    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        firebaseServiceManager = FirebaseServiceManager()
        GIDSignIn.sharedInstance().uiDelegate = self
        setAppearance()
        configureForgotLabel()
        loadingIndicator = UIActivityIndicatorView()
        setupLoadingIndicator()
        NotificationCenter.default.addObserver(self, selector: #selector(self.transitionToHomescreen), name: .goToHomeScreen, object: nil)
    }

    override func transition(from fromViewController: UIViewController, to toViewController: UIViewController, duration: TimeInterval, options: UIViewAnimationOptions = [], animations: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        super.viewWillDisappear(true)
        changeUIStates(enable: true)
    }

    // MARK: - IBActions
    @IBAction func didTapLoginButton(_ sender: UIButton) {
        changeUIStates(enable: false)
        loadingIndicator.startAnimating()
        if !isFormValid() {
            changeUIStates(enable: true)
            return
        }
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        firebaseServiceManager.signInUserWith(email: email, password: password) { [weak self] (userEmail, error) in
            if let error = error {
                print(error)
                self?.displayErrorAlert(message: error)
                return
            } else {
                print(userEmail as Any)
                self?.loadingIndicator.stopAnimating()
                self?.transitionToHomescreen()
            }
        }
    }

    @IBAction func didTapGoogleSignInButton(_ sender: UIButton) {
        changeUIStates(enable: false)
        loadingIndicator.startAnimating()
        GIDSignIn.sharedInstance().signIn()
    }

    // MARK: - Private methods
    /// Disables or enables UI elements
    private func changeUIStates(enable: Bool) {
        loginButton.isEnabled = enable
        googleSignInButton.isEnabled = enable
        registerButton.isEnabled = enable
        emailTextField.isEnabled = enable
        passwordTextField.isEnabled = enable
        forgotPasswordLabel.isEnabled = enable
    }

    /// Sets the appearance of UI elements
    private func setAppearance() {
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.clear.cgColor
        loginButton.layer.cornerRadius = 20

        registerButton.layer.borderWidth = 1
        registerButton.layer.borderColor = UIColor.clear.cgColor
        registerButton.layer.cornerRadius = 20

        googleSignInButton.layer.borderWidth = 1
        googleSignInButton.layer.borderColor = UIColor.clear.cgColor
        googleSignInButton.layer.cornerRadius = 20
    }

    /// Checks the login form
    /// returns: Bool
    private func isFormValid() -> Bool {
        guard let email = emailTextField.text else {return false}
        guard let password = passwordTextField.text else {return false}

        if email.isEmpty || password.isEmpty {
            displayErrorAlert(message: "You may not leave the fields blank!")
            return false
        }
        return true
    }

    /// Displays the error alert
    private func displayErrorAlert(message: String) {
        loadingIndicator.stopAnimating()
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { [weak self] (alertAction) in
            self?.changeUIStates(enable: true)
        }
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

    /// Transitions to home screen after successful login
    /// Usually invoked by the notification
    @objc private func transitionToHomescreen() {
        performSegue(withIdentifier: "ToHome", sender: self)
    }

    /// Sets up the loading indicator
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = .gray
        loadingIndicator.color = UIColor.darkGray
        view.addSubview(loadingIndicator)

        // Set constraints
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    /// Sets the UITapGestureRecognizer to forgotPasswordLabel
    private func configureForgotLabel() {
        forgotPasswordLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showPasswordResetAlert))
        tapGesture.numberOfTapsRequired = 1
        forgotPasswordLabel.addGestureRecognizer(tapGesture)
    }

    /// Displays the alert for success messages
    private func displaySuccessAlert(message: String) {
        let alert = UIAlertController(title: "Success!", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

    /// Displays the password resset alert
    @objc private func showPasswordResetAlert() {
        let alert = UIAlertController(title: "Reset your password", message: "Provide your email to reset your password.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { [weak self] (alertAction) in
            guard let email = alert.textFields?.first?.text else {return}
            self?.firebaseServiceManager.resetPasswordWith(email: email, completion: { (result, error) in
                if let error = error {
                    self?.displayErrorAlert(message: error)
                } else {
                    self?.displaySuccessAlert(message: "An email with further instructions has been sent to \(email)")
                    print(result!)
                }
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(cancel)
        alert.addAction(ok)

        alert.addTextField { (emailField) in
            emailField.autocorrectionType = UITextAutocorrectionType.no
            emailField.spellCheckingType = UITextSpellCheckingType.no
            emailField.textContentType = UITextContentType.emailAddress
            emailField.keyboardType = UIKeyboardType.emailAddress
            emailField.keyboardAppearance = UIKeyboardAppearance.dark
            emailField.smartDashesType = UITextSmartDashesType.no
            emailField.smartQuotesType = UITextSmartQuotesType.no

            emailField.placeholder = "Email address"
        }
        present(alert, animated: true) {
            alert.textFields?.first?.text = self.emailTextField.text
        }
    }

}

// MARK: - GIDSignIn UI delegate methods
extension LoginViewController: GIDSignInUIDelegate {

    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            displayErrorAlert(message: error.localizedDescription)
            changeUIStates(enable: true)
        } else {
            loadingIndicator.stopAnimating()
            changeUIStates(enable: true)
        }
    }

}
