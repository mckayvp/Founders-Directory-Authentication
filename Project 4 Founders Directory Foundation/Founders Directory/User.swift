//
//  Device.swift
//  Founders Directory
//
//  Created by McKay Palmer on 12/11/18.
//  Copyright © 2018 Steve Liddle. All rights reserved.
//

import Foundation


class User {
    
    // MARK: - Singleton
    static let sharedConfig = User()
    
    // MARK: - Properties
    var deviceId = ""
    var userId = ""
    var username = "mckaypalmer@gmail.com"
    var password = "password1"
    var biometricType = 0
}
