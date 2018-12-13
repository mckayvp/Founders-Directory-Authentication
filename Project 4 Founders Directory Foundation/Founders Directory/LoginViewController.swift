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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        User.sharedConfig.deviceId = UIDevice.current.identifierForVendor!.uuidString
    }

    
    // MARK: - Private helpers
    
    private func createAccount() {
        let ca = UIAlertController(
                                    title: "Create New Account",
                                    message: "Enter Username and Password",
                                    preferredStyle: .alert)
        
        let createAction = UIAlertAction(title: "Create", style: .default) {
            _ in
            let userField = ca.textFields![0] // Force unwrapping because we know it exists.
            let passwordField = ca.textFields![1]
            let passwordField2 = ca.textFields![2]
            if userField.text == "" {
                self.errorAlert("Username cannot be blank")
            }
            else if passwordField.text == "" {
                self.errorAlert("Password cannot be blank")
            }
            else if passwordField.text != passwordField2.text {
                self.errorAlert("Passwords do no match")
            } else {
                User.sharedConfig.username = userField.text ?? ""
                User.sharedConfig.password = passwordField.text ?? ""
                User.sharedConfig.deviceId = UIDevice.current.identifierForVendor!.uuidString
                self.deviceID = User.sharedConfig.deviceId
                self.executeLogin(User.sharedConfig.username, User.sharedConfig.password)
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
    
    private func errorAlert(_ message: String) {
        let ea = UIAlertController(
                                    title: "Error Creating Account",
                                    message: "\(message)",
                                    preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "OK", style: .cancel) {
            _ in
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
            _ in
            let userField = la.textFields![0] // Force unwrapping because we know it exists.
            let passwordField = la.textFields![1]
            self.executeLogin(userField.text!, passwordField.text!)
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
        let alert = UIAlertController(
                                      title: alertTitle,
                                      message: alertMessage,
                                      preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    private func requestLogin() {

        if deviceID == User.sharedConfig.deviceId { // user has already logged in with this device
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &biometricError) {
                // Use biometric login
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason:
                localizedReasonString) { // Present biometric login
                    [unowned self] (success, authenticationError) in
                    
                    DispatchQueue.main.async {
                        if success {
                            self.executeLogin(User.sharedConfig.username, User.sharedConfig.password)
                        } else { // catch biometric errors
                            self.loginAlert()
                        }
                    }
                }
            } else { // not enrolled in biometry auth
                settingsAlert()
            }
        } else { // first time for device, create username and password
            createAccount()
        }
    }
    
    private func settingsAlert() {
        let sa = UIAlertController(
                                    title: "Permission Required",
                                    message: "You previously disabled biometric authentication. Use the Settings app to enable Face ID or Touch ID.",
                                    preferredStyle: .alert)
        
        let manualLogin = UIAlertAction(title: "Manual Login", style: .default) {
                                                _ in
                                                self.loginAlert()
                                        }
        let launchSettings = UIAlertAction(title: "Open Settings", style: .default) {
                                                _ in
                                                if let url = UIApplication.openSettingsURLString.url {
                                                    UIApplication.shared.open(url)
                                                }
                                            }
        
        sa.addAction(manualLogin)
        sa.addAction(launchSettings)
        
        self.present(sa, animated: true)
    }
    
    private func executeLogin(_ username: String, _ password: String) {
        ApiHelper.shared.login(username, password) { [weak self] (message) in
            DispatchQueue.main.async {
                if let failureMessage = message {
                    self?.showAlert(failureMessage, "Incorrect username or password")
                } else {
                    if let foundersApp = UIApplication.shared.delegate as? AppDelegate {
                        foundersApp.displayMasterScene(animated: true)
                    } else {
                        self?.showAlert("Unexpected Login Error Occured", "")
                    }
                }
            }
        }
    }
}
