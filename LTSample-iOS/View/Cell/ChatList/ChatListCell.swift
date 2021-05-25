//
//  ChatListCell.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/4.
//

import UIKit

class ChatListCell: AvatarTVCell {
    private var lblSubject: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 17, weight: .medium)
        return view
    }()
    
    var subject: String {
        set {
            lblSubject.text = newValue
        }
        get {
            guard let subject = lblSubject.text else {
                return ""
            }
            return subject
        }
    }
    
    private var lblMessage: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.font = .systemFont(ofSize: 14)
        view.textColor = .systemGray2
        return view
    }()
    
    var message: NSAttributedString {
        set {
            lblMessage.attributedText = newValue
        }
        get {
            guard let message = lblMessage.attributedText else {
                return NSAttributedString()
            }
            return message
        }
    }
    
    private var lblTime: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    
    var time: String {
        set {
            lblTime.text = newValue
            lblTime.sizeToFit()
            layout()
        }
        get {
            guard let time = lblTime.text else {
                return ""
            }
            return time
        }
    }
    
    private var lblUnreadCount: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 12)
        view.textColor = .white
        view.backgroundColor = .systemBlue
        view.textAlignment = .center
        return view
    }()
    
    var unreadCount: String {
        set {
            lblUnreadCount.text = newValue
            layout()
        }
        get {
            guard let time = lblUnreadCount.text else {
                return ""
            }
            return time
        }
    }
    
    private var imgMute: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "speaker.slash.fill")
        view.tintColor = .systemGray4
        return view
    }()
    
    var isMute: Bool {
        set {
            if newValue {
                imgMute.frame.size = CGSize(width: 20, height: 20)
            } else {
                imgMute.frame.size = .zero
            }
            imgMute.isHidden = !newValue
        }
        
        get {
            return !imgMute.isHidden
        }
    }
    
    override var leadingPadding: CGFloat {
        get {
            return 16
        }
    }
    
    override class func avatarSize() -> CGFloat {
        return 48
    }
    
    override var separatorLeadingPadding: CGFloat {
        get {
            return leadingPadding + type(of: self).avatarSize() + avatarContentSpace
        }
    }
    
    private var avatarContentSpace: CGFloat {
        get {
            return 16
        }
    }
    
    override func commonInit() {
        super.commonInit()
        addSubview(lblSubject)
        addSubview(lblMessage)
        addSubview(lblTime)
        addSubview(lblUnreadCount)
        addSubview(imgMute)
        selectedBackgroundView = nil
    }
    
    override func layout() {
        super.layout()
        
        let cellW = bounds.width
        let w = lblTime.bounds.width
        let h = lblTime.bounds.height
        var y = imgViewAvatar.frame.minY
        let timeX = cellW - w - 16
        lblTime.frame = CGRect(x: timeX, y: y, width: w, height: h)
        
        var x = separatorLeadingPadding
        lblSubject.frame = CGRect(x: x, y: y, width: timeX - x - 16, height: 17)
        
        y = y + 4 + h
        
        var size: CGFloat = 0
        var space: CGFloat = 0
        if unreadCount.count > 0 {
            lblUnreadCount.sizeToFit()
            size = max(lblUnreadCount.bounds.width + 8, 20)
            x = cellW - 16 - size
            lblUnreadCount.frame = CGRect(x: x, y: y, width: size, height: 20)
            lblUnreadCount.circle()
            lblTime.textColor = .systemBlue
            space += 8
        } else {
            x = cellW - 16
            lblUnreadCount.frame.size = .zero
            lblTime.textColor = .systemGray
        }
        
        if isMute {
            x -= 28
            imgMute.frame = CGRect(x: x, y: y, width: 20, height: 20)
        }
        
        lblMessage.frame.origin = CGPoint(x: separatorLeadingPadding, y: y)
        lblMessage.frame.size.width = x - space - separatorLeadingPadding
        lblMessage.sizeToFit()
    }
}
