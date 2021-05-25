//
//  ChatMemberListVC.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/7.
//

import UIKit

class ChatMemberListCell: AvatarTitleTVCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ChatMemberListVC: ChatBaseVC {
    
    var channelMembers = [LTMemberPrivilege]()
    var queryMembering = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listViewShow = true
        title = "Particpants"
        listView.register(ChatMemberListCell.self, forCellReuseIdentifier: "Cell")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        IMManager.shared.addDelegate(self)
        queryMember()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IMManager.shared.removeDelegate(self)
    }
    
    func queryMember(lastUserID: String = "") {
        guard let channel = chatNavigation.channel, !queryMembering else { return }
        queryMembering = true
        IMManager.shared.queryChannelMember(chID: channel.chID, lastUserID: lastUserID, count: 30)
    }
    
    func addMember() {
        let storyboard = UIStoryboard(name: "Create", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "CreateSelect") as? CreateNavigationController {
            vc.type = .invite
            vc.currentChannel = chatNavigation.channel
            vc.ignore = channelMembers.map({ $0.userID})
            present(vc, animated: true, completion: nil)
        }
    }
    
    func chickMemberAction(_ member: LTMemberPrivilege) {
        guard member.userID != UserInfo.userID , let chID = chatNavigation.channel?.chID else { return }
        let nickname = ProfileManager.shared.getUserNickname(member.userID)

        let alert = UIAlertController(title: nickname, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Voice Call", style: .default, handler: { _ in
            let nickname = ProfileManager.shared.getUserNickname(member.userID)
            CallManager.shared.startCall(userID: member.userID, name: nickname ?? "Unknown")
        }))
        
//        alert.addAction(UIAlertAction(title: "Send message", style: .default, handler: { _ in
//            //TODO:
//        }))
        
        if isModerator {
            let isModerator = member.roleID == LTChannelRole.moderator
            alert.addAction(UIAlertAction(title: isModerator ? "Dissmiss As Moderator" : "Make Group Moderator", style: .default, handler: { _ in
                IMManager.shared.setMemberRole(chID: chID, userID: member.userID, roleID: isModerator ? LTChannelRole.participant : LTChannelRole.moderator)
            }))
            
            alert.addAction(UIAlertAction(title: "Remove From Group", style: .destructive, handler: { _ in
                IMManager.shared.kickChannelMember(chID: chID, userID: member.userID)
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
}

extension ChatMemberListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 0 {
            addMember()
            return
        }
        
        guard indexPath.row < channelMembers.count else { return }
        let member = channelMembers[indexPath.row]
        chickMemberAction(member)
    }
}

extension ChatMemberListVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return isModerator ? 1 : 0
        }
        return channelMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ChatMemberListCell else {
            return UITableViewCell()
        }
        
        guard indexPath.row < channelMembers.count else { return cell }
        
        if indexPath.section == 0 {
            cell.isSystem = true
            cell.title = "Add Participants"
            cell.avatar = UIImage(systemName: "person.badge.plus.fill")
            
        } else {
            if indexPath.row == channelMembers.count - 1 {
                queryMember(lastUserID: channelMembers.last?.userID ?? "")
            }
            
            let member = channelMembers[indexPath.row]
            let (nickname, avatar) = ProfileManager.shared.getUserProfile(member.userID)
            cell.isSystem = false
            cell.avatar = avatar ?? UIImage(systemName: "person.crop.circle")
            cell.title = nickname ?? member.userID
            
            cell.detailTextLabel?.text = member.roleID == LTChannelRole.moderator ? "Moderator" : ""
            cell.imgViewAvatar.contentMode = avatar != nil ? .scaleAspectFill : .scaleAspectFit
        }
        return cell
    }
    
}

extension ChatMemberListVC: IMManagerDelegate {
    func onQueryChannelMembers(chID: String, _ response: LTQueryChannelMembersResponse?) {
        guard let channel = chatNavigation.channel, chID == channel.chID, let members = response?.members, members.count > 0 else { return }
        
        let newMembers = members.filter({ newMember -> Bool in
            return !channelMembers.contains { member -> Bool in
                return member.userID == newMember.userID
            }
        })
        
        channelMembers += newMembers
        
        listView.reloadData()
        queryMembering = false
    }
    
    func onMemberChanged(chID: String) {
        guard let channel = chatNavigation.channel, chID == channel.chID else { return }
        queryMembering = false
        channelMembers.removeAll()
        queryMember()
    }
}
