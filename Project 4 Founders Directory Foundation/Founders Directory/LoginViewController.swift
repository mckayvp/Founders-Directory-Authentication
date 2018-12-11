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
    let context = LAContext()
    let localizedReasonString = "Authenticate to view founders"

    // MARK: - Properties

    var screenView: UIView?
    var biometricError: NSError?
    var username = "user"
    var password = "secret"

    // MARK: - Outlets

    @IBOutlet weak var networkIndicator: UIActivityIndicatorView!

    // MARK: - Actions

    @IBAction func signIn(_ sender: UIButton) {
        print("requestLogin()")
        requestLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        ApiHelper.logout()
//        requestLogin()  //call to request login immediately
//        loginAlert()
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
        print("loginAlert()")
        let la = UIAlertController(
                                    title: "Please Sign In",
                                    message: "Enter Username and Password",
                                    preferredStyle: .alert)
        let loginAction = UIAlertAction(title: "Log In", style: .default) {
            (action) in
            let userField = la.textFields![0] // Force unwrapping because we know it exists.
            print(userField.text ?? "")
            self.password = userField.text ?? ""
            self.textLogin("user", self.password)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        la.addAction(loginAction)
        la.addAction(cancelAction)
        
        la.addTextField {
            (textField) in
            textField.placeholder = "Enter Password"
            textField.isSecureTextEntry = true
        }
        
        self.present(la, animated: true)
//        la.addTextField { (textField) in
//            textField.text = "Username"
//        }
//        la.addTextField { (textField) in
//            textField.text = "Password"
//        }

//        la.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak la] (_) in
//            let userField = la!.textFields![0] // Force unwrapping because we know it exists.
//            let passwordField = la!.textFields![1]
//            print("User field: \(userField.text ?? "user") Password: \(passwordField.text ?? "secret")")
//        }))
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
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &biometricError) {

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason:
                                                                                    localizedReasonString) {
                [unowned self] (success, authenticationError) in
                
                DispatchQueue.main.async {
                    if success {
                        self.textLogin(self.username, self.password)
                    } else { // catch biometric errors
//                        self.loginAlert()
                        print("username and password")
//                        self.textLogin()
//                        self.loginAlert()
//                        self.showAlert("Authentication failed", "You could not be verified; please try again.")
                        // add action to display biometric login again
                        self.loginAlert()
                    }
                }
            }
        } else { // no biometry
//            textLogin()
//            showAlert("Login", "Enter Username and Password")
            print("need to allow biometry")
        }
    }
    
    private func textLogin(_ username: String, _ password: String) {
        ApiHelper.shared.login(username, password) { [weak self] (message) in
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
