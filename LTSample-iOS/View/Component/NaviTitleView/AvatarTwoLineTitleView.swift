//
//  AvatarTwoLineTitleView.swift
//  LTSample-iOS
//
//  Created by 游勝滄 on 2021/5/6.
//

import UIKit

class AvatarTwoLineTitleView: UIView {
    
    weak var delegate: NaviTitleViewDelegate? {
        didSet {
            longPress.isEnabled = (delegate != nil)
        }
    }
    
    let imgViewAvatar: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.tintColor = .systemGray4
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
    
    private let twoLineTitleView: TwoLineTitleView = {
        let view = TwoLineTitleView()
        view.alginment = .left
        return view
    }()
    
    var title: String? {
        set {
            twoLineTitleView.title = newValue
            layoutSubviews()
        }
        
        get {
            return twoLineTitleView.title
        }
    }
    
    var subTitle: String? {
        set {
            twoLineTitleView.subTitle = newValue
            layoutSubviews()
        }
        
        get {
            return twoLineTitleView.subTitle
        }
    }
    
    var subTitleColor: UIColor {
        set {
            twoLineTitleView.subTitleColor = newValue
        }
        
        get {
            return twoLineTitleView.subTitleColor
        }
    }
    
    private let longPress: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.minimumPressDuration = 0.01
        gesture.isEnabled = false
        return gesture
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func commonInit() {
        addSubview(imgViewAvatar)
        addSubview(twoLineTitleView)
        imgViewAvatar.isUserInteractionEnabled = false
        twoLineTitleView.isUserInteractionEnabled = false
        
        longPress.addTarget(self, action: #selector(longPressAction))
        addGestureRecognizer(longPress)
    }
    
    private func layout() {
        twoLineTitleView.layoutSubviews()
        let avatarSize = twoLineTitleView.bounds.height
        let space: CGFloat = 8
        let size = CGSize(width: twoLineTitleView.bounds.width + avatarSize + space, height: avatarSize)
        if bounds.size != size {
            frame.size = size
        } else {
            imgViewAvatar.frame = CGRect(x: 0, y: 0, width: avatarSize, height: avatarSize)
            imgViewAvatar.circle()
            twoLineTitleView.frame = CGRect(x: avatarSize + space, y: 0, width: twoLineTitleView.bounds.width, height: avatarSize)
        }
        
    }
    
    @objc func longPressAction(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended || gesture.state == .failed || gesture.state == .cancelled {
            alpha = 1
        } else {
            alpha = 0.25
        }
        if gesture.state == .ended {
            let point = gesture.location(in: gesture.view)
            if self.bounds.contains(point) {
                delegate?.clickTitleView()
            }
        }
    }
    
}
