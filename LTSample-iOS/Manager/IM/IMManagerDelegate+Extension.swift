//
//  IMManagerDelegate+Extension.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/5/9.
//

import Foundation

extension IMManagerDelegate {
    
    func onConnected() {
        
    }
    
    func onDisconnected() {
        
    }
    
    func onQueryMyUserProfile(_ userProfile: LTUserProfile?) {
        
    }
    
    func onQueryMyApnsSetting(_ myApnsSetting: LTQueryUserDeviceNotifyResponse?) {
        
    }
    
    func onSetMyNickname(_ userProfile: [AnyHashable : Any]?) {
        
    }
    
    func onSetMyAvatar(_ userProfile: [AnyHashable : Any]?) {
        
    }
    
    func onSetApnsMute(_ success: Bool) {
        
    }
    
    func onSetApnsDisplay(_ success: Bool) {
        
    }
    
    func onQueryChannels(_ channels: [LTChannelResponse]) {
    }
    
    func onQueryCurrentChannel(_ channel: LTChannelResponse?) {
        
    }
    
    func onChangeChannelPreference(_ preference: LTChannelPreference?) {
        
    }
    
    func onChangeChannelProfile(_ profile: LTChannelProfileResponse?) {
        
    }
    
    func onQueryMessages(_ messages: [LTMessageResponse]) {
        
    }
    
    func onQueryChannelMembers(chID: String, _ response: LTQueryChannelMembersResponse?) {
        
    }
    
    func onIncomingModifyUserProfile(_ message: LTModifyUserProfileResponse?) {
        
    }
    
    func onIncomingMessage(_ message: LTMessageResponse?) {
        
    }
    
    func onNeedQueryMessage() {
        
    }
    
    func onNeedQueryChannels() {
        
    }
    
    func onNeedQueryMyProfile() {
        
    }
    
    func onMemberChanged(chID: String) {
        
    }
    
    func onChannelChanged() {
        
    }
    
    func onChannelProfileChanged(_ message: LTChannelProfileResponse?) {
        
    }
    
    func onNeedLeaveChat(chID: String) {
        
    }
}
