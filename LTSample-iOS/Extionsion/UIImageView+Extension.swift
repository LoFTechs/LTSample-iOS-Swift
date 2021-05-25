//
//  UIImageView+Extension.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/4/26.
//

import UIKit

extension UIImageView {
    func renderingColor(_ color: UIColor) {
        image = image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
    }
}

