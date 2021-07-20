//
//  IMManager.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/19.
//

import UIKit

protocol IMManagerDelegate: LTProtocol {
    
    func onConnected()
    func onDisconnected()
    func onQueryMyUserProfile(_ userProfile: LTUserProfile?)
    func onQueryMyApnsSetting(_ myApnsSetting: LTQueryUserDeviceNotifyResponse?)
    func onSetMyNickname(_ userProfile: [AnyHashable: Any]?)
    func onSetMyAvatar(_ userProfile: [AnyHashable: Any]?)
    func onSetApnsMute(_ success: Bool)
    func onSetApnsDisplay(_ success: Bool)
    func onQueryChannels(_ channels: [LTChannelResponse])
    func onQueryCurrentChannel(_ channel: LTChannelResponse?)
    func onChangeChannelPreference(_ preference: LTChannelPreference?)
    func onChangeChannelProfile(_ profile: LTChannelProfileResponse?)
    func onQueryMessages(_ messages: [LTMessageResponse])
    func onQueryChannelMembers(chID: String, _ response: LTQueryChannelMembersResponse?)

    func onIncomingModifyUserProfile(_ message: LTModifyUserProfileResponse?)
    func onIncomingMessage(_ message: LTMessageResponse?)
    func onNeedQueryMessage()
    func onNeedQueryChannels()
    func onNeedQueryMyProfile()
    func onMemberChanged(chID: String)
    func onChannelChanged()
    func onChannelProfileChanged(_ message: LTChannelProfileResponse?)
    func onNeedLeaveChat(chID: String)

}

class IMManager: NSObject {
    
    static let shared: IMManager = {
        let manager = IMManager()
        manager.addDelegate(FriendManager.shared)
        return manager
    }()
    
    private lazy var delegateArray: [IMManagerDelegate] = []
    
    var currentUser: LTUser?
    var isConnected: Bool {
        get {
            guard let userID = currentUser?.userID, let manager = LTSDK.getIMManager(withUserID: userID) else {
                return false
            }
            return manager.isConnected()
        }
    }
    
    func addDelegate(_ delegate: IMManagerDelegate) {
        if let _ = delegateArray.firstIndex(where: { $0.className == delegate.className } ) {
            return
        }
        delegateArray.append(delegate)
    }
    
    func removeDelegate(_ delegate: IMManagerDelegate) {
        if let index = delegateArray.firstIndex(where: { $0.className == delegate.className } ) {
            delegateArray.remove(at: index)
        }
    }
    
    func getCurrentLTIMMnager() -> LTIMManager? {
        return LTSDK.getIMManager(withUserID: currentUser?.userID ?? "")
    }
    
    func initSDK(_ user: LTUser) {
        currentUser = user
        getCurrentLTIMMnager()?.delegate = self
        getCurrentLTIMMnager()?.ignoreSelfIncoming = false
        connect()
    }
    
    func connect() {
        getCurrentLTIMMnager()?.connect(completion: nil)
    }
    
    func disconnect() {
        getCurrentLTIMMnager()?.disconnect(completion: nil)
    }
    
    func terminate() {
        getCurrentLTIMMnager()?.terminate()
    }
    
