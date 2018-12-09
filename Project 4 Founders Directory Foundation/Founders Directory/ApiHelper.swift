//
//  ApiHelper.swift
//  Founders Directory
//
//  Created by Steve Liddle on 11/1/16.
//  Copyright © 2016 Steve Liddle. All rights reserved.
//

import UIKit
import GRDB

typealias JSONObject = [String : Any?]
typealias JSONArray = [Any?]

class ApiHelper {
    
    // MARK: - Constants

    struct Command {
        static let add = "addfounder"
        static let delete = "deletefounder"
        static let getPhoto = "photo"
        static let getUpdates = "getupdatessince"
        static let login = "login"
        static let logout = "logout"
        static let reportStats = "r"
        static let setPassword = "setpassword"
        static let update = "updatefounder"
        static let uploadPhoto = "uploadphoto"
    }

    struct Constants {
        static let baseSyncUrl = "https://scriptures.byu.edu/founders/v5/"
        static let failureCode = "0"
        static let photoFounder = "founder"
        static let photoSpouse = "spouse"
        static let resultKey = "result"
        static let successResult = "success"
    }

    struct Key {
        static let result = "result"
        static let sessionId = "sessionId"
        static let userId = "userId"
    }

    struct Notice {
        static let changesMade = NSNotification.Name(rawValue: "changesMade")
    }
    
    struct Parameter {
        static let device = "d"
        static let photoField = "u"
        static let photoType = "f"
        static let id = "i"
        static let maxVersion = "x"
        static let password = "p"
        static let sessionToken = "k"
        static let username = "u"
        static let version = "v"
    }

    struct Sync {
        static let interval: Double = 120
    }

    struct UI {
        static let changedPassword = "Password successfully changed."
        static let didntChangePassword = "Unable to change password.\nTry logging out and back in."
        static let failedLogin = "Unable to log in."
        static let notLoggedIn = "Please log in first."
    }

    // MARK: - Properties

    var isSynchronizing = false
    var lastSyncTime: Date?
    var timer: Timer?

    var sessionToken: String? {
        didSet {
            if sessionToken != nil {
                DispatchQueue.global().async {
                    _ = ApiHelper.shared.synchronizeFounders()
                }

                timer = Timer.scheduledTimer(withTimeInterval: Sync.interval, repeats: true) {
                    (timer) in

                    DispatchQueue.global().async {
                        _ = ApiHelper.shared.synchronizeFounders()
                    }
                }
            } else {
                if let activeTimer = timer {
                    activeTimer.invalidate()
                }
            }
        }
    }

    // MARK: - Singleton
    
    static let shared = ApiHelper()

    fileprivate init() {
        loadSessionFromPreferences()
    }

    // MARK: - Public API

    func isLoggedIn() -> Bool {
        return sessionToken != nil
    }

    func loadSessionFromPreferences() {
        sessionToken = UserDefaults.standard.string(forKey: Key.sessionId)
    }

    func login(_ username: String, _ password: String, completionHander: @escaping (String?) -> ()) {
        // NEEDSWORK: get rid of this bypass code!
        if username == "user" && password == "secret" {
            sessionToken = "b24b226e6862e4243110c844fe04ca34"

            let defaults = UserDefaults.standard

            defaults.set("31", forKey: Key.userId)
            defaults.set(sessionToken, forKey: Key.sessionId)
            defaults.synchronize()

            completionHander(nil)

            return
        }
        print("username: \(username)")
        print("password: \(password)")

        let loginUrl = ApiHelper.shared.syncUrl(
            forCommand: Command.login,
            withArguments: [ Parameter.username : username,
                             Parameter.password : password,
                             Parameter.device : AnalyticsHelper.shared.device ],
            encoded: false)

        HttpHelper.shared.getJsonContent(urlString: loginUrl) { (jsonResult) in
            var failureMessage: String?

            if let json = jsonResult,
                let userId = json[Key.userId] as? String,
                let sessionToken = json[Key.sessionId] as? String {
                
                let defaults = UserDefaults.standard
                
                defaults.set(userId, forKey: Key.userId)
                defaults.set(sessionToken, forKey: Key.sessionId)
                defaults.synchronize()

                self.sessionToken = sessionToken
            } else {
                failureMessage = UI.failedLogin
            }

            completionHander(failureMessage)
        }
    }

