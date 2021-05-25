//
//  FileManager+Extension.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/4/19.
//

import Foundation

extension FileManager {
    func getCachePath() -> String {
        let url = containerURL(forSecurityApplicationGroupIdentifier: "group.com.loftechs.sample")
        let cachePath = createDirectory(url!.path + "/Caches")
        return cachePath + "/"
    }
    
    func createDirectory(_ path: String) -> String {
        do {
            if !fileExists(atPath: path) {
                try createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
            }
        } catch {
            print(error.localizedDescription)
        }
        return path
    }
    
    func removeCachePath() {
        let url = containerURL(forSecurityApplicationGroupIdentifier: "group.com.loftechs.sample")
        let cachePath = url!.path + "/Caches"
        do {
            if fileExists(atPath: cachePath) {
                try removeItem(atPath: cachePath)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeFile(path: String) {
        do {
            if fileExists(atPath: path) {
                try removeItem(atPath: path)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func moveFile(atPath: String, toPath: String) {
        do {
            try moveItem(atPath: atPath, toPath: toPath)
        } catch {
            print(error.localizedDescription)
        }
    }
}
