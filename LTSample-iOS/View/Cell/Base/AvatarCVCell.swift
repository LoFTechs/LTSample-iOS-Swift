//
//  AvatarCVCell.swift
//  LTSample-iOS
//
//  Created by 游勝滄 on 2021/4/28.
//

import UIKit

protocol AvatarCVCellDelegate: NSObject {
    func avatarCVCellDidClickClose(_ cell: AvatarCVCell)
}


class AvatarCVCell: UICollectionViewCell {
    
    weak var delegate: AvatarCVCellDelegate?
    
    private var lblTitle: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingMiddle
        view.textAlignment = .center
        return view
    }()
    
    var imgViewAvatar: UIImageView = {
        let view = UIImageView()
        view.tintColor = .systemGray4
        return view
    }()
    
    private var btnClose: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        view.tintColor = .systemRed
        view.backgroundColor = .systemBackground
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
    
    var avatar: UIImage? {
        set {
            imgViewAvatar.image = newValue
        }
        
        get {
            return imgViewAvatar.image
        }
    }
    
    var avatarTitlSpace: CGFloat {
        get {
            return 4
        }
    }
    
    class func avatarSize() -> CGFloat {
        return 72
    }
    
    class func closeSize() -> CGFloat {
        return 24
    }
    
    var titleFont: UIFont {
        get {
            return .systemFont(ofSize: 12)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        addSubview(lblTitle)
        addSubview(btnClose)
        btnClose.addTarget(self, action: #selector(clickClose), for: .touchUpInside)
        lblTitle.font = titleFont
    }
    
    func layout() {
        let size = type(of: self).avatarSize()
        let c = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
        let contentH = size + avatarTitlSpace + lblTitle.bounds.height
        imgViewAvatar.bounds.size = CGSize(width: size, height: size)
        imgViewAvatar.center = CGPoint(x: c.x, y: (bounds.height - contentH + size) * 0.5)
        
        if isCircleAvatar() {
            imgViewAvatar.circle()
        }
        
        lblTitle.bounds.size.width = min(lblTitle.bounds.width, bounds.width - 4)
        lblTitle.center = CGPoint(x: c.x, y: size + avatarTitlSpace + (bounds.height - contentH + lblTitle.bounds.height) * 0.5)
        
        let closeSize = type(of: self).closeSize()
        btnClose.frame = CGRect(x: imgViewAvatar.frame.maxX - closeSize, y: imgViewAvatar.frame.minY, width: closeSize, height: closeSize)
        btnClose.circle()
    }
    
    func isCircleAvatar() -> Bool {
        return true
    }
    
    @IBAction private func clickClose() {
        delegate?.avatarCVCellDidClickClose(self)
    }
    
    //MARK: Animation
    func animatedAppear() {
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform.identity
            }
        }
    }
    
    func animatedDisappear(completion: (() ->Void)?) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            } completion: { success in
                self.alpha = 0
                completion?()
            }
        }
    }
    
    func removeAllAnimation() {
        alpha = 1
        layer.removeAllAnimations()
        transform = CGAffineTransform.identity
    }
}