    func logout() {
        if let token = sessionToken {
            let logoutUrl = syncUrl(forCommand: Command.logout,
                                    withArguments: [Parameter.sessionToken : token])

            HttpHelper.shared.performGet(urlString: logoutUrl)
            sessionToken = nil
        }

        UserDefaults.standard.set(nil, forKey: Key.sessionId)
        UserDefaults.standard.synchronize()
    }

    func reportEvent(_ parameters: [String : String]) {
        let reportUrl = syncUrl(forCommand: Command.reportStats, withArguments: parameters)

        HttpHelper.shared.performGet(urlString: reportUrl)
    }

    func setPassword(_ password: String, completionHandler: @escaping (Bool, String?) -> ()) {
        guard let token = sessionToken else {
            completionHandler(false, UI.notLoggedIn)
            return
        }

        let passwordUrl = ApiHelper.shared.syncUrl(
            forCommand: Command.setPassword,
            withArguments: [ Parameter.sessionToken : token, Parameter.password : password ])

        HttpHelper.shared.getJsonContent(urlString: passwordUrl) { (jsonResult) in
            if let json = jsonResult, let _ = json[Key.result] as? String {
                completionHandler(true, UI.changedPassword)
            } else {
                completionHandler(false, UI.didntChangePassword)
            }
        }
    }

    func synchronizeFounders() -> Bool {
        print("Call to synchronizeFounders")
        if isSynchronizing {
            return false
        }

        isSynchronizing = true

        lastSyncTime = Date()

        let maxVersion = FounderDatabase.shared.maxFounderVersion()
        var serverMaxVersion = 0

        // Note: In the production version, we won't let users delete or create founder records,
        //       only update.  I'll leave these here because an admin might delete or insert.
        serverMaxVersion = syncDeletedFounders(serverMaxVersion)
        serverMaxVersion = syncNewFounders(serverMaxVersion)
        serverMaxVersion = syncDirtyFounders(serverMaxVersion)
        let changesMade = syncServerFounderUpdates(maxVersion, serverMaxVersion)

        if changesMade {
            NotificationCenter.default.post(Notification(name: Notice.changesMade, object: self))
        }

        AnalyticsHelper.shared.reportEvent(page: "sync")

        isSynchronizing = false

        return changesMade
    }

    func syncUrl(forCommand command: String, withArguments arguments: [String : String], encoded: Bool = true) -> String {
        var url = syncUrl(forCommand: command)

        if arguments.count > 0 {
            var first = true
            url += "?"

            for (key, value) in arguments {
                if first {
                    first = false
                } else {
                    url += "&"
                }

                if encoded {
                    let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? value
                
                    url += "\(key)=\(encodedValue)"
                } else {
                    url += "\(key)=\(value)"
                }
            }
        }

        return url
    }

    // MARK: - Private helpers

    private func allFieldsMap() -> [String : String] {
        var allFields = [String : String]()
        var index = 0
    
        for field in Founder.allFieldsIdVersion {
            allFields["f\(index)"] = field
            index += 1
        }

        return allFields
    }

    //
    // Download and save locally a photo for a Founder or spouse.
    //
    private func downloadPhoto(id: Int, isSpouse: Bool) {
        guard let token = sessionToken else {
            return
        }

        let photoType = isSpouse ? Constants.photoSpouse : Constants.photoFounder
        let url = syncUrl(forCommand: Command.getPhoto,
                          withArguments: [Parameter.sessionToken : token,
                                          Parameter.id : "\(id)",
                                          Parameter.photoType : photoType])
        HttpHelper.shared.getContent(urlString: url) { (data) in
            if let imageData = data, let photoImage = UIImage(data: imageData) {
                if isSpouse {
                    PhotoManager.shared.saveSpousePhotoFor(founderId: id, photo: photoImage)
                } else {
                    PhotoManager.shared.savePhotoFor(founderId: id, photo: photoImage)
                    let notification = NSNotification(name: Notice.changesMade,
                                                      object: self,
                                                      userInfo: [Key.userId : "\(id)"])
                    NotificationCenter.default.post(notification as Notification)
                }
            }
        }
    }

