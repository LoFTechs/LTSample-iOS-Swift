//
//  ChatNavigationController.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/5.
//

import UIKit

class ChatNavigationController: UINavigationController {
    
    var channel: LTChannelResponse? {
        didSet {
            if channel == nil {
                subject = nil
                avatar = nil
                readTime = 0
            } else {
                readTime = channel!.lastReadTime
            }
        }
    }
    var subject: String?
    var avatar: UIImage?
    var avatarContentMode: UIView.ContentMode = .scaleAspectFill
    var readTime: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        IMManager.shared.addDelegate(self)
    }
    
    func push(channel: LTChannelResponse, profile: (UIImage?, String?, UIView.ContentMode)? = nil) {
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? ChatVC else {
            return
        }
        
        if let p = profile {
            avatar = p.0
            subject = p.1
            avatarContentMode = p.2
        }
        
        self.channel = channel
        pushViewController(vc, animated: true)
    }
    
    func popToChatList() {
        popToRootViewController(animated: true)
    }
}

extension ChatNavigationController: IMManagerDelegate {
    var className: AnyClass {
        get {
            return type(of: self)
        }
    }

    func onNeedLeaveChat(chID: String) {
        if chID == channel?.chID {
            popToChatList()
        }
    }
}
