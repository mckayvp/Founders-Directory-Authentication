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

    private func requestLogin() {
        networkIndicator.startAnimating()
        displayScreenView()

        ApiHelper.shared.login("user", "secret") { [weak self] (message) in
            DispatchQueue.main.async {
                if let failureMessage = message {
                    // NEEDSWORK: display the failure message to the user as given by the API
                    print(failureMessage)
                } else {
                    if let foundersApp = UIApplication.shared.delegate as? AppDelegate {
                        foundersApp.displayMasterScene(animated: true)
                    } else {
                        // NEEDSWORK: display a generic failure message
                        print("Login failed")
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
