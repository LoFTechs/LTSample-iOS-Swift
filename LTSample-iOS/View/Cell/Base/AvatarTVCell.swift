//
//  AvatarTVCell.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/27.
//

import UIKit

class AvatarTVCell: UITableViewCell {
    
    var imgViewAvatar: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    var avatar: UIImage? {
        set {
            imgViewAvatar.image = newValue
        }
        
        get {
            return imgViewAvatar.image
        }
    }
    
    var leadingPadding: CGFloat {
        get {
            return 16
        }
    }
    
    class func avatarSize() -> CGFloat {
        return 36
    }
    
    var separatorLeadingPadding: CGFloat {
        get {
            return leadingPadding + type(of: self).avatarSize()
        }
    }
    
    var isSystem: Bool {
        set {
            if newValue {
                imgViewAvatar.contentMode = .center
                imgViewAvatar.tintColor = .systemBlue
                imgViewAvatar.backgroundColor = .systemGray4
            } else {
                imgViewAvatar.contentMode = .scaleAspectFit
                imgViewAvatar.tintColor = .systemGray4
                imgViewAvatar.backgroundColor = .clear
            }
        }
        
        get {
            return imgViewAvatar.contentMode == .center
        }
    }
    
    static private let selectedBGView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    func commonInit() {
        addSubview(imgViewAvatar)
        selectedBackgroundView = type(of: self).selectedBGView
    }
    
    func layout() {
        if let tableView = superViewWithClass(UITableView.self) as? UITableView {
            if tableView.semanticContentAttribute == .forceRightToLeft {
                separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: separatorLeadingPadding)
            } else {
                separatorInset = UIEdgeInsets(top: 0, left: separatorLeadingPadding, bottom: 0, right: 0)
            }
        }
        
        let size = type(of: self).avatarSize()
        imgViewAvatar.frame = CGRect(x: leadingPadding, y: (bounds.height - size) * 0.5, width: size, height: size)
        if isCircleAvatar() {
            imgViewAvatar.circle()
        }
    }
    
    func isCircleAvatar() -> Bool {
        return true
    }
}
