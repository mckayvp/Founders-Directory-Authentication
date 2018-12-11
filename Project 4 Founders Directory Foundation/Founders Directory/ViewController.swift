//
//  ViewController.swift
//  Founders Directory
//
//  Created by McKay Palmer on 12/8/18.
//  Copyright © 2018 Steve Liddle. All rights reserved.
//

import UIKit

//This framework contains authentication helper codes
//import LocalAuthentication
//class ViewController: UIViewController {
//    @IBAction func touchIdAction(_ sender: UIButton) {
//        
//        print("hello there!.. You have clicked the touch ID")
//        
//        let myContext = LAContext()
//        let myLocalizedReasonString = "Biometric Authntication testing !! "
//        
//        
//        var authError: NSError?
//        if #available(iOS 8.0, macOS 10.12.1, *) {
//            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
//                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
//                    
//                    DispatchQueue.main.async {
//                        if success {
//                            // User authenticated successfully, take appropriate action
//                            self.successLabel.text = "Awesome!!... User authenticated successfully"
//                        } else {
//                            // User did not authenticate successfully, look at error and take appropriate action
//                            self.successLabel.text = "Sorry!!... User did not authenticate successfully"
//                        }
//                    }
//                }
//            } else {
//                // Could not evaluate policy; look at authError and present an appropriate message to user
//                successLabel.text = "Sorry!!.. Could not evaluate policy."
//            }
//        } else {
//            // Fallback on earlier versions
//            
//            successLabel.text = "Ooops!!.. This feature is not supported."
//        }
//        
//        
//    }
//}
