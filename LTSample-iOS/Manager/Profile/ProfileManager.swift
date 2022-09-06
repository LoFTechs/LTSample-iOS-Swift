//
//  ProfileManager.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/5/5.
//

import Foundation

protocol ProfileManagerDelagate: LTProtocol {
    func profileUpdate(userIDs: [String])
}

class ProfileManager: DelegatesObject {
    static let shared: ProfileManager = {
        let manager = ProfileManager()
        DownloadManager.shared.addDelegate(manager)
        IMManager.shared.addDelegate(manager)
        return manager
    }()
    
    private var isExecuteQuery = false
    private var queryUserProfiles = [String]()
    private var downloadAvatarDict = [String: String]()
    
    private var updateTime: TimeInterval { Date().timeIntervalSince1970 + 86400 }
    private var retryTime: TimeInterval { Date().timeIntervalSince1970 + 60 }
    
    func getChannelAvatar(_ chID: String, fileInfo: LTFileInfo? = nil) -> UIImage? {
        let image = getUserAvatar(chID)
        if image == nil, let theFileInfo = fileInfo {
            updateAvatar(chID, fileInfo: theFileInfo)
        }
        return image
    }
    
    func getUserAvatar(_ avatarID: String) -> UIImage? {
        guard avatarID != UserInfo.userID else { return UserInfo.avatar }
        let avatarPath = FileManager.default.getCachePath() + "\(avatarID).jpg"
        return UIImage(contentsOfFile: avatarPath)
    }
    
    func getUserNickname(_ userID: String) -> String? {
        guard userID != UserInfo.userID else { return "You" }
        updateProfileInfo(userID: userID)
        return UserInfo.getUserNickname(userID)
    }
    
    func getUserProfile(_ userID: String) -> (nickName: String?, avatar: UIImage?) {
        let profile = (getUserNickname(userID), getUserAvatar(userID))
        return profile
    }
    
    func updateProfileInfo(userID: String, rightnow: Bool = false) {
        guard userID.count > 0 && !queryUserProfiles.contains(userID) && !downloadAvatarDict.values.contains(userID) else {
            batchQueryUserProfile()
            return
        }
        
        if rightnow || checkProfileInfoNeedUpdate(userID: userID) {
            queryUserProfiles.append(userID)
            UserInfo.saveLastUserUpdateTime(userID, updateTime: retryTime)
            batchQueryUserProfile()
        }
    }
    
    func checkProfileInfoNeedUpdate(userID: String) -> Bool {
        guard let updateTime = UserInfo.getLastUserUpdateTime(userID), updateTime > Date().timeIntervalSince1970 else {
            return true
        }
        return false
    }
    
    private func batchQueryUserProfile() {
        guard !isExecuteQuery , let manager = IMManager.shared.getCurrentLTIMMnager() else { return }
        
        let userIDs = queryUserProfiles.count > 20 ? Array(queryUserProfiles[0..<20]) : queryUserProfiles
        
        guard userIDs.count > 0 else { return }
        
        isExecuteQuery = true
        
        manager.userHelper?.queryUserProfile(withTransID: UUID().uuidString, userIDs: userIDs, phoneNumbers: nil, completion: { (userProfileResponse, errorInfo) in
            DispatchQueue.main.async {
                if let response = userProfileResponse, response.result.count > 0 {
                    for profile in response.result {

                        if profile.userID.count > 0 && profile.nickname.count > 0 {
                            self.updateNickname(profile.userID, nickname: profile.nickname)
                        }

                        if profile.userID.count > 0 && profile.profileImageFileInfo.isExist {
                            self.updateAvatar(profile.userID, fileInfo: profile.profileImageFileInfo)
                        }

                        UserInfo.saveLastUserUpdateTime(profile.userID, updateTime: self.updateTime)
                    }
                    
                    for delegate in self.delegateArray {
                        if let profileManagerDelagate = delegate as? ProfileManagerDelagate {
                            profileManagerDelagate.profileUpdate(userIDs: userIDs)
                        }
                    }
                }
                
                self.queryUserProfiles.removeAll { userID -> Bool in
                    return userIDs.contains { return $0 == userID}
                }
                
                self.isExecuteQuery = false
                self.batchQueryUserProfile()
            }
        })
    }
    