    //MARK: Query Self Info
    func queryMyUserProfile() {
        guard let userID = currentUser?.userID else {
            return
        }
        
        getCurrentLTIMMnager()?.userHelper.queryUserProfile(withTransID: UUID().uuidString, userIDs: [userID], phoneNumbers: nil, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Query my UserProfile fail: " + err.errorMessage)
                }
                
                for delegate in self.delegateArray {
                    delegate.onQueryMyUserProfile(response?.result.first)
                }
            }
        })
    }
    
    func queryMyApnsSetting() {
        guard let _ = currentUser?.userID else {
            return
        }
        
        getCurrentLTIMMnager()?.userHelper.queryDeviceNotify(withTransID: UUID().uuidString, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Query My Apns Setting fail: " + err.errorMessage)
                }
                
                for delegate in self.delegateArray {
                    delegate.onQueryMyApnsSetting(response)
                }
            }
        })
    }
    
    func setMyNickname(_ nickname: String) {
        getCurrentLTIMMnager()?.userHelper.setUserNicknameWithTransID(UUID().uuidString, nickname: nickname, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Set nickname fail: " + err.errorMessage)
                } else {
                    print("Set nickname success!")
                }
                
                for delegate in self.delegateArray {
                    delegate.onSetMyNickname(response?.userProfile)
                }
            }
        })
    }
    
    func setMyAvatar(_ avatar: UIImage?) {
        
        let filePath = FileManager.default.getCachePath().appending("\(UserInfo.userID).jpg")
        do {
            var isDelete = false
            if let theAvatar = avatar, let data = theAvatar.jpegData(compressionQuality: 0.5) {
                try data.write(to: URL(fileURLWithPath: filePath), options: .atomic)
            } else {
                isDelete = true
                if FileManager.default.fileExists(atPath: filePath) {
                    try FileManager.default.removeItem(atPath: filePath)
                }
            }
            getCurrentLTIMMnager()?.userHelper.setUserAvatarWithTransID(UUID().uuidString, filePath: isDelete ? "" : filePath, completion: { (response, error) in
                DispatchQueue.main.async {
                    if let err = error {
                        print("Set My Avatar fail: " + err.errorMessage)
                    } else {
                        print("Set My Avatar success!")
                        UserInfo.saveLastUserUpdateTime(UserInfo.userID, updateTime: Date().timeIntervalSince1970)
                    }
                    
                    for delegate in self.delegateArray {
                        delegate.onSetMyAvatar(response?.userProfile)
                    }
                }
            }, progress: { (response, isDone) in
                if let progress = response, progress.totalLength > 0 {
                    print("Set My Avatar progress = \(progress.loadingBytes/progress.totalLength)")
                } else {
                    print("Setting My Avatar ...")
                }
            })
        } catch {
            print(error)
            for delegate in self.delegateArray {
                delegate.onSetMyAvatar(nil)
            }
        }
    }
    
    func setApnsMute(_ mute: Bool) {
        getCurrentLTIMMnager()?.userHelper.setUserDeviceMuteWithTransID(UUID().uuidString, muteAll: mute, time: nil, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Set apns mute fail: " + err.errorMessage)
                } else {
                    print("Set apns mute success!")
                }
                
                for delegate in self.delegateArray {
                    delegate.onSetApnsMute(error == nil)
                }
            }
        })
    }
    
    func setApnsDisplaySender(_ displaySender: Bool, displayContent: Bool) {
        getCurrentLTIMMnager()?.userHelper.setUserDeviceNotifyPreviewWithTransID(UUID().uuidString, hidingSender: !displaySender, hidingContent: !displayContent, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Set apns display fail: " + err.errorMessage)
                } else {
                    print("Set apns display success!")
                }
                
                for delegate in self.delegateArray {
                    delegate.onSetApnsDisplay(error == nil)
                }
            }
        })
    }
    
    //MARK: Query Channel Info
    func queryChannels() {
        var result = [LTChannelResponse]()
        var isFailed = false
        let chTypes: Set<NSNumber> = [NSNumber(integerLiteral: LTChannelType.group.rawValue), NSNumber(integerLiteral: LTChannelType.single.rawValue)]
        getCurrentLTIMMnager()?.channelHelper.queryChannel(withTransID: UUID().uuidString, chTypes: chTypes, batchCount: 30, withMembers: false, completion: { (response, error) in
            if isFailed {
                return
            }
            
            if let err = error {
                isFailed = true
                DispatchQueue.main.async {
                    print("QueryChannels fail: " + err.errorMessage)
                    for delegate in self.delegateArray {
                        delegate.onQueryChannels([])
                    }
                }
                return
            }
            
            guard let rp = response else {
                isFailed = true
                DispatchQueue.main.async {
                    print("QueryChannels fail: rp nil" )
                    for delegate in self.delegateArray {
                        delegate.onQueryChannels([])
                    }
                }
                return
            }
            
            if rp.channels.count > 0 {
                result.append(contentsOf: rp.channels)
            }
            
            if rp.batchNo == rp.batchTotal {
                DispatchQueue.main.async {
                    for delegate in self.delegateArray {
                        delegate.onQueryChannels(result)
                    }
                }
            }
        })
    }
    
    func queryChannel(chID: String) {
        getCurrentLTIMMnager()?.channelHelper.queryChannel(withTransID: UUID().uuidString, chID: chID, withMembers: false, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Query current chat fail: " + err.errorMessage)
                }
                
                for delegate in self.delegateArray {
                    delegate.onQueryCurrentChannel(response?.channels.first)
                }
            }
        })
    }
    
    //MARK: Set Channel
    
    func setChannelAvatar(chID: String, avatar: UIImage?, completion: ((Bool) ->Void)? = nil) {
        let avatarPath = FileManager.default.getCachePath().appending("\(chID).jpg")
        var isDelete = false
        do {
            if let theAvatar = avatar, let data = theAvatar.jpegData(compressionQuality: 0.5) {
                try data.write(to: URL(fileURLWithPath: avatarPath), options: .atomic)
            } else {
                isDelete = true
                if FileManager.default.fileExists(atPath: avatarPath) {
                    try FileManager.default.removeItem(atPath: avatarPath)
                }
            }
            
            getCurrentLTIMMnager()?.channelHelper.setChannelAvatarWithTransID(UUID().uuidString, chID: chID, avatarPath: isDelete ? "" : avatarPath, completion: { (response, error) in
                if let err = error {
                    print("Set group chat avatar fail: " + err.errorMessage)
                    completion?(false)
                } else {
                    print("Set group chat avatar success")
                    completion?(true)
                }
            }, progress: nil)
        } catch {
            print(error)
        }
    }
    
    func setChannelSubject(chID: String, subject: String?, completion: ((Bool) ->Void)? = nil) {
        getCurrentLTIMMnager()?.channelHelper.setChannelSubjectWithTransID(UUID().uuidString, chID: chID, subject: subject,completion: { (response, error) in
            if let err = error {
                print("Set group chat subject fail: " + err.errorMessage)
                completion?(false)
            } else {
                print("Set group chat subject success")
                completion?(true)
            }
            
            if chID != response?.chID {
                return
            }
            
            for delegate in self.delegateArray {
                delegate.onChangeChannelProfile(response)
            }
        })
    }
    
    func setMyChannelNickname(chID: String,  nickname: String) {
        getCurrentLTIMMnager()?.channelHelper.setChannelUserNicknameWithTransID(UUID().uuidString, chID: chID, nickname: nickname, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Set my chNickname fail: " + err.errorMessage)
                } else {
                    print("Set my chNickname success!")
                }
                
                if chID != response?.chID {
                    return
                }
                
                for delegate in self.delegateArray {
                    delegate.onChangeChannelPreference(response?.channelPreference)
                }
            }
        })
    }
    
    func setChannelMute(chID: String, mute: Bool, completion: ((Bool) ->Void)? = nil) {
        getCurrentLTIMMnager()?.channelHelper.setChannelMuteWithTransID(UUID().uuidString, chID: chID, isMute: mute, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Set mute fail: " + err.errorMessage)
                    completion?(false)
                } else {
                    print("Set mute success!")
                    completion?(true)
                }
                
                if chID != response?.chID {
                    return
                }
                
                for delegate in self.delegateArray {
                    delegate.onChangeChannelPreference(response?.channelPreference)
                }
            }
        })
    }
    
    func dismissChannel(chID: String) {
        getCurrentLTIMMnager()?.channelHelper.dismissChannel(withTransID: UUID().uuidString, chID: chID, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Dismiss fail: " + err.errorMessage)
                } else {
                    print("Dismiss success!")
                }
            }
        })
    }
    
    func leaveChannel(chID: String) {
        getCurrentLTIMMnager()?.channelHelper.leaveChannel(withTransID: UUID().uuidString, chID: chID, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Leave fail: " + err.errorMessage)
                } else {
                    print("Leave success!")
                }
            }
        })
    }
    
    func deleteChannelMessages(chID: String) {
        getCurrentLTIMMnager()?.messageHelper.deleteChannelMessages(withTransID: UUID().uuidString, chID: chID, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Dismiss fail: " + err.errorMessage)
                } else {
                    print("Dismiss success!")
                }
            }
        })
    }
    
    //MARK: - Message
    //MARK: - Query Message
    func queryMessages(chID: String, markTS: Int64) {
        getCurrentLTIMMnager()?.messageHelper.queryMessage(withTransID: UUID().uuidString, chID: chID, markTS: markTS, afterN: -20, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Leave fail: " + err.errorMessage)
                }
                var result: [LTMessageResponse] = []
                if let rp = response, rp.messages.count > 0 {
                    result.append(contentsOf: rp.messages)
                }
                
                for delegate in self.delegateArray {
                    delegate.onQueryMessages(result)
                }
            }
        })
    }
    
    //MARK: - Send Message
    func sendTextMessage(chID: String, chType: LTChannelType, text: String, completion: ((Bool)->Void)? = nil) {
        let message = LTTextMessage()
        message.msgContent = text
        sendLTMessage(chID: chID, chType: chType, message: message, completion: completion)
    }
    
    func sendImageMessage(chID: String, chType: LTChannelType, image: UIImage, completion: ((Bool)->Void)? = nil) {
        let message = LTImageMessage()
        message.transID = UUID().uuidString
        message.chID = chID
        message.chType = chType
        let uploadImg = image.scaleToLimit(720)
        let path = FileManager.default.getCachePath().appending("\(message.transID).jpg")
        do {
            if let data = uploadImg.jpegData(compressionQuality: 0.5) {
                try data.write(to: URL(fileURLWithPath: path), options: .atomic)
            }
        } catch {
            print(error)
        }
        
        if path.count > 0 {
            let url = URL.init(fileURLWithPath: path)
            message.fileName = url.lastPathComponent
        }
        message.imagePath = path
        message.thumbnailPath = path
        sendLTMessage(chID: chID, chType: chType, message: message, completion: completion)

    }

    func sendDocumentMessage(chID: String, chType: LTChannelType, filePath: String) {
        let message = LTDocumentMessage()
        message.filePath = filePath
        if filePath.count > 0 {
            let url = URL.init(fileURLWithPath: filePath)
            message.fileName = url.lastPathComponent
        }
        sendLTMessage(chID: chID, chType: chType, message: message)
    }

    private func sendLTMessage(chID: String, chType: LTChannelType, message: LTMessage, completion: ((Bool)->Void)? = nil) {
        message.chID = chID
        message.chType = chType
        message.transID = UUID().uuidString
        getCurrentLTIMMnager()?.messageHelper.send(message, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Send fail: " + err.errorMessage)
                    completion?(false)
                } else {
                    print("Send success")
                    completion?(true)
                }
            }
        })
    }
    
    //MARK - Delete Message
    func deleteMessage(_ msgID: String) {
        getCurrentLTIMMnager()?.messageHelper.deleteMessages(withTransID: UUID().uuidString, msgIDs: [msgID], completion: { (response, error) in
            DispatchQueue.main.async { [self] in
                if let err = error {
                    print("Send fail: " + err.errorMessage)
                } else {
                    print("Send success")
                }
                
                guard let rp = response else {
                    return
                }
                
                for delegate in self.delegateArray {
                    delegate.onNeedQueryMessage()
                }
            }
        })
    }
    
    func recallMessage(_ msgID: String) {
        getCurrentLTIMMnager()?.messageHelper.recallMessage(withTransID: UUID().uuidString, msgIDs: [msgID], silentMode: false, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Recall message fail: " + err.errorMessage)
                } else {
                    print("Recall message success")
                }
            }
        })
    }
    
    //MARK - Channel Member
    func queryChannelMember(chID: String, lastUserID: String, count: Int) {
        getCurrentLTIMMnager()?.channelHelper.queryChannelMembers(withTransID: UUID().uuidString, chID: chID, lastUserID: lastUserID, count: UInt(count), completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Query Channel Member fail: " + err.errorMessage)
                }
                
                for delegate in self.delegateArray {
                    delegate.onQueryChannelMembers(chID:chID, response)
                }
            }
        })
    }
    
    func setMemberRole(chID: String, userID: String, roleID: LTChannelRole) {
        getCurrentLTIMMnager()?.channelHelper.setMemberRoleWithTransID(UUID().uuidString, chID: chID, userID: userID, roleID: roleID, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Set member role fail: " + err.errorMessage)
                }
                
                guard let chID = response?.chID else { return }

                for delegate in self.delegateArray {
                    delegate.onMemberChanged(chID: chID)
                }
            }
        })
    }
    
    func kickChannelMember(chID: String, userID: String) {
        let member = LTMemberModel()
        member.userID = userID
        let members: Set<LTMemberModel> = [member]
        
        getCurrentLTIMMnager()?.channelHelper.kickMembers(withTransID: UUID().uuidString, chID: chID, members: members, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Kick member fail: " + err.errorMessage)
                }
                
                guard let chID = response?.chID else { return }

                for delegate in self.delegateArray {
                    delegate.onMemberChanged(chID: chID)
                }
            }
        })
    }
    
    func createGroupChannel(_ friends: [Friend], subject: String, avatar: UIImage? = nil, completion: ((Bool, String) ->Void)? = nil) {
        var set = Set<LTMemberModel>()
        for friend in friends {
            let member = LTMemberModel()
            member.userID = friend.userID
            set.insert(member)
        }

        let chID = UUID().uuidString
        getCurrentLTIMMnager()?.channelHelper.createGroupChannel(withTransID: UUID().uuidString, chID: chID, channelSubject: subject, members: set, completion: { (response, error) in
            DispatchQueue.main.async { [self] in
                if let err = error {
                    print("Create group chat fail: " + err.errorMessage)
                    completion?(false, "")
                } else {
                    print("Create group chat success")
                    completion?(true, chID)
                    
                    if let img = avatar {
                        setChannelAvatar(chID: chID, avatar: img, completion: nil)
                    }
                }
            }
        })
    }
    
    func inviteChannelMember(chID: String, members: [LTMemberModel]) {
        let set = Set(members)
        
        getCurrentLTIMMnager()?.channelHelper.inviteMembers(withTransID: UUID().uuidString, chID: chID, members: set, joinMethod: .normal, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("Invite members fail: " + err.errorMessage)
                } else {
                    print("Invite members success")
                }
                
                for delegate in self.delegateArray {
                    delegate.onMemberChanged(chID: chID)
                }
            }
        })
    }
    
    func markRead(chID: String, markTS: Int64, completion: ((Bool) ->Void)? = nil) {
        getCurrentLTIMMnager()?.messageHelper.markRead(withTransID: UUID().uuidString, chID: chID, markTS: markTS, completion: { (response, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("MarkRead fail: " + err.errorMessage)
                    completion?(false)
                } else {
                    print("MarkRead success")
                    completion?(true)
                }
            }
        })
    }
  
}

