//
//  LTMessageResponse+Extension.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/10.
//

import Foundation
import MessageKit

extension LTMessageResponse: SenderType {
    public var senderId: String {
        return senderID
    }
    
    public var displayName: String {
        return senderNickname
    }
}

extension LTMessageResponse: MessageType {
    public var sender: SenderType {
        return self
    }
    
    public var messageId: String {
        return msgID
    }
    
    public var sentDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(sendTime) * 0.001)
    }
    
    public var kind: MessageKind {
        var customText = ""
        if recallStatus != nil {
            customText.append(" recall this message.")
        } else if msgType == .text {
            return .text(msgContent)
        } else if msgType == .image || msgType == .video {
            return .photo(self)
        } else if msgType == .voice {
            customText.append(" sent a voice message.")
        } else if msgType == .contact {
            customText.append(" sent a contact message.")
        } else if msgType == .location {
            customText.append(" sent a location message.")
        } else if msgType == .document {
            customText.append(" sent a document message.")
        } else if msgType == .answerInvition {
            customText.append(" joined chanennl.")
        } else if msgType == .createChannel {
            customText.append(" create channel.")
        } else if msgType == .inviteChatroom {
            customText.append(" invited members.")
        } else if msgType == .leaveChannel {
            customText.append(" left.")
        } else if msgType == .kickChannel {
            customText.append(" kicked members.")
        } else if msgType == .setRoleID {
            customText.append(" set member role.")
        } else if msgType == .setChannelProfile {
            customText.append(" set channel profile.")
        } else if msgType == .recall {
            customText.append(" recall messages.")
        } else {
            customText.append(" sent a msgType = \(msgType.rawValue) message")
        }
        
        customText.append(" " + MessageKitDateFormatter.shared.string(from: sentDate))
        
        var name = senderNickname
        if name.count == 0 {
            name = ProfileManager.shared.getUserNickname(senderID) ?? "Unknown member"
        }
        return .custom(name + customText)
    }
    
    
}

extension LTMessageResponse: MediaItem {
    public var url: URL? {
        var path = FileManager.default.getCachePath().appending("\(transID).jpg")
        if let rp = self as? LTSendMessageResponse, let file = rp.message as? LTFileMessage {
            path = FileManager.default.getCachePath().appending(file.fileName)
        }
        
        return URL(fileURLWithPath: path)
    }
    
    public var image: UIImage? {
        let img = UIImage(contentsOfFile: url!.path)
        if img == nil {
            DownloadManager.shared.download(messageRP: self)
        }
        return img
    }
    
    public var placeholderImage: UIImage {
        return UIImage()
    }
    
    public var size: CGSize {
        return CGSize(width: 240, height: 240)
    }
    
    
}
