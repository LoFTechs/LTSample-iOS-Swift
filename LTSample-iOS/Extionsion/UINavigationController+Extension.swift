//
//  UINavigationController+Extension.swift
//  LTSample-iOS
//
//  Created by 游勝滄 on 2021/4/26.
//

import UIKit

extension UINavigationController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let vc = topViewController else {
            return .portrait
        }
        return vc.supportedInterfaceOrientations
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        guard let vc = topViewController else {
            return .portrait
        }
        return vc.preferredInterfaceOrientationForPresentation
    }
    
    open override var shouldAutorotate: Bool {
        guard let vc = topViewController else {
            return false
        }
        return vc.shouldAutorotate
    }
}
