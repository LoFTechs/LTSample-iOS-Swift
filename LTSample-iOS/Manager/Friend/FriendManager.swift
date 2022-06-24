//
//  FriendManager.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/27.
//

import Foundation

struct Friend {
    var userID: String
}

protocol FriendManagerDelegate: LTProtocol {
    func friendManagerSearchFriendFail(_ errMsg: String)
    func friendManagerWillAddFriend()
    func friendManagerDidAddFriend(_ success: Bool, _ errMsg: String?)
    func friendManagerChangedFriends()
}

class FriendManager {
    static let shared = FriendManager()
    
    private lazy var delegateArray = [FriendManagerDelegate]()
    
    var friends = [Friend]()
    
    func addDelegate(_ delegate: FriendManagerDelegate) {
        if let _ = delegateArray.firstIndex(where: { $0.className == delegate.className } ) {
            return
        }
        delegateArray.append(delegate)
    }
    
    func removeDelegate(_ delegate: FriendManagerDelegate) {
        if let index = delegateArray.firstIndex(where: { $0.className == delegate.className } ) {
            delegateArray.remove(at: index)
        }
    }
    
    class func getUserID(chID: String) -> String {
        return chID.replacingOccurrences(of: UserInfo.userID, with: "").replacingOccurrences(of: ":", with: "")
    }
    
    func addFriend(_ account: String) {
        LTSDK.getUserStatus(withSemiUIDs: [account]) { (response, userStatuses) in
            DispatchQueue.main.async {
                if response.returnCode == .success {
                    
                    var userID = ""
                    
                    userStatuses?.forEach({ userStatuses in
                        if userStatuses.userID.count > 0, userStatuses.canIM {
                            if userStatuses.brandID == Config.brandID {
                                userID = userStatuses.userID;
                                return
                            } else if userID.count == 0 {
                                userID = userStatuses.userID;
                            }
                        }
                    })
                    
                    if userID.count > 0 {
                        
                        self.createFriendShip(userID: userID)
                        
                    } else {
                        for delegate in self.delegateArray {
                            delegate.friendManagerSearchFriendFail("User not exist.")
                        }
                    }
                    
                } else {
                    
                    for delegate in self.delegateArray {
                        delegate.friendManagerSearchFriendFail(response.returnMessage ?? "")
                    }
                }
            }
        }
    }
    
    private func createFriendShip(userID: String) {
        if let _ = friends.firstIndex(where: { $0.userID == userID}) {
            for delegate in self.delegateArray {
                delegate.friendManagerSearchFriendFail("This friend already existed.")
            }
            return
        }
        
        
        guard let  manager = IMManager.shared.getCurrentLTIMMnager() else {
            for delegate in self.delegateArray {
                delegate.friendManagerSearchFriendFail("Get LTIManager error.")
            }
            return
        }
        
        for delegate in self.delegateArray {
            delegate.friendManagerWillAddFriend()
        }
        let member = LTMemberModel()
        member.userID = userID
        manager.channelHelper?.createSingleChannel(withTransID: UUID().uuidString, member: member, completion: { (respone, error) in
            DispatchQueue.main.async {
                if let err = error {
                    for delegate in self.delegateArray {
                        delegate.friendManagerDidAddFriend(false, err.errorMessage)
                    }
                    return
                }
                
                let newFriend = Friend(userID: userID)
                self.friends.append(newFriend)
                
                for delegate in self.delegateArray {
                    delegate.friendManagerDidAddFriend(true, nil)
                    delegate.friendManagerChangedFriends()
                }
            }
        })
    }
    
    func clean() {
        friends.removeAll()
    }
}

extension FriendManager: IMManagerDelegate {
    
    var className: AnyClass {
        get {
            return type(of: self)
        }
    }
    
    func onQueryChannels(_ channels: [LTChannelResponse]) {
        let singles = channels.filter{ $0.chType == .single }
        if singles.count == 0 {
            return
        }
        
        friends.removeAll()
        for channel in singles {
            let userID = FriendManager.getUserID(chID: channel.chID)
            if userID.count == 0 {
                continue
            }
            
            let friend = Friend(userID: userID)
            friends.append(friend)
            ProfileManager.shared.updateProfileInfo(userID: userID, rightnow: true)
        }
        
        friends.sort{ $0.userID < $1.userID }
        
        for delegate in self.delegateArray {
            delegate.friendManagerChangedFriends()
        }
    }
}