    //
    // Download the Founder and/or spouse photo(s) for this Founder record.
    //
    private func downloadPhotos(values: JSONObject) {
        if let idValue = values[Founder.Field.id] as? NSNumber {
            let id = Int(truncating: idValue)

            downloadPhoto(id: id, isSpouse: false)
            downloadPhoto(id: id, isSpouse: true)
        }
    }

    private func syncDeletedFounders(_ serverMaxVersion: Int) -> Int {
        guard let token = sessionToken else {
            return serverMaxVersion
        }

        var maxVersion = serverMaxVersion

        for deletedId in FounderDatabase.shared.deletedFounderIds() {
            let url = syncUrl(forCommand: Command.delete,
                              withArguments: [Parameter.sessionToken : token,
                                              Parameter.id : "\(deletedId)"])
            HttpHelper.shared.getContent(urlString: url, failureCode: Constants.failureCode) { (content) in
                maxVersion = Int(content) ?? maxVersion

                if content != Constants.failureCode {
                    // Sync to delete on server worked, so remove from local database
                    FounderDatabase.shared.delete(deletedId)
                }
            }
        }

        return maxVersion
    }

    private func syncDirtyFounders(_ serverMaxVersion: Int) -> Int {
        guard let token = sessionToken else {
            return serverMaxVersion
        }

        var maxVersion = serverMaxVersion

        for dirtyId in FounderDatabase.shared.dirtyFounderIds() {
            var arguments = [Parameter.sessionToken : token,
                             Parameter.id : "\(dirtyId)"]
            let fieldKeyMap = allFieldsMap()
            let founderRow = FounderDatabase.shared.founderRecordForId(dirtyId)

            for (key, field) in fieldKeyMap {
                if let value = founderRow[field] as? String {
                    arguments[key] = value
                } else if let value = founderRow[field] as? NSNumber {
                    arguments[key] = "\(value)"
                } else {
                    arguments[key] = ""
                }
            }

            let version = founderRow[Founder.Field.version] ?? "1"

            arguments[Parameter.version] = "\(version)"

            let url = syncUrl(forCommand: Command.update, withArguments: arguments)

            HttpHelper.shared.postContent(urlString: url) { (data) in
                if let founders = try? JSONSerialization.jsonObject(with: data!,
                                                        options: .allowFragments) as! JSONObject {
                    let founder = FounderDatabase.shared.founderForId(dirtyId)
                    let upResult = uploadPhoto(id: dirtyId, founder: founder, isSpouse: false) ||
                                   uploadPhoto(id: dirtyId, founder: founder, isSpouse: true)

                    // Sync to add on server worked, so update in local database

                    guard let version = founders[Founder.Field.version] as? String else {
                        return
                    }

                    founder.new = Int(Founder.Flag.existing)!

                    // If we had trouble uploading an image, this record is still dirty
                    founder.dirty = Int(upResult ? Founder.Flag.clean : Founder.Flag.dirty)!
                    founder.update(from: founders)

                    maxVersion = Int(version) ?? maxVersion

                    FounderDatabase.shared.update(founder)
                }
            }
        }

        return maxVersion
    }

    private func syncNewFounders(_ serverMaxVersion: Int) -> Int {
        guard let token = sessionToken else {
            return serverMaxVersion
        }

        var maxVersion = serverMaxVersion

        for newId in FounderDatabase.shared.newFounderIds() {
            var arguments = [Parameter.sessionToken : token]
            let fieldKeyMap = allFieldsMap()
            let founderRow = FounderDatabase.shared.founderRecordForId(newId)

            for (key, field) in fieldKeyMap {
                if let value = founderRow[field] as? String {
                    arguments[key] = value
                } else {
                    arguments[key] = ""
                }
            }

            let url = syncUrl(forCommand: Command.add, withArguments: arguments)
            
            HttpHelper.shared.postContent(urlString: url) { (data) in
                if let serverNew = try? JSONSerialization.jsonObject(with: data!,
                                                                     options: .allowFragments) as! JSONObject {
                    // Sync to add on server worked, so replace in local database
                    
                    // TODO: There could be an issue here.  Make sure this ID doesn't already exist.
                    guard let newIdValue = serverNew[Founder.Field.id] as? String,
                        let version = serverNew[Founder.Field.version] as? String else {
                            return
                    }
                    
                    let founder = FounderDatabase.shared.founderForId(newId)
                    
                    founder.id = Int(newIdValue)!
                    founder.new = Int(Founder.Flag.existing)!
                    founder.dirty = Int(Founder.Flag.clean)!
                    founder.version = Int(version)!
                    
                    maxVersion = Int(version) ?? maxVersion
                    
                    FounderDatabase.shared.update(founder)

                    _ = uploadPhoto(id: newId, founder: founder, isSpouse: false)
                    _ = uploadPhoto(id: newId, founder: founder, isSpouse: true)
                }
            }
        }
        
        return maxVersion
    }

