//
//  UIView+Extension.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/4/23.
//

import UIKit

extension UIView {
    func coveredByView(_ view: UIView, sendToBack: Bool = false) {
        addSubview(view)
        if sendToBack {
            sendSubviewToBack(view)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.heightAnchor.constraint(equalTo: heightAnchor),
            view.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }
    
    func addSubViewAtCenter(_ view: UIView) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func circle() {
        let radius = min(bounds.width, bounds.height)
        layer.cornerRadius = radius * 0.5
        layer.masksToBounds = true
    }
    
    func currentFirstResponder() -> UIResponder? {
        if isFirstResponder {
            return self
        }
        
        for subView in subviews {
            if let responder = subView.currentFirstResponder() {
                return responder
            }
        }
        
        return nil
    }
    
    func superViewWithClass(_ Class: AnyClass) -> Any? {
        guard let view = superview else {
            return nil
        }
        
        if view.isKind(of: Class.self) {
            return view
        }
        
        return view.superViewWithClass(Class)
    }
}
