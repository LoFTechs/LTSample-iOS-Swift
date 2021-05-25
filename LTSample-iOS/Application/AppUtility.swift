//
//  AppUtility.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/20.
//

import UIKit

class AppUtility {
    
    class func getContent(_ type: LTMessageType, content: String) -> String {
        if type == .text {
            return content
        } else if type == .image {
            return "Sent a image message."
        } else if type == .video {
            return "Sent a video message."
        } else if type == .voice {
            return "Sent a voice message."
        } else if type == .contact {
            return "Sent a contact message."
        } else if type == .location {
            return "Sent a location message."
        } else if type == .document {
            return "Sent a document message."
        } else if type == .answerInvition {
            return "Join channel."
        } else if type == .createChannel {
            return "Create a channel."
        } else if type == .inviteChatroom {
            return "Invite members."
        } else if type == .leaveChannel {
            return "Leave channel."
        } else if type == .kickChannel {
            return "Kick members."
        } else if type == .setRoleID {
            return "Set members role."
        } else if type == .setChannelProfile {
            return "Set channel profile."
        } else if type == .recall {
            return "Recall messages"
        }
        
        return ""
    }
    
}

//MARK: UI
extension AppUtility {
    
    class func alert(_ string: String) {
        print(string)
        let alert = UIAlertController(title: string, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Confirm", style: .default, handler: nil)
        alert.addAction(action)
        topVC()?.present(alert, animated: true, completion: nil)
    }
    
    class func topVC() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            return topController
        }
        
        return nil
    }
    
    class func isLand() -> Bool {
        return UIScreen.main.bounds.width > UIScreen.main.bounds.height
    }
    
    class var deviceWidth: CGFloat {
        get {
            if isLand() {
                return UIScreen.main.bounds.height
            }
            return UIScreen.main.bounds.width
        }
    }
}
