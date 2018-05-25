//
//  HomeViewController.swift
//  Zerina-MovieMoment
//
//  Created by Zerina Ribić on 04/03/2018.
//  Copyright © 2018 Zerina Ribić. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import Alamofire
import SwiftyJSON
import SDWebImage
import ProjectOxfordFace

class HomeViewController: UIViewController {

    // MARK: - IBOutlets / class properties
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var takePhotoLabel: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    var MSClient : MPOFaceServiceClient!
    var captureSession : AVCaptureSession!
    var videoPreviewLayer : AVCaptureVideoPreviewLayer!
    var capturePhotoOutput : AVCapturePhotoOutput!
    var captureDevice : AVCaptureDevice?
    var firebaseServiceManager : FirebaseServiceManager!
    var visualEffectView : UIVisualEffectView!

    // Mark: - LifeCycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupVisualEffectView()
        configureHelloLabel()
        configureTakePhotoLabel()
        configureProfileImageView()
        firebaseServiceManager = FirebaseServiceManager()
        MSClient = MPOFaceServiceClient(endpointAndSubscriptionKey: Constants.MSAPIEndPoint, key: Constants.MSAPIKey)
        NotificationCenter.default.addObserver(self, selector: #selector(resetAlphaOnParrentView), name: .changeAlpha, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.async {
            guard let name = Auth.auth().currentUser?.displayName else {return}
            self.helloLabel.text = name
        }
        if let imageUrl = Auth.auth().currentUser?.photoURL {
            profilePhoto.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "PlaceholderProfileImage"), options: SDWebImageOptions()) { (image, error, cacheType, url) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        applyPulsatingTo(UIElement: takePhotoLabel)
    }

    // MARK: - Private methods
    /// Adds a pulsating animation to the take photo label
    private func applyPulsatingTo(UIElement: UIView) {
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        pulseAnimation.duration = 1.5
        pulseAnimation.fromValue = 0
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        UIElement.layer.add(pulseAnimation, forKey: "animateOpacity")
    }

    /// Configures the profile photo image view
    private func configureProfileImageView() {
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2
    }

    /// Configures the hello label (e.g. adds the gesture recognizer)
    private func configureHelloLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showSettingsVC))
        tapGesture.numberOfTapsRequired = 1
        helloLabel.addGestureRecognizer(tapGesture)
        helloLabel.isUserInteractionEnabled = true
    }

    /// Displays the SettingsViewController
    @objc private func showSettingsVC() {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsViewController")
        let navigationVC = UINavigationController(rootViewController: settingsVC)
        present(navigationVC, animated: true, completion: nil)
    }


    /// Sets the alpha value of the parrent view
    /// Uses UIView animations to gradually increase alpha value
    /// Called by posting a notification
    @objc private func resetAlphaOnParrentView() {
        UIView.animate(withDuration: 0.5) {
            self.view.alpha = 1
        }
    }

    /// Decreases and animates the alpha value of parrent view
    private func decreaseAlphaOnParrentView() {
        UIView.animate(withDuration: 0.2) {
            self.view.alpha = 0.5
        }
    }

    /// Initializes and sets up the camera and it's custom view finder
    private func setupCamera() {
        // Initialize capture device and capture output
        guard let captureDevice = getDevice(position: .front) else {return}
        capturePhotoOutput = AVCapturePhotoOutput()

        do {
            // Initialize and add input to the capture session
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)

            // Initialize video preview layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            // Make sure that video preview maintains the aspect ratio
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            // Make video preview layer fill the whole screen
            videoPreviewLayer?.frame = view.layer.bounds
            // Insert video preview layer under all UI elements
            view.layer.insertSublayer(videoPreviewLayer, at: 0)
            // Start capture session and add capture photo output
            captureSession.startRunning()
            capturePhotoOutput.isHighResolutionCaptureEnabled = true
            captureSession.addOutput(capturePhotoOutput)
        } catch {
            print(error)
        }
    }

    /// Sets up the UIVisualEffectView
    private func setupVisualEffectView() {
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = UIScreen.main.bounds
        visualEffectView.effect = UIBlurEffect.init(style: .dark)
        addLabelToVisualEffectView()
    }

    /// Shows or hides UIVisualEffectView
    private func showVisualEffectView(show: Bool) {
        if show {
            view.addSubview(visualEffectView)
        } else {
            visualEffectView.removeFromSuperview()
        }
    }

    /// Adds a label to UIVisualEffectView
    private func addLabelToVisualEffectView() {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.text = "I am thinking..."
        visualEffectView.contentView.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: visualEffectView.contentView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: visualEffectView.contentView.centerYAnchor).isActive = true
    }

    /// Configures the takePhotoLabel
    private func configureTakePhotoLabel() {
        takePhotoLabel.backgroundColor = UIColor.clear
        takePhotoLabel.textColor = UIColor.white

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(takePhoto(tapRecognizer:)))
        tapGesture.numberOfTouchesRequired = 1
        takePhotoLabel.addGestureRecognizer(tapGesture)
        takePhotoLabel.isUserInteractionEnabled = true
    }

    /// Takes a photo
    @objc private func takePhoto(tapRecognizer: UITapGestureRecognizer) {
        print("Tap gesture performed!")
        guard let photoOutput = capturePhotoOutput else {return}
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    /// Gets an input device (camera) for the specified position (front or back)
    private func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices();
        // Iterates through all the devices and looks for those with front position
        for device in devices {
            let deviceConverted = device
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }

    /// Displays the errors
    private func displayErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}

