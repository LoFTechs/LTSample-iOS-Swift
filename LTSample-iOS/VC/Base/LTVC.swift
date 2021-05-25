//
//  LTVC.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/26.
//

import UIKit

class LTVC: UIViewController {
    
    private var currentTitleView: UIView?
    private var currentWindow: UIWindow?
    private var currentFirstResponder: UIResponder?
    
    private var currentLeftEnable = false
    private var currentRightEnable = false
    
    private lazy var observers = [NotificationToken]()
    
    private lazy var mask: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        return view
    }()
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let navi = navigationController else {
            return
        }
        
        coordinator.animate { (_) in
            navi.navigationBar.sizeToFit()
            if let titleView = self.navigationItem.titleView {
                titleView.layoutSubviews()
            }
        }
    }
    
    func observe(name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> ()) {
        let token = NotificationCenter.default.observe(name: name, object: obj, queue: queue, using: block)
        observers.append(token)
    }
    
    func removeAllObserve() {
        observers.removeAll()
    }
    
    func loading(_ string: String, _ wait: Bool = false) {
        
        if let titleView = navigationItem.titleView, !titleView.isKind(of: LoadingTitleView.self) {
            currentTitleView = navigationItem.titleView
        }
        currentFirstResponder = view.currentFirstResponder()
        let loading = LoadingTitleView()
        loading.title = string
        navigationItem.titleView = loading
        
        if wait && mask.superview == nil {
            view.window?.endEditing(true)
            view.coveredByView(mask)
            currentWindow = view.window
            currentWindow?.isUserInteractionEnabled = false
            view.isUserInteractionEnabled = false
            
            if let left = navigationItem.leftBarButtonItem {
                currentLeftEnable = left.isEnabled
                left.isEnabled = false
            }
            
            if let right = navigationItem.rightBarButtonItem {
                currentRightEnable = right.isEnabled
                right.isEnabled = false
            }
        }
    }
    
    func endLoading() {
        mask.removeFromSuperview()
        currentWindow?.isUserInteractionEnabled = true
        currentWindow = nil
        view.isUserInteractionEnabled = true
        self.navigationItem.titleView = currentTitleView
        currentTitleView = nil
        currentFirstResponder?.becomeFirstResponder()
        currentFirstResponder = nil
        
        if let left = navigationItem.leftBarButtonItem {
            left.isEnabled = currentLeftEnable
        }
        
        if let right = navigationItem.rightBarButtonItem {
            right.isEnabled = currentRightEnable
        }
    }
}

extension LTVC: LTProtocol {
    var className: AnyClass {
        get {
            return type(of: self)
        }
    }
}