extension IMManager: LTIMManagerDelegate {
    
    //MARK - Common
    func ltimManagerConnected(withReceiver receiver: String) {
        DispatchQueue.main.async {
            for delegate in self.delegateArray {
                delegate.onConnected()
            }
        }
    }
    
    func ltimManagerDisconnected(withReceiver receiver: String, error: LTErrorInfo?) {
        DispatchQueue.main.async {
            for delegate in self.delegateArray {
                delegate.onDisconnected()
            }
        }
    }
    
    func ltimManagerIncomingMessage(_ response: LTMessageResponse?, receiver: String) {
        DispatchQueue.main.async {
            for delegate in self.delegateArray {
                delegate.onIncomingMessage(response)
            }
        }
    }
    
    //MARK - Channel
    func ltimManagerIncomingCreateChannel(_ response: LTCreateChannelResponse?, receiver: String) {
        DispatchQueue.main.async {
            for delegate in self.delegateArray {
                delegate.onNeedQueryChannels()
            }
        }
    }
    
    func ltimManagerIncomingDismissChannel(_ response: LTDismissChannelResponse?, receiver: String) {
        DispatchQueue.main.async {
            guard let chID = response?.chID else { return }
            
            for delegate in self.delegateArray {
                delegate.onNeedLeaveChat(chID: chID)
            }
        }
    }
    
