//
//  LoginViewController.swift
//  Founders Directory
//
//  Created by Steve Liddle on 11/7/16.
//  Copyright © 2016 Steve Liddle. All rights reserved.
//

import UIKit

class LoginViewController : UITableViewController {

    // MARK: - Properties

    var screenView: UIView?

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
    
    private func loginErrorAlert(_ failureMessage: String) {
        let alert = UIAlertController(title: "\(failureMessage)",
                                      message: "",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func requestLogin() {
        networkIndicator.startAnimating()
        displayScreenView()

        ApiHelper.shared.login("user", "secret") { [weak self] (message) in
            DispatchQueue.main.async {
                if let failureMessage = message {
                    self?.loginErrorAlert(failureMessage)
                } else {
                    if let foundersApp = UIApplication.shared.delegate as? AppDelegate {
                        print("successful Login")
                        foundersApp.displayMasterScene(animated: true)
                    } else {
                        self?.loginErrorAlert("Unexpected Login Error Occured")
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
