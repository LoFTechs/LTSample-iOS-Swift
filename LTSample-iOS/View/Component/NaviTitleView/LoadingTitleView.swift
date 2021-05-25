//
//  LoadingTitleView.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/22.
//

import UIKit

class LoadingTitleView: UIView {
    
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
    
    private lazy var lblTitle: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 17, weight: .medium)
        return view
    }()
    
    private lazy var activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .medium
        return view
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
        addSubview(activityView)
    }
    
    private func layout() {
        frame = CGRect(x: 0, y: 0, width: lblTitle.bounds.width, height: lblTitle.bounds.height)
        activityView.center = CGPoint(x: -16, y: lblTitle.bounds.height * 0.5)
        if window != nil {
            activityView.startAnimating()
        } else {
            activityView.stopAnimating()
        }
    }
}
