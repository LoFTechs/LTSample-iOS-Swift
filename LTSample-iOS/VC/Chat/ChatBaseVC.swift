//
//  ChatBaseVC.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/5.
//

import UIKit

class ChatBaseVC: LTListVC {
    var chatNavigation: ChatNavigationController {
        get {
            guard let navi = navigationController as? ChatNavigationController else {
                print("Please setup ChatNavigationController.")
                return ChatNavigationController()
            }
            
            return navi
        }
    }
    
    var isSingle: Bool {
        get {
            if chatNavigation.channel?.chType == .single {
                return true
            }
            return false
        }
    }
    
    var isModerator: Bool {
        get {
            if chatNavigation.channel?.privilege.roleID == LTChannelRole.moderator {
                return true
            }
            return false
        }
    }

}
