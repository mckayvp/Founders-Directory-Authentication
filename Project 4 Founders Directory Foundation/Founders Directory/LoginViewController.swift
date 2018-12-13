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
    var deviceID = User.sharedConfig.deviceId

    // MARK: - Outlets

    @IBOutlet weak var networkIndicator: UIActivityIndicatorView!

    // MARK: - Actions

    @IBAction func signIn(_ sender: UIButton) {
        requestLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        User.sharedConfig.deviceId = UIDevice.current.identifierForVendor!.uuidString
    }


    // MARK: - Private helpers
    
    private func createAccount() {
        let ca = UIAlertController(
            title: "Create New Account",
            message: "Enter Username and Password",
            preferredStyle: .alert)
        let createAction = UIAlertAction(title: "Create", style: .default) {
            (action) in
            let userField = ca.textFields![0] // Force unwrapping because we know it exists.
            let passwordField = ca.textFields![1]
            let passwordField2 = ca.textFields![2]
            if passwordField.text != passwordField2.text {
                self.errorAlert()
            } else {
                print(userField.text ?? "")
                User.sharedConfig.username = userField.text ?? ""
                User.sharedConfig.password = passwordField.text ?? ""
                User.sharedConfig.deviceId = UIDevice.current.identifierForVendor!.uuidString
                self.deviceID = User.sharedConfig.deviceId
                self.textLogin(User.sharedConfig.username, User.sharedConfig.password)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ca.addAction(createAction)
        ca.addAction(cancelAction)
        
        ca.addTextField {
            (textField) in
            textField.placeholder = "Enter Username"
            textField.isSecureTextEntry = false
        }
        ca.addTextField {
            (textField) in
            textField.placeholder = "Enter Password"
            textField.isSecureTextEntry = true
        }
        ca.addTextField {
            (textField) in
            textField.placeholder = "Confirm Password"
            textField.isSecureTextEntry = true
        }
        
        self.present(ca, animated: true)
    }
    
    private func errorAlert() {
        let ea = UIAlertController(
            title: "Passwords Don't Match",
            message: "Enter password again",
            preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "OK", style: .cancel) {
            (action) in
            self.createAccount()
        }
        
        ea.addAction(closeAction)
        self.present(ea, animated: true)
    }
    
    private func loginAlert() {
        let la = UIAlertController(
                                    title: "Please Sign In",
                                    message: "Enter Username and Password",
                                    preferredStyle: .alert)
        let loginAction = UIAlertAction(title: "Log In", style: .default) {
            (action) in
            let userField = la.textFields![0] // Force unwrapping because we know it exists.
            let passwordField = la.textFields![1]
            self.textLogin(userField.text!, passwordField.text!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        la.addAction(loginAction)
        la.addAction(cancelAction)
        
        la.addTextField {
            (textField) in
            textField.placeholder = "Enter Username"
            textField.isSecureTextEntry = false
        }
        la.addTextField {
            (textField) in
            textField.placeholder = "Enter Password"
            textField.isSecureTextEntry = true
        }
        
        self.present(la, animated: true)
    }
    
    private func showAlert(_ alertTitle: String, _ alertMessage: String) {
        let alert = UIAlertController(title: alertTitle,
                                      message: alertMessage,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    private func requestLogin() {

        if deviceID == User.sharedConfig.deviceId { // user has already logged in with this device
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &biometricError) { // Use biometric login
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason:
                localizedReasonString) {
                    [unowned self] (success, authenticationError) in
                    
                    DispatchQueue.main.async {
                        if success {
                            self.textLogin(User.sharedConfig.username, User.sharedConfig.password)
                        } else { // catch biometric errors
                            self.loginAlert()
                        }
                    }
                }
            } else { // no biometry
                loginAlert()
            }
        } else { // first time for device, create username and password
            createAccount()
        }
    }
    
    private func textLogin(_ username: String, _ password: String) {
        ApiHelper.shared.login(username, password) { [weak self] (message) in
            DispatchQueue.main.async {
                if let failureMessage = message {
                    self?.showAlert(failureMessage, "Incorrect username or password")
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
