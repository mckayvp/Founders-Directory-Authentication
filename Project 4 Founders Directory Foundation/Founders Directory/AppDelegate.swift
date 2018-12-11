//
//  AppDelegate.swift
//  Founders Directory
//
//  Created by Steve Liddle on 9/21/16.
//  Copyright © 2016 Steve Liddle. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    // MARK: - Constants

    private struct Animation {
        static let duration = 0.33
    }

    private struct Storyboard {
        static let detailVCIdentifier = "DetailVC"
        static let login = "Login"
        static let main = "Main"
    }

    // MARK: - Properties

    var window: UIWindow?

    // MARK: - Application lifecycle

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                                                [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AnalyticsHelper.shared.reportEvent(page: "launch")

        if ApiHelper.shared.isLoggedIn() {
            if let splitVC = window!.rootViewController as? UISplitViewController {
                splitVC.delegate = self
            }
        } else {
            displayLoginScene()
        }

        return true
    }

    // MARK: - Split view delegate

    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        // We don't want to see the detail VC by default, but rather the main list
        return true
    }

    func splitViewController(
        _ splitViewController: UISplitViewController,
        separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        
        // NEEDSWORK: something is missing here, because the iPhone 7 Plus doesn't have the right
        // connection to the detail VC any more after running through a rotation.
        
        if let navVC = primaryViewController as? UINavigationController {
            for controller in navVC.viewControllers {
                if controller is UINavigationController {
                    // We found our detail VC on the master nav VC stack
                    return controller
                }
            }
        }

        // We didn't find our detail VC on the master nav VC stack, so we need to instantiate it
        let storyboard = UIStoryboard(name: Storyboard.main, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: Storyboard.detailVCIdentifier)
    }

    // MARK: - Scene management helpers

    private func animateTransition(to viewController: UIViewController) {
        if let currentViewController = window!.rootViewController {
            viewController.view.frame = currentViewController.view.frame
            viewController.view.alpha = 0
            self.window!.addSubview(viewController.view)

            UIView.animate(withDuration: Animation.duration, animations: {
                viewController.view.alpha = 1
                currentViewController.view.alpha = 0
            }, completion: { (finished) -> Void in
                self.window!.rootViewController = viewController
                self.window!.makeKey()
            })
        } else {
            window!.rootViewController = viewController
            window!.makeKeyAndVisible()
        }
    }

    func displayLoginScene(animated: Bool = false) {
        let storyboard = UIStoryboard(name: Storyboard.login, bundle: nil)

        if let loginViewController = storyboard.instantiateInitialViewController() as? LoginViewController {
            if animated {
                animateTransition(to: loginViewController)
            } else {
                window!.rootViewController = loginViewController
                window!.makeKeyAndVisible()
            }
        }
    }

    func displayMasterScene(animated: Bool = false) {
        if !(window!.rootViewController is UISplitViewController) {
            let storyboard = UIStoryboard(name: Storyboard.main, bundle: nil)

            if let splitVC = storyboard.instantiateInitialViewController() as? UISplitViewController {
                splitVC.delegate = self

                if animated {
                    animateTransition(to: splitVC)
                } else {
                    window!.rootViewController = splitVC
                    window!.makeKeyAndVisible()
                }
            }
        }
    }
}
