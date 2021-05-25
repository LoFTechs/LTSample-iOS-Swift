//
//  ChatListVC.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/23.
//

import UIKit

class ChatListVC: ChatBaseVC {
    
    private var channels = [LTChannelResponse]()
    private var waitToPushChID: String?
    private var waitPushProfile: (UIImage?, String?, UIView.ContentMode)?
    
    private var chatListEmptyView: LTListEmptyView = {
        let title = NSMutableAttributedString(string: "Tap on  ")
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "square.and.pencil")?.withTintColor(.label)
        attachment.bounds = CGRect(x: 0, y: -4, width: 22, height: 22)
        title.append(NSAttributedString(attachment: attachment))
        title.append(NSAttributedString(string: "  in the top right corner to start a new chat."))
        
        let view = UINib(nibName: "LTListEmptyView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! LTListEmptyView
        view.attributedTitle = title
        view.subTitle = "You can chat with contacts who have App installed on their phone."
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listViewShow = true
        listView.register(ChatListCell.self, forCellReuseIdentifier: "ChatListCell")
        listView.register(LeftRightButtonCell.self, forCellReuseIdentifier: "LeftRightButtonCell")
        setupEmpty()
        listView.tableHeaderView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IMManager.shared.addDelegate(self)
        ProfileManager.shared.addDelegate(self)
        IMManager.shared.queryChannels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chatNavigation.channel = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IMManager.shared.removeDelegate(self)
        ProfileManager.shared.removeDelegate(self)
        super.viewWillDisappear(animated)
    }
    
    private func setupEmpty() {
        let action = LTListEmptyViewAction(title: "Start Messageing") {
            self.clickCreateChat()
        }
        chatListEmptyView.addAction(action)
        emptyView = chatListEmptyView
    }
    
    @IBAction private func clickCreateChat() {
        let storyboard = UIStoryboard(name: "Create", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() as? CreateNavigationController {
            vc.type = .chat
            vc.createDelegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    private func push(chID: String, profile: (UIImage?, String?, UIView.ContentMode)?, needWait: Bool = true) {
        if let channel = channels.first(where: {
            $0.chID == chID
        }) {
            presentedViewController?.dismiss(animated: true) {
                self.chatNavigation.push(channel: channel, profile: profile)
            }
        } else if needWait {
            waitToPushChID = chID
            waitPushProfile = profile
        }
    }
}

extension ChatListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        }
        return ChatListCell.avatarSize() + 24
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? ChatListCell {
            chatNavigation.push(channel: channels[indexPath.row], profile: (cell.avatar, cell.subject, cell.imgViewAvatar.contentMode))
        }
    }
}

extension ChatListVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyViewShow = channels.count == 0
        if section == 0 {
            return 1
        }
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeftRightButtonCell", for: indexPath) as? LeftRightButtonCell else {
                return UITableViewCell()
            }
            cell.rightTitle = "New Group"
            cell.delegate = self
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as? ChatListCell else {
            return UITableViewCell()
        }
        
        if indexPath.row >= channels.count {
            cell.subject = ""
            cell.message = NSAttributedString(string: "")
            cell.time = ""
            cell.unreadCount = ""
            return cell
        }
        
        let channel = channels[indexPath.row]
        cell.isSystem = false
        
        var hasAvatar = false
        if channel.chType == .single {
            let userID = FriendManager.getUserID(chID: channel.chID)
            let (nickname, avatar) = ProfileManager.shared.getUserProfile(userID)
            cell.subject = nickname ?? "Unknown"
            if let img = avatar {
                cell.avatar = img
                hasAvatar = true
            } else {
                cell.avatar = UIImage(systemName: "person.crop.circle")
            }
        } else {
            let avatar = ProfileManager.shared.getChannelAvatar(channel.chID, fileInfo: channel.profileImageFileInfo)
            cell.subject = channel.subject
            cell.avatar = avatar ?? UIImage(systemName: "person.3.fill")
            hasAvatar = (avatar != nil)
        }
        
        if hasAvatar {
            cell.imgViewAvatar.contentMode = .scaleAspectFill
        } else {
            cell.imgViewAvatar.contentMode = .scaleAspectFit
        }
        
        let nickname = ProfileManager.shared.getUserNickname(channel.lastMsgSenderID) ?? "Unknown"
        cell.message = channel.lastMsgType.getMessage(sender: nickname, msgContent: channel.lastMsgContent)
        
        let time = Date(timeIntervalSince1970: TimeInterval(channel.lastMsgTime) * 0.001).dateFormat()
        cell.time = time
        
        if channel.unreadCount == 0 {
            cell.unreadCount = ""
        } else {
            cell.unreadCount = "\(channel.unreadCount)"
        }
        
        cell.isMute = channel.isMute
        
        return cell
    }
}

extension ChatListVC: IMManagerDelegate {
    
    func onQueryChannels(_ channels: [LTChannelResponse]) {
        self.channels.removeAll()
        self.channels.append(contentsOf: channels)
        self.channels.sort(by: { $0.lastMsgTime > $1.lastMsgTime })
        listView.reloadData()
        
        if let chID = waitToPushChID, chID.count > 0 {
            push(chID: chID, profile: waitPushProfile, needWait: false)
        }
        
        waitToPushChID = nil
        waitPushProfile = nil
    }
    
    func onNeedQueryChannels() {
        IMManager.shared.queryChannels()
    }

}

extension ChatListVC: LeftRightButtonCellDelegate {
    func LeftRightButtonCellDidClickLeftButton(_ cell: LeftRightButtonCell) {
        
    }
    
    func LeftRightButtonCellDidClickRightButton(_ cell: LeftRightButtonCell) {
        let storyboard = UIStoryboard(name: "Create", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CreateSelect") as? CreateNavigationController {
            vc.type = .chat
            vc.createDelegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
}

extension ChatListVC: ProfileManagerDelagate {
    func profileUpdate(userIDs: [String]) {
        if let ids = userIDs.first(where: { userID -> Bool in
            return channels.contains { channel -> Bool in
                if channel.chType == .single {
                    return userID == FriendManager.getUserID(chID: channel.chID)
                } else {
                    return userID == channel.chID
                }
            }
        }), ids.count > 0 {
            listView.reloadData()
        }
    }
}

extension ChatListVC: CreateNCDelegate {
    func createNC(_ createNC: CreateNavigationController, selectedFriend friend: Friend, profile: (UIImage?, String?, UIView.ContentMode)) {
        if let chID = IMManager.shared.getCurrentLTIMMnager()?.channelHelper.getSingleChannelID(withUserID: friend.userID) {
            push(chID: chID, profile: profile)
        }
    }
    
    func createNC(_ createNC: CreateNavigationController, createdChannel chID: String, profile: (UIImage?, String?, UIView.ContentMode)) {
        push(chID: chID, profile: profile)
    }

    
}
