//
//  Gravatar.swift
//  MoinApp
//
//  Created by Sören Gade on 07.10.17.
//  Copyright © 2017 Sören Gade. All rights reserved.
//

import UIKit

enum GravatarError : Error {
    case invalidImageData
}

class Gravatar {
    private static let baseURL = URL(string: "https://www.gravatar.com/avatar")!
    private static let cacheExpirationTime: TimeInterval = 86400 // 1 day

    private let urlSession: URLSession

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    func image(forHash hash: String, completion: @escaping (Result<UIImage>) -> Void) {
        if let cacheImage = self.checkCacheForImage(withHash: hash) {
            return completion(.success(cacheImage))
        }

        let url = Gravatar.baseURL.appendingPathComponent(hash)
        let task = self.urlSession.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                return completion(.error(error!))
            }
            guard let data = data,
                let image = UIImage(data: data) else {
                    return completion(.error(GravatarError.invalidImageData))
            }

            // cache
            if let file = self.cacheFile(forHash: hash) {
                do {
                    try UIImagePNGRepresentation(image)!.write(to: file)
                } catch {
                    NSLog("Failed to cache \( hash ): \( error ).")
                }
            }

            completion(.success(image))
        }
        task.resume()
    }

    private func checkCacheForImage(withHash hash: String) -> UIImage? {
        guard let file = self.cacheFile(forHash: hash) else {
            return nil
        }
        let filePathWithoutScheme = file.absoluteString.replacingOccurrences(of: "\(file.scheme!)://", with: "")
        guard FileManager.default.fileExists(atPath: filePathWithoutScheme) else {
            return nil
        }

        guard let attributes = try? FileManager.default.attributesOfItem(atPath: filePathWithoutScheme) else {
            return nil
        }

        guard let modificationDate = attributes[FileAttributeKey.modificationDate] as? Date else {
            return nil
        }

        if modificationDate.addingTimeInterval(Gravatar.cacheExpirationTime) < Date() {
            // cache has expired
            return nil
        }

        return UIImage(contentsOfFile: filePathWithoutScheme)
    }

    private func cacheFile(forHash hash: String) -> URL? {
        return self.cachesDirectory.appendingPathComponent(hash)
    }

    private var cachesDirectory: NSURL {
        let cachesDirectories = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let cachesDirectory = cachesDirectories[0]
        return NSURL(fileURLWithPath: cachesDirectory, isDirectory: true)
    }
}
