//
//  AvatarTitleTVCell.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/4.
//

import UIKit

class AvatarTitleTVCell: AvatarTVCell {
    private var lblTitle: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        return view
    }()
    
    var title: String {
        set {
            lblTitle.text = newValue
            lblTitle.sizeToFit()
            layout()
        }
        get {
            guard let title = lblTitle.text else {
                return ""
            }
            return title
        }
    }
    
    var avatarTitlSpace: CGFloat {
        get {
            return 16
        }
    }
    
    override var separatorLeadingPadding: CGFloat {
        get {
            return leadingPadding + type(of: self).avatarSize() + avatarTitlSpace
        }
    }
    
    override var isSystem: Bool {
        set {
            super.isSystem = newValue
            if newValue {
                lblTitle.textColor = .systemBlue
            } else {
                lblTitle.textColor = .label
            }
        }
        
        get {
            return super.isSystem
        }
    }
    
    var titleFont: UIFont {
        get {
            return .systemFont(ofSize: 17)
        }
    }
    
    static private let selectedBGView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    override func commonInit() {
        super.commonInit()
        addSubview(lblTitle)
        lblTitle.font = titleFont
    }
    
    override func layout() {
        super.layout()
        
        if let tableView = superViewWithClass(UITableView.self) as? UITableView {
            if tableView.semanticContentAttribute == .forceRightToLeft {
                separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: separatorLeadingPadding)
            } else {
                separatorInset = UIEdgeInsets(top: 0, left: separatorLeadingPadding, bottom: 0, right: 0)
            }
        }
        
        lblTitle.center = CGPoint(x: separatorLeadingPadding + lblTitle.bounds.width * 0.5, y: bounds.height * 0.5)
    }
}
