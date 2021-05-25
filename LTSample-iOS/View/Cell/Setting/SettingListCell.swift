//
//  SettingListCell.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/28.
//

import UIKit

class SettingProfileCell: AvatarTitleTVCell {
    override class func avatarSize() -> CGFloat {
        return 60
    }
    
    override var titleFont: UIFont {
        get {
            return .systemFont(ofSize: 24)
        }
    }
}