// MARK: - AVCapturePhotoCapture delegate methods
extension HomeViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        showVisualEffectView(show: true)
        view.isUserInteractionEnabled = false
        if let error = error {
            print(error.localizedDescription)
            showVisualEffectView(show: false)
            view.isUserInteractionEnabled = true
        } else {
            print("Photo taken successfuly!")
            // Get the image as JPG
            // Since we are supporting iOS 10 this warning needs to stay for now
            guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {return}
            let capturedImage = UIImage.init(data: imageData, scale: 1.0)

            if let image = capturedImage {
                guard let id = Auth.auth().currentUser?.uid else {return}
                firebaseServiceManager.uploadPhotoToFirebaseStorage(userID: id, photo: image, completion: { [weak self] (imageUrl, error) in
                    if let error = error {
                        print(error)
                        self?.displayErrorAlert(message: error)
                        self?.showVisualEffectView(show: false)
                        self?.view.isUserInteractionEnabled = true
                    } else {
                        print("Image uploaded to firebase storage!")
                        guard let imageUrl = imageUrl else {return}
                        TemporaryInfo.currentImageUrl = imageUrl
                        self?.MSClient.detect(withUrl: imageUrl, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [1,2,3,4,5,6,7,8], completionBlock: { (face, error) in
                            if let error = error {
                                print(error.localizedDescription)
                                self?.showVisualEffectView(show: false)
                                self?.displayErrorAlert(message: error.localizedDescription)
                                self?.view.isUserInteractionEnabled = true
                            } else {
                                let faces = face
                                if faces?.count == 0 {
                                    self?.showVisualEffectView(show: false)
                                    self?.displayErrorAlert(message: "No faces detected\nTry again!")
                                    self?.view.isUserInteractionEnabled = true
                                }
                                guard let emotion = face?.first?.attributes.emotion.mostEmotion else {return}
                                guard let detectedGender = face?.first?.attributes.gender else {return}

                                TemporaryInfo.currentEmotion = emotion
                                TemporaryInfo.currentGender = detectedGender

                                self?.showVisualEffectView(show: false)
                                self?.performSegue(withIdentifier: "ToRecommendedActivities", sender: nil)
                                self?.decreaseAlphaOnParrentView()
                                self?.view.isUserInteractionEnabled = true
                            }
                        })
                    }
                })
            }
        }
    }
}
