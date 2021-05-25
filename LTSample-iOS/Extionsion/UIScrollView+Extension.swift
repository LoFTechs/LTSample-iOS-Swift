//
//  UIScrollView+Extension.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/5.
//

import UIKit

extension UIScrollView {
    var isBottom: Bool {
        get {
            return contentOffset.y == (contentSize.height - bounds.height + adjustedContentInset.bottom)
        }
    }
    
    func scrollToBottom(_ animated: Bool) {
        scrollRectToVisible(CGRect(x: 0, y: contentSize.height - 1, width: bounds.width, height: 1), animated: animated)
    }
}