    func ltimManagerIncomingChannelPreference(_ response: LTChannelPreferenceResponse?, receiver: String) {
        DispatchQueue.main.async {
            for delegate in self.delegateArray {
                delegate.onChannelChanged()
            }
        }
    }
    
    func ltimManagerIncomingChannelProfile(_ response: LTChannelProfileResponse?, receiver: String) {
        DispatchQueue.main.async {
            for delegate in self.delegateArray {
                delegate.onChannelProfileChanged(response)
            }
        }
    }
    
    //MARK: Channel Member
    func ltimManagerIncomingJoinChannel(_ response: LTJoinChannelResponse?, receiver: String) {
        guard let chID = response?.chID else { return }
        
        DispatchQueue.main.async {
            
            for delegate in self.delegateArray {
                delegate.onIncomingMessage(response)
                delegate.onMemberChanged(chID: chID)
            }
        }
    }

    func ltimManagerIncomingInviteMember(_ response: LTInviteMemberResponse?, receiver: String) {
        guard let chID = response?.chID else { return }
        
        DispatchQueue.main.async {
            
            for delegate in self.delegateArray {
                delegate.onIncomingMessage(response)
                delegate.onMemberChanged(chID: chID)
            }
        }
    }
    
    func ltimManagerIncomingKickMember(_ response: LTKickMemberResponse?, receiver: String) {
        DispatchQueue.main.async {
            guard let chID = response?.chID else { return }
            
            if let filter = response?.members.filter({ $0.userID == UserInfo.userID}), filter.count > 0 {
                for delegate in self.delegateArray {
                    delegate.onNeedLeaveChat(chID: chID)
                }
            } else {
                for delegate in self.delegateArray {
                    delegate.onIncomingMessage(response)
                    delegate.onMemberChanged(chID: chID)
                }
            }
        }
    }
    
