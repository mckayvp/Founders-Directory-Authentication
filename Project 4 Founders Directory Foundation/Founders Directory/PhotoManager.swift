//
//  PhotoManager.swift
//  Founders Directory
//
//  Created by Steve Liddle on 11/3/16.
//  Copyright © 2016 Steve Liddle. All rights reserved.
//

import UIKit

class PhotoManager {

    // MARK: - Properties

    lazy var fileManager = FileManager()
    
    // MARK: - Singleton

    static let shared = PhotoManager()

    fileprivate init() { }

    func getPhoto(filename: String) -> UIImage? {
        if let photoUrl = urlForExistingPhoto(filename) {
            if let imageData = try? Data(contentsOf: photoUrl) {
                return UIImage(data: imageData)
            }
        }

        return nil
    }

    func getPhotoFor(founderId: Int) -> UIImage? {
        return getPhoto(filename: "founder\(founderId)")
    }

    func getSpousePhotoFor(founderId: Int) -> UIImage? {
        return getPhoto(filename: "spouse\(founderId)")
    }

    func savePhotoFor(founderId: Int, photo: UIImage) {
        savePhoto(filename: "founder\(founderId)", with: photo)
    }
    
    func saveSpousePhotoFor(founderId: Int, photo: UIImage) {
        savePhoto(filename: "spouse\(founderId)", with: photo)
    }

    func urlForFileName(_ filename: String) -> String? {
        if let photoUrl = urlForExistingPhoto(filename) {
            return photoUrl.absoluteString
        }

        return nil
    }

    func urlForExistingPhoto(_ filename: String) -> URL? {
        for cacheDir in fileManager.urls(for: .cachesDirectory, in: .userDomainMask) {
            let photoUrl = cacheDir.appendingPathComponent(filename)

            if fileManager.fileExists(atPath: photoUrl.path) {
                return photoUrl
            }
        }

        return nil
    }

    func urlForNewPhoto(_ filename: String) -> URL {
        if let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            return cacheDir.appendingPathComponent(filename)
        }

        return URL(string: "defaultPhoto-60")!
    }

    func savePhoto(filename: String, with photoImage: UIImage) {
        let photoUrl = urlForNewPhoto(filename)
        let imageData = photoImage.jpegData(compressionQuality: 1.0)

        if fileManager.fileExists(atPath: photoUrl.absoluteString) {
            try? fileManager.removeItem(at: photoUrl)
        }

        try? imageData?.write(to: photoUrl, options: .atomic)
    }
}
