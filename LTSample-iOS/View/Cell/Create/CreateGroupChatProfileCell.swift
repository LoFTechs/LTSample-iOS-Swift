//
//  CreateGroupChatProfileCell.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/3.
//

import UIKit

protocol CreateGroupChatProfileCellDelegate: NSObject {
    func CreateGroupChatProfileCellDidClickAvatar(_ cell: CreateGroupChatProfileCell)
    func CreateGroupChatProfileCellSubjectDidChange(_ cell: CreateGroupChatProfileCell)
}

class CreateGroupChatProfileCell: UITableViewCell {
    
    weak var delegate: CreateGroupChatProfileCellDelegate?
    
    var avatar: UIImage? {
        didSet {
            if let img = avatar {
                imgAvatar.image = img
                imgAvatar.contentMode = .scaleAspectFill
                imgAvatar.circle()
            } else {
                imgAvatar.image = UIImage(systemName: "person.2.fill")
                imgAvatar.contentMode = .scaleAspectFit
                imgAvatar.layer.cornerRadius = 0
                imgAvatar.layer.masksToBounds = false
            }
        }
    }
    
    var subject: String {
        set {
            tfSubject.text = newValue
        }
        
        get {
            if let text = tfSubject.text, text.count > 0 {
                return text
            }
            return ""
        }
    }
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak private var btnEditAvatar: UIButton!
    @IBOutlet weak private var tfSubject: LTLimitTextField!
    
    
    @IBAction private func clickEditAvatar() {
        delegate?.CreateGroupChatProfileCellDidClickAvatar(self)
    }
    
    @IBAction private func editTextField() {
        delegate?.CreateGroupChatProfileCellSubjectDidChange(self)
    }
    
    override var isFirstResponder: Bool {
        return tfSubject.isFirstResponder
    }

    override func becomeFirstResponder() -> Bool {
        return tfSubject.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        return tfSubject.resignFirstResponder()
    }
}
