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
    var deviceID = User.sharedConfig.deviceId

    // MARK: - Outlets

    @IBOutlet weak var networkIndicator: UIActivityIndicatorView!

    // MARK: - Actions

    @IBAction func signIn(_ sender: UIButton) {
        print("requestLogin()")
        requestLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        print(User.sharedConfig.username)
        print(User.sharedConfig.password)
        print(User.sharedConfig.deviceId)


        
        
//        ApiHelper.logout()
//        requestLogin()  //call to request login immediately
//        loginAlert()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        print("Device ID: \(UIDevice.current.identifierForVendor!.uuidString)")
        User.sharedConfig.deviceId = UIDevice.current.identifierForVendor!.uuidString
        if deviceID == User.sharedConfig.deviceId {
            print("equal ids")
        } else {
            print("ids don't match")
            print(deviceID)
            print(User.sharedConfig.deviceId)
            createAccount()
        }
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
            if passwordField != passwordField2 {
                print("passwords no match")
            }
            
            print(userField.text ?? "")
            User.sharedConfig.username = userField.text ?? ""
            User.sharedConfig.password = passwordField.text ?? ""
            User.sharedConfig.deviceId = UIDevice.current.identifierForVendor!.uuidString
            self.deviceID = User.sharedConfig.deviceId
            self.textLogin(User.sharedConfig.username, User.sharedConfig.password)
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
            let passwordField = la.textFields![0] // Force unwrapping because we know it exists.
            let userField = la.textFields![1] // Force unwrapping because we know it exists.
            print(userField.text ?? "")
            self.username = passwordField.text ?? ""
            self.password = userField.text ?? ""
            self.textLogin(self.username, self.password)
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
        let alert = UIAlertController(title: "\(alertTitle)",
                                      message: alertMessage,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    private func requestLogin() {
        networkIndicator.startAnimating()
        displayScreenView()
        
//        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &biometricError) {
//        ^^ uncomment to check if enrolled for biometric auth ^^

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason:
                                                                                    localizedReasonString) {
                [unowned self] (success, authenticationError) in
                
                DispatchQueue.main.async {
                    if success {
                        self.textLogin(User.sharedConfig.username, User.sharedConfig.password)
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
//        } else { // no biometry
////            textLogin()
////            showAlert("Login", "Enter Username and Password")
//            print("need to allow biometry")
//        }
    }
    
    private func textLogin(_ username: String, _ password: String) {
        print("textLogin()")
        print(User.sharedConfig.username)
        print(User.sharedConfig.password)
        print(User.sharedConfig.deviceId)
        print(username)
        print(password)
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
