//
//  UserInfo.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/19.
//

import Foundation
import MessageKit

class UserInfo {
    
    static let currentUser = UserInfo()
    
    private static let info = load()
    private static func load() -> UserDefaults! {
        let userInfo = UserDefaults.init(suiteName: "group.com.loftechs.sample")
        return userInfo
    }
    
    class var accountID: String {
        get {
            guard let accountID = info?.object(forKey: "ACCOUNTID") as? String else {
                return ""
            }
            return accountID
        }
    }
    
    class var userID: String {
        get {
            guard let userID = info?.object(forKey: "USERID") as? String else {
                return ""
            }
            return userID
        }
    }
    
    class var uuid: String {
        get {
            guard let uuid = info?.object(forKey: "UUID") as? String else {
                return ""
            }
            return uuid
        }
    }
    
    class func save(_ dict: [AnyHashable: Any]) {
        if let semiUID = dict["semiUID"] as? String, semiUID.count > 0 {
            info?.setValue(semiUID, forKey: "ACCOUNTID")
        }
        
        if let userID = dict["userID"] as? String, userID.count > 0 {
            info?.setValue(userID, forKey: "USERID")
        }
        
        if let uuid = dict["uuid"] as? String, uuid.count > 0 {
            info?.setValue(uuid, forKey: "UUID")
        }
    }
    
    class func delete() {
        info?.removeObject(forKey: "ACCOUNTID")
        info?.removeObject(forKey: "USERID")
        info?.removeObject(forKey: "UUID")
        info?.removeObject(forKey: "NICKNAME")
        info?.removeObject(forKey: "NOTIFICATION_DISPLAY")
        info?.removeObject(forKey: "NOTIFICATION_CONTENT")
        info?.removeObject(forKey: "NOTIFICATION_MUTE")
        info?.removeObject(forKey: "LAST_USER_UPDATE_TIME")
        info?.removeObject(forKey: "USER_NICKNAME")
    }
    
    
    class var notificationDisplay: Bool {
        get {
            guard let notificationDisplay = info?.object(forKey: "NOTIFICATION_DISPLAY") as? Bool else {
                return true
            }
            return notificationDisplay
        }
    }
    
    class var notificationContent: Bool {
        get {
            guard let notificationContent = info?.object(forKey: "NOTIFICATION_CONTENT") as? Bool else {
                return true
            }
            return notificationContent
        }
    }
    
    class var notificationMute: Bool {
        get {
            guard let notificationMute = info?.object(forKey: "NOTIFICATION_MUTE") as? Bool else {
                return false
            }
            return notificationMute
        }
    }
    
    class var nickname: String {
        get {
            guard let nickname = info?.object(forKey: "NICKNAME") as? String else {
                return ""
            }
            return nickname
        }
    }
    
    class var avatar: UIImage? {
        get {
            let filePath = FileManager.default.getCachePath().appending("\(userID).jpg")
            let img = UIImage(contentsOfFile: filePath)
            return img
        }
    }
    
    class func saveNotificationDisplay(_ display: Bool) {
        info?.setValue(display, forKey: "NOTIFICATION_DISPLAY")
    }
    
    class func saveNotificationContent(_ content: Bool) {
        info?.setValue(content, forKey: "NOTIFICATION_CONTENT")
    }
    
    class func saveNotificationMute(_ mute: Bool) {
        info?.setValue(mute, forKey: "NOTIFICATION_MUTE")
    }
    
    class func saveNickname(_ nickname: String) {
        info?.setValue(nickname, forKey: "NICKNAME")
    }
}

//MARK: - UserProfile

extension UserInfo {
    class func getLastUserUpdateTime(_ userID: String) -> Double? {
        let lastUserUpdateTime = info?.object(forKey: "LAST_USER_UPDATE_TIME") as? [String: Double] ?? [:]
        print("getLastUserUpdateTime:\(userID):\(lastUserUpdateTime[userID] ?? 0 )")
        return lastUserUpdateTime[userID]
    }
    
    class func saveLastUserUpdateTime(_ userID: String, updateTime: Double) {
        var lastUserUpdateTime = info?.object(forKey: "LAST_USER_UPDATE_TIME") as? [String: Double] ?? [:]
        lastUserUpdateTime[userID] = updateTime
        info?.setValue(lastUserUpdateTime, forKey: "LAST_USER_UPDATE_TIME")
        print("saveLastUserUpdateTime:\(userID):\(updateTime)")
    }
    
    class func getUserNickname(_ userID: String) -> String? {
        let userNickname = info?.object(forKey: "USER_NICKNAME") as? [String: String] ?? [:]
        print("getUserNickname:\(userID):\(userNickname[userID] ?? "" )")
        return userNickname[userID]
    }
    
    class func saveUserNickname(_ userID: String, nickname: String) {
        var userNickname = info?.object(forKey: "USER_NICKNAME") as? [String: String] ?? [:]
        userNickname[userID] = nickname
        info?.setValue(userNickname, forKey: "USER_NICKNAME")
        print("saveUserNickname:\(userID):\(nickname)")
    }
}

extension UserInfo: SenderType {
    var senderId: String {
        return UserInfo.userID
    }
    
    var displayName: String {
        return UserInfo.nickname
    }
    
}
