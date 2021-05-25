//
//  CallStatusBarVC.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/4/28.
//

import UIKit

class CallStatusBarVC: UIViewController {
    static let shared = CallStatusBarVC()
    
    lazy var window: UIWindow = {
        let w = UIWindow()
        var height: CGFloat = 20
        if #available(iOS 11.0, *) {
            height = w.safeAreaInsets.top + 24
        }
        w.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        w.windowLevel = .alert + 1
        w.isHidden = true
        view.backgroundColor = UIColor.init(red: 21.0/255.0, green: 217.0/255.0, blue: 105.0/255.0, alpha: 1)
        return w
    }()
    
    lazy var lblMessage: UILabel = {
        let label = UILabel.init()
        
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.contentMode = .center
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 1.0
        animation.fillMode = .forwards
        animation.autoreverses = true

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [animation]
        animationGroup.duration = 2.0
        animationGroup.repeatCount = .greatestFiniteMagnitude

        label.layer.add(animationGroup, forKey: "groupAnimation")
        
        return label
    }()
    
    var tapGesture: UITapGestureRecognizer? {
        didSet {
            if oldValue != nil {
                window.removeGestureRecognizer(oldValue!)
            }
            if tapGesture != nil {
                window.addGestureRecognizer(tapGesture!)
            }
        }
    }

    var isShow = false {
        didSet {
            window.rootViewController = self
            window.isHidden = !isShow
            view.backgroundColor = UIColor.init(red: 52.0/255.0, green: 199.0/255.0, blue: 89.0/255.0, alpha: 1)
            let edgeInsets = isShow ? UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0) : .zero
            for window in UIApplication.shared.windows {
                window.rootViewController?.additionalSafeAreaInsets = edgeInsets
            }
        }
    }
}
