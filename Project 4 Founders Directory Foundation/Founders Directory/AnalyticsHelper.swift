//
//  AnalyticsHelper.swift
//  Founders Directory
//
//  Created by Steve Liddle on 11/5/16.
//  Copyright © 2016 Steve Liddle. All rights reserved.
//

import UIKit

class AnalyticsHelper {

    // MARK: - Constants

    private struct Key {
        static let bundleShortVersion = "CFBundleShortVersionString"
        static let bundleVersion = "CFBundleVersion"
        static let device = "d"
        static let manufacturer = "m"
        static let model = "o"
        static let page = "g"
        static let product = "p"
        static let release = "r"
        static let sdk = "s"
        static let url = "u"
        static let version = "v"
    }

    // MARK: - Properties

    var device: String
    var manufacturer = "apple"
    var model: String
    var product = "ios"
    var release: String
    var sdk: String
    var version: String

    // MARK: - Singleton
    
    static let shared = AnalyticsHelper()

    fileprivate init() {
        if let vendorId = UIDevice.current.identifierForVendor {
            device = vendorId.uuidString
        } else {
            device = "simulator"
        }

        model = AnalyticsHelper.findModel()
        release = UIDevice.current.systemVersion
        sdk = release

        // Here I'm looking up information from the app's info bundle.  Right-click your Info.plist
        // and open as "Source Code" and you can see all the keys and values that are accessible,
        // including the two we use here.
        if let appVersion = Bundle.main.object(forInfoDictionaryKey: Key.bundleShortVersion) as? String {
            version = appVersion
        } else {
            version = "0.0"
        }

        if let buildNumber = Bundle.main.object(forInfoDictionaryKey: Key.bundleVersion) as? String {
            version += ".\(buildNumber)"
        } else {
            version += ".0"
        }
    }

    // MARK: - Public API

    func reportEvent(page: String, url: String? = nil) {
        let urlValue = url?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let parameters = [ Key.device       : device,
                           Key.manufacturer : manufacturer,
                           Key.model        : model,
                           Key.product      : product,
                           Key.release      : release,
                           Key.sdk          : sdk,
                           Key.page         : page,
                           Key.version      : version,
                           Key.url          : urlValue
                         ]
 
        ApiHelper.shared.reportEvent(parameters)
    }

    // MARK: - Private helpers

    private static func findModel() -> String {
        // See http://bit.ly/2fPcfQz for ideas on this.

        // Default will be the generic model supplied by UIDevice (usually "iPhone")
        var machineString = UIDevice.current.model

        #if (arch(i386) || targetEnvironment(simulator)) && os(iOS)
            // This conditionally compiles code for execution only in the simulator
            if let model = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                return model
            }
        #else
            // This code will compile for execution when running on a device
            var systemInfo = utsname()

            uname(&systemInfo)  // This lets uname() change the systemInfo structure, to fill it in

            // To really understand this thoroughly, I'd need to teach you more Swift functional
            // programming and more about the Swift standard library.  You can read about Mirror
            // at http://apple.co/2eq01IT for example.
            let machineMirror = Mirror(reflecting: systemInfo.machine)

            machineString = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else {
                    return identifier
                }

                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        #endif

        return machineString
    }
}