    private func updateNickname(_ userID: String, nickname: String) {
        UserInfo.saveUserNickname(userID, nickname: nickname)
    }
    
    func updateAvatar(_ fileID: String, fileInfo: LTFileInfo) {
        guard fileInfo.isExist else {
            self.deleteAvatar(fileID, fileInfo: fileInfo)
            return
        }
        
        let storePath = FileManager.default.getCachePath() + "temp_" + (fileInfo.fileName ?? "")
                
        let action = LTStorageAction.createDownloadFileAction(with: fileInfo, storePath: storePath)
        
        FileManager.default.removeFile(path: storePath)
        
        downloadAvatarDict[storePath] = fileID
        DownloadManager.shared.execute(actions: [action])
    }
    
    func deleteAvatar(_ fileID: String, fileInfo: LTFileInfo) {

        let storePath = FileManager.default.getCachePath() + (fileInfo.fileName ?? "")
        
        guard !fileInfo.isExist, FileManager.default.fileExists(atPath: storePath) else { return }
                
        FileManager.default.removeFile(path: storePath)
        UserInfo.saveLastUserUpdateTime(fileID, updateTime:updateTime)

        for delegate in self.delegateArray {
            if let profileManagerDelagate = delegate as? ProfileManagerDelagate {
                profileManagerDelagate.profileUpdate(userIDs: [fileID])
            }
        }
    }

}

extension ProfileManager: DownloadManagerDelegate {
    
    var className: AnyClass {
        get {
            return type(of: self)
        }
    }
    
    func downloadDidFinished(acitons: [LTStorageAction]) {
        for aciton in acitons {
            if let tempStorePath = aciton.storePath, let userID = downloadAvatarDict[tempStorePath] {
                UserInfo.saveLastUserUpdateTime(userID, updateTime: updateTime)
                downloadAvatarDict.removeValue(forKey: tempStorePath)
                
                let storePath = FileManager.default.getCachePath() + aciton.fileName
                FileManager.default.removeFile(path: storePath)
                FileManager.default.moveFile(atPath: tempStorePath, toPath: storePath)
                FileManager.default.removeFile(path: tempStorePath)

                for delegate in self.delegateArray {
                    if let profileManagerDelagate = delegate as? ProfileManagerDelagate {
                        profileManagerDelagate.profileUpdate(userIDs: [userID])
                    }
                }
            }
        }
    }
    
    func downloadDidFailed(acitons: [LTStorageAction]) {
        for aciton in acitons {
            if let storePath = aciton.storePath, let userID = downloadAvatarDict[storePath] {
                UserInfo.saveLastUserUpdateTime(userID, updateTime: retryTime )
                FileManager.default.removeFile(path: storePath)
                downloadAvatarDict.removeValue(forKey: storePath)
            }
        }
    }
}

extension ProfileManager: IMManagerDelegate {
    
    func onIncomingModifyUserProfile(_ message: LTModifyUserProfileResponse?) {
        guard let msg = message else {
            return
        }
        let userProfiles = msg.userProfiles
        for userProfile in userProfiles {
            if let userID = userProfile["userID"] as? String, Int64(UserInfo.getLastUserUpdateTime(userID) ?? 0) < msg.sendTime {
                if let fileInfo = userProfile["profileImageFileInfo"] as? LTFileInfo {
                    updateAvatar(userID,fileInfo: fileInfo)
                }
                
                if let nickname = userProfile["nickname"] as? String {
                    updateNickname(userID, nickname: nickname)
                }
                UserInfo.saveLastUserUpdateTime(userID, updateTime: TimeInterval(msg.sendTime))
            }
        }
    }
    
    func onChannelProfileChanged(_ message: LTChannelProfileResponse?) {
        guard let msg = message else {
            return
        }
        let channelProfile = msg.channelProfile
        let chID = msg.chID
        if Int64(UserInfo.getLastUserUpdateTime(chID) ?? 0) < msg.sendTime {
            if let fileInfo = channelProfile["profileImageFileInfo"] as? LTFileInfo {
                updateAvatar(chID,fileInfo: fileInfo)
            }
            
            if let nickname = channelProfile["nickname"] as? String {
                updateNickname(chID, nickname: nickname)
            }
            UserInfo.saveLastUserUpdateTime(chID, updateTime: TimeInterval(msg.sendTime))
        }
    }
}
