//
//  CreateNavigationController.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/4.
//

import UIKit

enum CreateType: Int {
    case call = 0
    case chat = 1
    case invite = 2
}

protocol CreateNCDelegate: LTProtocol {
    func createNC(_ createNC: CreateNavigationController, selectedFriend friend: Friend, profile: (UIImage?, String?, UIView.ContentMode))
    func createNC(_ createNC: CreateNavigationController, createdChannel chID: String, profile: (UIImage?, String?, UIView.ContentMode))
}

class CreateNavigationController: UINavigationController {
    
    weak var createDelegate: CreateNCDelegate?
    
    var type: CreateType = .call
    var selectedFriendIndexArray = [Int]()
    var avatar: UIImage?
    var subject = ""
    
    var currentChannel: LTChannelResponse?
    var ignore: [String]?
}