    func ltimManagerIncomingLeaveChannel(_ response: LTLeaveChannelResponse?, receiver: String) {
        guard let chID = response?.chID else { return }

        DispatchQueue.main.async {
            if response?.senderID == UserInfo.userID {
                for delegate in self.delegateArray {
                    delegate.onNeedLeaveChat(chID: chID)
                }
            } else {
                for delegate in self.delegateArray {
                    delegate.onIncomingMessage(response)
                    delegate.onMemberChanged(chID: chID)
                }
            }
        }
    }
    
    func ltimManagerIncomingMemberRole(_ response: LTMemberRoleResponse?, receiver: String) {
        guard let chID = response?.chID else { return }

        DispatchQueue.main.async {
            
            for delegate in self.delegateArray {
                delegate.onIncomingMessage(response)
                delegate.onMemberChanged(chID: chID)
            }
        }
    }


    //MARK: Message
    func ltimManagerIncomingSendMessage(_ response: LTSendMessageResponse?, receiver: String) {
        DispatchQueue.main.async {
            for delegate in self.delegateArray {
                delegate.onIncomingMessage(response)
            }
        }
    }

    func ltimManagerIncomingDeleteMessages(_ response: LTDeleteMessagesResponse?, receiver: String) {
        DispatchQueue.main.async {
            for delegate in self.delegateArray {
                delegate.onNeedQueryMessage()
            }
        }
    }

    func ltimManagerIncomingRecall(_ response: LTRecallResponse?, receiver: String) {
        DispatchQueue.main.async {
            for delegate in self.delegateArray {
                delegate.onNeedQueryMessage()
            }
        }
    }

    //MARK: User
    func ltimManagerIncomingSetUserProfile(_ response: LTSetUserProfileResponse?, receiver: String) {
        DispatchQueue.main.async {
            for delegate in self.delegateArray {
                delegate.onNeedQueryMyProfile()
            }
        }
    }
    
    func ltimManagerIncomingModifyUserProfile(_ response: LTModifyUserProfileResponse?, receiver: String) {
            for delegate in self.delegateArray {
                delegate.onIncomingModifyUserProfile(response)
            }
    }
    
}
