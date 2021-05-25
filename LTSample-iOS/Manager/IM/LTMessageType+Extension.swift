//
//  LTMessageType+Extension.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/5/6.
//

import Foundation

extension LTMessageType {
    func getMessage(sender:String, msgContent: String = "") -> NSAttributedString {
        switch self {
        case .text: break
        case .image:
            return getIconText(sender: sender, icon: UIImage(named: "TabBarCameraActive_Normal")?.withTintColor(.systemGray), text: "Photo")
        case .video:
            return getIconText(sender: sender, icon: UIImage(named: "SwitchToVideoButton_Normal")?.withTintColor(.systemGray), text: "Video")
        case .voice:
            return getIconText(sender: sender, icon: UIImage(named: "MicRecTemplate_Normal")?.withTintColor(.systemGray), text: "Voice message")
        case .contact:
            return getIconText(sender: sender, icon: UIImage(systemName: "person.crop.circle")?.withTintColor(.systemGray), text: "Contact")
        case .location:
            return getIconText(sender: sender, icon: UIImage(named: "Location_Normal")?.withTintColor(.systemGray), text: "Location")
        case .document:
            return getIconText(sender: sender, icon: UIImage(named: "Documents_Normal")?.withTintColor(.systemGray), text: "File")
        case .answerInvition:
            return NSAttributedString(string: "\(sender) join the group.")
        case .createChannel:
            return NSAttributedString(string: "\(sender) created a group.")
        case .inviteChatroom:
            return NSAttributedString(string: "\(sender) added a participant.")
        case .leaveChannel:
            return NSAttributedString(string: "\(sender) left.")
        case .kickChannel:
            return NSAttributedString(string: "\(sender) removed a participant.")
        case .setRoleID:
            return NSAttributedString(string: "\(sender) changed member permissions.")
        case .setChannelProfile:
            return NSAttributedString(string: "\(sender) changed the profile of this group.")
        case .recall:
            return NSAttributedString(string: "\(sender) deleted this message.")
        default:
            break
        }
        return NSAttributedString(string: "\(sender):\(msgContent)")
    }
    
    private func getIconText(sender: String, icon: UIImage?, text: String) -> NSAttributedString {
        let title = NSMutableAttributedString(string: "\(sender):")
        let attachment = NSTextAttachment()
        attachment.image = icon
        attachment.bounds = CGRect(x: 0, y: -5, width: 20, height: 20)
        title.append(NSAttributedString(attachment: attachment))
        title.append(NSAttributedString(string: text))
        return title
    }
    
}
