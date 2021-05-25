//
//  UILabel+Extension.swift
//  LTSample-iOS
//
//  Created by shanezhang on 2021/4/26.
//

import UIKit

extension UILabel {
    func setDateFormatText(time: TimeInterval) {
        self.text = Date(timeIntervalSince1970: time).dateFormat()
    }
}
