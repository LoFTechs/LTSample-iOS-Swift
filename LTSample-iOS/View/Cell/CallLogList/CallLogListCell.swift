//
//  CallLogListCell.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/4/26.
//

import UIKit

enum CallLogState {
    case outgoingCall
    case incomingCall
    case missCall
}

class CallLogListCell: AvatarTVCell {
    private var lblName: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 17, weight: .medium)
        return view
    }()
    
    var name: String {
        set {
            lblName.text = newValue
        }
        get {
            guard let name = lblName.text else {
                return ""
            }
            return name
        }
    }
    
    private var lblState: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.font = .systemFont(ofSize: 14)
        view.textColor = .systemGray2
        return view
    }()
    
    var message: NSAttributedString {
        set {
            lblState.attributedText = newValue
        }
        get {
            guard let message = lblState.attributedText else {
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
    
    override var leadingPadding: CGFloat {
        get {
            return 16
        }
    }
    
    override class func avatarSize() -> CGFloat {
        return 40
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
    
    func setState(_ state: CallLogState) {
        let title = NSMutableAttributedString()
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "InfoVoiceCall")?.withTintColor(UIColor.init(displayP3Red: 130.0/255, green: 130.0/255, blue: 130.0/255, alpha: 1))
        attachment.bounds = CGRect(x: 0, y: -8, width: 25, height: 25)
        title.append(NSAttributedString(attachment: attachment))
        
        switch state {
        case .outgoingCall:
            lblName.textColor = .none
            title.append(NSAttributedString(string: "Outgoing call"))
        case .incomingCall:
            lblName.textColor = .none
            title.append(NSAttributedString(string: "Incoming call"))
        case .missCall:
            lblName.textColor = UIColor.systemRed
            title.append(NSAttributedString(string: "Miss call"))
        }
        message = title
    }
    
    override func commonInit() {
        super.commonInit()
        addSubview(lblName)
        addSubview(lblState)
        addSubview(lblTime)
        selectedBackgroundView = nil
    }
    
    override func layout() {
        super.layout()
        
        let cellW = bounds.width
        let cellH = bounds.height
        let w = lblTime.bounds.width
        let h = lblTime.bounds.height
        var y = imgViewAvatar.frame.minY
        let x = separatorLeadingPadding
        
        let timeY = (cellH - h) / 2
        let timeX = cellW - w - 16
        
        lblTime.frame = CGRect(x: timeX, y: timeY, width: w, height: h)
        
        lblName.frame = CGRect(x: x, y: y, width: timeX - x - 16, height: 17)
        
        y = y + 4 + h
        
        lblState.frame.origin = CGPoint(x: separatorLeadingPadding - 4, y: y)
        lblState.frame.size.width = x - separatorLeadingPadding
        lblState.sizeToFit()
    }
    
}
