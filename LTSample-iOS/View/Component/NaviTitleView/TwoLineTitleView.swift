//
//  TwoLineTitleView.swift
//  LTSample-iOS
//
//  Created by 游勝滄 on 2021/4/28.
//

import UIKit

class TwoLineTitleView: UIView {
    
    weak var delegate: NaviTitleViewDelegate? {
        didSet {
            longPress.isEnabled = (delegate != nil)
        }
    }
    
    var alginment: NSTextAlignment = .center
    
    var title: String? {
        set {
            lblTitle.text = newValue
            lblTitle.sizeToFit()
            layout()
        }
        
        get {
            return lblTitle.text
        }
    }
    
    var subTitle: String? {
        set {
            lblSubTitle.text = newValue
            lblSubTitle.sizeToFit()
            layout()
        }
        
        get {
            return lblSubTitle.text
        }
    }
    
    var subTitleColor: UIColor {
        set {
            lblSubTitle.textColor = newValue
        }
        
        get {
            return lblSubTitle.textColor
        }
    }
    
    private let lblTitle: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 17, weight: .medium)
        return view
    }()
    
    private let lblSubTitle: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 10)
        return view
    }()
    
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
        addSubview(lblTitle)
        addSubview(lblSubTitle)
        lblTitle.isUserInteractionEnabled = false
        lblSubTitle.isUserInteractionEnabled = false
        
        longPress.addTarget(self, action: #selector(longPressAction))
        addGestureRecognizer(longPress)
    }
    
    private func layout() {
        var titleFont: UIFont = .systemFont(ofSize: 17, weight: .medium)
        var space: CGFloat = 4
        if AppUtility.isLand() {
            titleFont = .systemFont(ofSize: 14, weight: .medium)
            space = 0
        }
        lblTitle.font = titleFont
        lblTitle.sizeToFit()
        lblSubTitle.sizeToFit()
        
        let h = lblTitle.bounds.height + lblSubTitle.bounds.height + space
        let w = max(lblTitle.bounds.width, lblSubTitle.bounds.width)
        let size = CGSize(width: w, height: h)
        if bounds.size != size {
            frame.size = size
        } else {
            lblTitle.center = CGPoint(x: center.x, y: lblTitle.bounds.height * 0.5)
            lblSubTitle.center = CGPoint(x: center.x, y: h - lblSubTitle.bounds.height * 0.5)
            
            if alginment == .left {
                lblTitle.center.x = lblTitle.bounds.width * 0.5
                lblSubTitle.center.x = lblSubTitle.bounds.width * 0.5
            } else if alginment == .right {
                lblTitle.center.x = w - lblTitle.bounds.width * 0.5
                lblSubTitle.center.x = w - lblSubTitle.bounds.width * 0.5
            }
        }
    }
    
    @objc func longPressAction(_ gesture: UILongPressGestureRecognizer) {
        alpha = 1
        if gesture.state == .began  {
            alpha = 0.25
        } else if gesture.state == .ended {
            let point = gesture.location(in: gesture.view)
            if self.bounds.contains(point) {
                delegate?.clickTitleView()
            }
        }
    }
}
