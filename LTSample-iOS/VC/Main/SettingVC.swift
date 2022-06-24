//
//  SettingVC.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/23.
//

import UIKit

class SettingVC: LTVC {
    @IBOutlet weak private var listView: UITableView!
    private let switchMute: UISwitch = {
        let view = UISwitch()
        view.isOn = !UserInfo.notificationMute
        view.isUserInteractionEnabled = false
        return view
    }()
    private let switchContent: UISwitch = {
        let view = UISwitch()
        view.isOn = !UserInfo.notificationContent
        view.isUserInteractionEnabled = false
        return view
    }()
    private let switchDisplay: UISwitch = {
        let view = UISwitch()
        view.isOn = !UserInfo.notificationDisplay
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private var settingContent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listView.register(SettingProfileCell.self, forCellReuseIdentifier: "SettingProfileCell")
        listView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        listView.backgroundView = nil
        listView.backgroundColor = .clear
        view.backgroundColor = .systemGray5
        IMManager.shared.addDelegate(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IMManager.shared.queryMyApnsSetting()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func getSwitch(_ index: IndexPath) -> UISwitch? {
        guard let cell = listView.cellForRow(at: index) else {
            return nil
        }
        
        if let s = cell.accessoryView as? UISwitch {
            return s
        }
        
        let new = UISwitch()
        cell.accessoryView = new
        new.isUserInteractionEnabled = false
        return new
    }
}

extension SettingVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let bottomLine = getLine(view, tag: 9999)
        bottomLine.frame = CGRect(x: 0, y: view.bounds.height - 1, width: view.bounds.width, height: 1)
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let topLine = getLine(view, tag: 9998)
        topLine.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 1)
    }
    
    private func getLine(_ view: UIView, tag: Int) -> UIView {
        if let line = view.viewWithTag(tag) {
            return line
        }
        
        let new = UIView()
        new.backgroundColor = .systemGray5
        new.tag = tag
        view.addSubview(new)
        return new
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return SettingProfileCell.avatarSize() + 20
        }
        return 48
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch (indexPath.section, indexPath.row) {
        case (0, _):
            performSegue(withIdentifier: "goInitialProfileFromSetting", sender: nil)
        case (1, _):
            loading("Setting up ...")
            fallthrough
        case (1,0):
            switchMute.isOn.toggle()
            IMManager.shared.setApnsMute(!UserInfo.notificationMute)
        case (1,1):
            settingContent = true
            switchContent.isOn.toggle()
            IMManager.shared.setApnsDisplaySender(!UserInfo.notificationDisplay, displayContent: UserInfo.notificationContent)
        case (1,2):
            settingContent = false
            switchDisplay.isOn.toggle()
            IMManager.shared.setApnsDisplaySender(UserInfo.notificationDisplay, displayContent: !UserInfo.notificationContent)
        case (2,0):
            let alert = UIAlertController(title: "Are you sure you want to log out?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
                SDKManager.shared.logout()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true, completion: nil)
        case (2,1):
            let alert = UIAlertController(title: "Are you sure you want to delete account?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
                SDKManager.shared.deleteAccount()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true, completion: nil)
            break
        case (_, _):break
        }
    }
}

extension SettingVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "MESSAGE NOTIFICATIONS"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 3
        case 2: return 2
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingProfileCell", for: indexPath) as? SettingProfileCell else {
                return UITableViewCell()
            }
            
            if let avatar = UserInfo.avatar {
                cell.avatar = avatar
                cell.imgViewAvatar.contentMode = .scaleAspectFill
            } else {
                cell.avatar = UIImage(systemName: "person.circle.fill")
                cell.isSystem = false
                cell.imgViewAvatar.contentMode = .scaleAspectFit
            }
            cell.title = UserInfo.nickname
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.numberOfLines = 1
        cell.textLabel?.font = .systemFont(ofSize: 18)
        
        switch (indexPath.section, indexPath.row) {
        case (1,0):
            cell.textLabel?.text = "Show notification"
            cell.accessoryView = switchMute
        case (1,1):
            cell.textLabel?.text = "Show notification content"
            cell.accessoryView = switchContent
        case (1,2):
            cell.textLabel?.text = "Show notification sender"
            cell.accessoryView = switchDisplay
        case (2,0):
            cell.textLabel?.text = "Log out"
            cell.textLabel?.textColor = .systemRed
        case (2,1):
            cell.textLabel?.text = "Delete my account"
            cell.textLabel?.textColor = .systemRed
        case (_, _):break
        }
        return cell
    }
}

extension SettingVC: IMManagerDelegate {

    func onQueryMyApnsSetting(_ myApnsSetting: LTQueryUserDeviceNotifyResponse?) {
        if let rp = myApnsSetting {
            UserInfo.saveNotificationMute(rp.notifyData.isMute)
            switchMute.isOn = !UserInfo.notificationMute
            
            UserInfo.saveNotificationContent(rp.notifyData.hidingContent)
            switchContent.isOn = !UserInfo.notificationContent
            
            UserInfo.saveNotificationDisplay(rp.notifyData.hidingCaller)
            switchDisplay.isOn = !UserInfo.notificationDisplay
        }
    }
    
    func onSetMyAvatar(_ userProfile: [AnyHashable: Any]?) {
        listView.reloadData()
    }
    
    func onSetApnsMute(_ success: Bool) {
        endLoading()
        if success {
            UserInfo.saveNotificationMute(!UserInfo.notificationMute)
        } else {
            switchMute.isOn.toggle()
        }
    }
    
    func onSetApnsDisplay(_ success: Bool) {
        endLoading()
        if success {
            if settingContent {
                UserInfo.saveNotificationContent(!UserInfo.notificationContent)
            } else {
                UserInfo.saveNotificationDisplay(!UserInfo.notificationDisplay)
            }
        } else {
            if settingContent {
                switchContent.isOn.toggle()
            } else {
                switchDisplay.isOn.toggle()
            }
        }
    }
}
