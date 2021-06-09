//
//  ChatSettingVC.swift
//  LTSample-iOS
//
//  Created by 游勝滄 on 2021/5/7.
//

import UIKit

protocol EditAvatarProtocal {
    func clickEditAvatar()
}

class ChatSettingVC: ChatBaseVC {
    
    @IBOutlet weak private var imgViewAvatar: UIImageView!
    @IBOutlet weak private var btnEditAvatar: UIButton! {
        didSet {
            btnEditAvatar.addTarget(self, action: #selector(clickEditAvatar), for: .touchUpInside)
        }
    }
    
    private lazy var editAvatarHelper: EditAvatarHelper = {
        return EditAvatarHelper(vc: self)
    }()
    
    private var initialOffsetY: CGFloat {
        get {
            return 200
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        listViewShow = true
        title = "Group Info"
        listView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        if !AppUtility.isLand() {
            listView.contentOffset = CGPoint(x: 0, y: initialOffsetY)
        }
        setupAvatar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IMManager.shared.addDelegate(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IMManager.shared.removeDelegate(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnEditAvatar.circle()
        checkAvatarPosition()
    }
    
    private func checkAvatarPosition() {
        if AppUtility.isLand() {
            imgViewAvatar.transform = .identity
            btnEditAvatar.transform = .identity
        } else {
            var y = -listView.contentOffset.y
            if y < 0 {
                y *= 0.5
            }
            imgViewAvatar.transform = CGAffineTransform(translationX: 0, y: y)
            btnEditAvatar.transform = CGAffineTransform(translationX: 0, y: -listView.contentOffset.y)
        }
    }
    
    private func setupAvatar() {
        imgViewAvatar.tintColor = .systemGray
        imgViewAvatar.image = chatNavigation.avatar
        imgViewAvatar.contentMode = chatNavigation.avatarContentMode
        if let channel = chatNavigation.channel, channel.chType == .single {
            btnEditAvatar.isHidden = true
        } else {
            btnEditAvatar.layer.borderWidth = 1
            btnEditAvatar.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    @IBAction func clickEditAvatar() {
        guard let channel = chatNavigation.channel else { return }
        editAvatarHelper.clickEditAvatar(avatar: channel.profileImageFileInfo.isExist ? chatNavigation.avatar : nil)
    }
    
    func clickEditSubject() {
        guard let _ = chatNavigation.channel else { return }
        
        let alert = UIAlertController(title: "Subject", message: nil, preferredStyle: .alert)
        alert.addTextField { tfSubject in
            tfSubject.keyboardType = .default
            tfSubject.text = self.chatNavigation.subject
        }
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            self.editSubject(alert.textFields?.first?.text ?? "")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    func editSubject(_ newSubject: String) {
        guard let channel = chatNavigation.channel, channel.chType != .single, newSubject.count > 0, chatNavigation.subject != newSubject else { return }
        
        IMManager.shared.setChannelSubject(chID: channel.chID, subject: newSubject) { success in
            if success {
                DispatchQueue.main.async {
                    IMManager.shared.queryChannel(chID: channel.chID)
                }
            }
        }
    }
    
    func clickMute() {
        guard let channel = chatNavigation.channel else { return }
        let newMute = !channel.isMute
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let setAction = UIAlertAction(title: channel.isMute ? "Unmute" : "Mute", style: .destructive) {_ in
            IMManager.shared.setChannelMute(chID: channel.chID, mute: newMute) { success in
                if success {
                    DispatchQueue.main.async {
                        IMManager.shared.queryChannel(chID: channel.chID)
                    }
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(setAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension ChatSettingVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if !AppUtility.isLand() {
                return AppUtility.deviceWidth
            }
        }
        return 22
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSingle {
            if indexPath.section == 0 {
                if indexPath.row == 0 || indexPath.row == 2 {
                    return 0
                }
            } else if indexPath.section == 1 {
                if indexPath.row == 1 || indexPath.row == 2 {
                    return 0
                }
            }
        } else if !isModerator {
            if indexPath.section == 1 {
                if indexPath.row == 2 {
                    return 0
                }
            }
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == numberOfSections(in: tableView) - 1 {
            return 44
        }
        return 22
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            if section == 0 {
                header.contentView.backgroundColor = .clear
                return
            }
            header.contentView.backgroundColor = .systemGray6
        }
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.contentView.backgroundColor = .systemGray6
            footer.textLabel?.textColor = .systemGray2
            footer.textLabel?.font = .systemFont(ofSize: 12)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                clickEditSubject()
            } else if indexPath.row == 1 {
                clickMute()
            } else if indexPath.row == 2 {
                performSegue(withIdentifier: "goChatMemberList", sender: nil)
            }
        } else if indexPath.section == 1 {
            if let chID = chatNavigation.channel?.chID {
                if indexPath.row == 0 {
                    IMManager.shared.deleteChannelMessages(chID: chID)
                } else if indexPath.row == 1 {
                    IMManager.shared.leaveChannel(chID: chID)
                } else if indexPath.row == 2 {
                    IMManager.shared.dismissChannel(chID: chID)
                }
            }
            
        }
    }
    
}

extension ChatSettingVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if isSingle {
            return ""
        }
        if section == numberOfSections(in: tableView) - 1 {
            if let channel = chatNavigation.channel, let creator = channel.createUserID as String? {
                let nickname = ProfileManager.shared.getUserNickname(creator) ?? "Unknow ( " + creator + " )"
                let createTime = Date(timeIntervalSince1970: Double(channel.createTime) * 0.001).dateFormat()
                return "Group created by \(nickname).\nCreate at \(createTime)."
            }
        }
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        cell.accessoryType = .none
        if indexPath.section == 0 {
            cell.textLabel?.textColor = .label
            if isSingle {
                if indexPath.row == 0 || indexPath.row == 2 {
                    return cell
                }
            }
            
            if indexPath.row == 0 {
                cell.textLabel?.text = chatNavigation.subject
                cell.accessoryType = .disclosureIndicator
                return cell
            } else if indexPath.row == 1 {
                if let isMute = chatNavigation.channel?.isMute, isMute {
                    cell.textLabel?.text = "Muted"
                    cell.textLabel?.textColor = .systemRed
                } else {
                    cell.textLabel?.text = "Mute"
                }
                return cell
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "Particpants"
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        }
        
        cell.textLabel?.textColor = .systemRed
        if indexPath.row == 0 {
            cell.textLabel?.text = "Clear Chat"
            return cell
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Exit Group"
            return cell
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "Dismiss Group"
            return cell
        }
        return cell
    }
    
}

extension ChatSettingVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkAvatarPosition()
    }
}

extension ChatSettingVC: EditAvatarProtocol {
    func deleteHandler() {
        guard let channel = chatNavigation.channel, channel.chType != .single else { return }
        IMManager.shared.setChannelAvatar(chID: channel.chID, avatar: nil) { success in
            if success {
                DispatchQueue.main.async {
                    IMManager.shared.queryChannel(chID: channel.chID)
                }
            }
        }
    }
    
    func editHandler(isLoadingPicker: Bool) {
        if isLoadingPicker {
            loading("Reading album ...", true)
        } else {
            endLoading()
        }
    }
    
    func completionHandler(avatar: UIImage?) {
        guard let image = avatar, let channel = chatNavigation.channel, channel.chType != .single else { return }
        let uploadAvatar = image.scaleToLimit(512)
        IMManager.shared.setChannelAvatar(chID: channel.chID, avatar: uploadAvatar) { success in
            if success {
                DispatchQueue.main.async {
                    IMManager.shared.queryChannel(chID: channel.chID)
                }
            }
        }
    }
}

extension ChatSettingVC: IMManagerDelegate {
    func onQueryCurrentChannel(_ channel: LTChannelResponse?) {
        guard let currentChannel = channel, let chatChannel = chatNavigation.channel, currentChannel.chID == chatChannel.chID else { return }
        chatNavigation.channel = currentChannel
        chatNavigation.subject = currentChannel.subject
        chatNavigation.avatar = ProfileManager.shared.getChannelAvatar(currentChannel.chID)
        if let avatar = chatNavigation.avatar {
            imgViewAvatar.image = avatar
        } else if currentChannel.chType == .group {
            imgViewAvatar.image = UIImage(systemName: "person.3.fill")
        } else if currentChannel.chType == .single {
            imgViewAvatar.image = UIImage(systemName: "person.crop.circle")
        }
        listView.reloadData()
    }
}
