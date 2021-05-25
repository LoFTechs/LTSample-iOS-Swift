//
//  ChatHeaderView.swift
//  LTSample-iOS
//
//  Created by 游勝滄 on 2021/5/18.
//

import UIKit
import MessageKit

class ChatHeaderView: MessageReusableView {
    
    private let lblTitle: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.backgroundColor = .init(white: 0, alpha: 0.5)
        view.font = .systemFont(ofSize: 14)
        view.textColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.masksToBounds = true
        return view
    }()
    
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
        addSubview(lblTitle)
        backgroundColor = .clear
    }
    
    func layout() {
        let h = bounds.height - 4
        let w = max(h, lblTitle.bounds.width + 8)
        lblTitle.frame = CGRect(x: (bounds.width - w) * 0.5, y: 2, width: w, height: h)
        lblTitle.layer.cornerRadius =  h * 0.5
    }
}