    private func syncServerFounderUpdates(_ maxVersion: Int, _ serverMaxVersion: Int) -> Bool {
        var changesMade = false

        guard let token = sessionToken else {
            return changesMade
        }

        // Ask the server for updates between our max at the beginning of the sync and
        // the new max on the server
        let arguments = [Parameter.sessionToken : token,
                         Parameter.version : "\(maxVersion)",
                         Parameter.maxVersion : "\(serverMaxVersion)"]
        let url = syncUrl(forCommand: Command.getUpdates, withArguments: arguments)

        HttpHelper.shared.getContent(urlString: url) { (dataResult) in
            guard let data = dataResult else {
                return
            }

            if let founders = try? JSONSerialization.jsonObject(with: data,
                                                        options: .allowFragments) as! JSONArray {
                for i in 0 ..< founders.count {
                    if let founderObject = founders[i] as? JSONObject {
                        changesMade = true

                        let id = Int(truncating: founderObject[Founder.Field.id] as! NSNumber)

                        let founder = FounderDatabase.shared.founderForId(id)
                        
                        founder.new = Int(Founder.Flag.existing)!

                        if let deletedValue = founderObject[Founder.Field.deleted] as? String {
                            if deletedValue == Founder.Flag.deleted {
                                // Attempt to delete
                                FounderDatabase.shared.delete(id)
                                continue
                            }
                        }

                        // Attempt to update
                        if founder.id > 0 {
                            founder.update(from: founderObject)
                            FounderDatabase.shared.update(founder)
                            continue
                        }

                        // If we fall through to here, attempt to create
                        FounderDatabase.shared.insert(founder, from: founderObject)

                        downloadPhotos(values: founderObject)
                    }
                }
            }
        }

        return changesMade
    }

    private func syncUrl(forCommand command: String) -> String {
        return "\(Constants.baseSyncUrl)\(command).php"
    }
    
    //
    // Upload a photo for a founder or spouse.  Returns true if successful.
    //
    private func uploadPhoto(id: Int, founder: Founder, isSpouse: Bool) -> Bool {
        guard let token = sessionToken else {
            return false
        }

        var photo: UIImage?

        if (isSpouse) {
            photo = PhotoManager.shared.getSpousePhotoFor(founderId: id)
        } else {
            photo = PhotoManager.shared.getPhotoFor(founderId: id)
        }
        
        if let photoImage = photo {
            let uploadUrl = syncUrl(forCommand: Command.uploadPhoto)
            let photoType = isSpouse ? Constants.photoSpouse : Constants.photoFounder
            let photoField = isSpouse ? Founder.Field.spouseImageUrl : Founder.Field.imageUrl
            let photoParameters = [Parameter.sessionToken : token,
                                   Parameter.id : "\(id)",
                                   Parameter.photoType : photoType,
                                   Parameter.photoField : photoField]
            var success = false

            HttpHelper.shared.postMultipartContent(urlString: uploadUrl,
                                                   parameters: photoParameters,
                                                   image: photoImage) { (data) in
                if let resultObject = try? JSONSerialization.jsonObject(with: data!,
                                                        options: .allowFragments) as! JSONObject {
                    if let resultCode = resultObject[Constants.resultKey] as? String {
                        success = resultCode == Constants.successResult
                    }
                }
            }

            return success
        }

        // There was no photo to upload, so it wasn't a failure.
        return true
    }
}
