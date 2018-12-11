//
//  LoginViewController.swift
//  Founders Directory
//
//  Created by Steve Liddle on 11/7/16.
//  Copyright © 2016 Steve Liddle. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController : UITableViewController {
    
    // MARK: - Constants
    let myContext = LAContext()
    let myLocalizedReasonString = "Authenticate to view founders"
    let loginController = UIAlertController(title: "Please Sign In",
                                            message: "Enter Username and Password",
                                            preferredStyle: .alert)


    // MARK: - Properties

    var screenView: UIView?
    var biometricError: NSError?

    // MARK: - Outlets

    @IBOutlet weak var networkIndicator: UIActivityIndicatorView!

    // MARK: - Actions

    @IBAction func signIn(_ sender: UIButton) {
        print("requestLogin()")
        requestLogin()
    }

    // MARK: - Private helpers

    private func displayScreenView() {
        // Display a semi-transparent screen to prevent additional UI events 
        let screenView = UIView()

        screenView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        screenView.frame = view.bounds
        screenView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(screenView)
        self.screenView = screenView
    }
    
    private func loginAlert() {
        let la = UIAlertController(title: "Please Sign In",
                                      message: "Enter Username and Password",
                                      preferredStyle: UIAlertController.Style.alert)
        la.addTextField { (textField) in
            textField.text = "Username"
        }
        la.addTextField { (textField) in
            textField.text = "Password"
        }
        
        la.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak la] (_) in
            let userField = la!.textFields![0] // Force unwrapping because we know it exists.
            let passwordField = la!.textFields![1]
            print("User field: \(userField.text ?? "user") Password: \(passwordField.text ?? "secret")")
        }))
    }
    
    private func showAlert(_ alertTitle: String, _ alertMessage: String) {
        let alert = UIAlertController(title: "\(alertTitle)",
                                      message: alertMessage,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    private func requestLogin() {
        networkIndicator.startAnimating()
        displayScreenView()
        
        if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &biometricError) {
            
            myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason:
                                                                                    myLocalizedReasonString) {
                [unowned self] (success, authenticationError) in
                
                DispatchQueue.main.async {
                    if success {
                        if let foundersApp = UIApplication.shared.delegate as? AppDelegate {
                            print("successful biometric Login")
                            foundersApp.displayMasterScene(animated: true)
                        } else {
                            self.showAlert("Unexpected Login Error Occured", "")
                        }
                    } else { // catch biometric errors
//                        self.loginAlert()
                        print("username and password")
//                        self.textLogin()
//                        self.loginAlert()
                        self.showAlert("Authentication failed", "You could not be verified; please try again.")
                    }
                }
            }
        } else { // no biometry
            textLogin()
        }
    }
    
    private func textLogin() {
        ApiHelper.shared.login("user", "secret") { [weak self] (message) in
            DispatchQueue.main.async {
                if let failureMessage = message {
                    self?.showAlert(failureMessage, "")
                } else {
                    if let foundersApp = UIApplication.shared.delegate as? AppDelegate {
                        print("successful Login")
                        foundersApp.displayMasterScene(animated: true)
                    } else {
                        self?.showAlert("Unexpected Login Error Occured", "")
                    }
                }
                
                if let screenView = self?.screenView {
                    screenView.removeFromSuperview()
                    self?.networkIndicator.stopAnimating()
                }
            }
        }
    }
}
