//
//  CallLogListVC.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/23.
//

import UIKit

class CallLogListVC: LTListVC {
    
    var items = [LTCallCDRNotificationMessage]()
    var queryCallLoging = false
    var callUserInfos = [String: LTCallUserInfo]()
    
    private var callLogEmptyView: LTListEmptyView = {
        let title = NSMutableAttributedString(string: "To place a voice call, tap  ")
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "IconNewCall_Normal")?.withTintColor(.label)
        attachment.bounds = CGRect(x: 0, y: -4, width: 22, height: 22)
        title.append(NSAttributedString(attachment: attachment))
        title.append(NSAttributedString(string: "  at the top and select a friend."))
        
        let view = UINib(nibName: "LTListEmptyView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! LTListEmptyView
        view.attributedTitle = title
        view.subTitle = "You can talk to other friends."
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        binding()
        setupEmpty()
        loadCallogs(20)
    }
    
    func binding() {
        ProfileManager.shared.addDelegate(self)
        CallManager.shared.callLogDelegate = self
        listView.delegate = self
        listView.dataSource = self
//        listView.register(UINib(nibName: "CallLogListCell", bundle: nil), forCellReuseIdentifier: "CallLogCell")
        listView.register(CallLogListCell.self, forCellReuseIdentifier: "CallLogListCell")

    }
    
    func loadCallogs(_ countN: Int) {
        guard !queryCallLoging else { return }
        queryCallLoging = true
        if items.count < countN {
            let markTS:Double = items.count == 0 ? NSDate().timeIntervalSince1970 * 1000 : items.last!.sendTime
            let afterN = items.count - countN
            CallManager.shared.queryCDR(markTS: markTS, afterN: afterN)
        }
    }
    
    private func setupEmpty() {
        let action = LTListEmptyViewAction(title: "Start call") {
            self.clickCreateCall()
        }
        callLogEmptyView.addAction(action)
        emptyView = callLogEmptyView
    }
    
    @IBAction private func clickCreateCall() {
        let storyboard = UIStoryboard(name: "Create", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() as? CreateNavigationController {
            vc.type = .call
            present(vc, animated: true, completion: nil)
        }
    }
}

//MARK: UITableView
extension CallLogListVC:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emptyViewShow = items.count == 0
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CallLogListCell.avatarSize() + 24
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CallLogListCell", for: indexPath) as? CallLogListCell, indexPath.row < items.count else {
            return UITableViewCell()
        }
        
        if indexPath.row == items.count - 1 {
            loadCallogs(items.count + 20)
        }
        
        let item = items[indexPath.row]
        
        var callUserInfo:LTCallUserInfo
        if item.callerInfo.userID == UserInfo.userID {
            callUserInfo = item.calleeInfo
            cell.setState(CallLogState.outgoingCall, callMode: item.callMode)
        } else if item.billingSecond == 0 {
            callUserInfo = item.callerInfo
            cell.setState(CallLogState.missCall, callMode: item.callMode)
        } else {
            callUserInfo = item.callerInfo
            cell.setState(CallLogState.incomingCall, callMode: item.callMode)
        }
        
        cell.time = Date(timeIntervalSince1970: item.callStartTime / 1000).dateFormat()
        cell.imgViewAvatar.tintColor = .systemGray4
        
        callUserInfos[callUserInfo.userID] = callUserInfo
        let (nickname, avatar) = ProfileManager.shared.getUserProfile(callUserInfo.userID)
        
        cell.name = nickname ?? callUserInfo.semiUID
        
        if let img = avatar {
            cell.avatar = img
            cell.imgViewAvatar.contentMode = .scaleAspectFill
        } else {
            cell.avatar = UIImage(systemName: "person.crop.circle")?.withTintColor(.label)
            cell.imgViewAvatar.contentMode = .scaleAspectFit
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard indexPath.row < items.count else {
            return
        }
        
        let item = items[indexPath.row]
        let userInfo = item.callerInfo.userID == UserInfo.userID ? item.calleeInfo : item.callerInfo
        let name = ProfileManager.shared.getUserNickname(userInfo.userID) ?? userInfo.semiUID
        
        if item.callMode == LTCallMode.video {
            CallManager.shared.startCall(userID: userInfo.userID, name: name, callMode: LTCallMode.video)
        } else {
            CallManager.shared.startCall(userID: userInfo.userID, name: name, callMode: LTCallMode.voice)
        }
    }
    
}

//MARK: CallLogDelegate
extension CallLogListVC: CallLogDelegate {
    func getCallLogs(_ cdrs: [LTCallCDRNotificationMessage]) {
        guard cdrs.count > 0 else { return }
        
        queryCallLoging = false
        
        items += cdrs.filter({ cdr -> Bool in
            return !self.items.contains { item -> Bool in
                return item.callID == cdr.callID
            }
        })
        
        items.sort { (itemA, itemB) -> Bool in
            return itemA.sendTime > itemB.sendTime
        }
        
        listView.reloadData()
    }
}

//MARK: ProfileManagerDelagate

extension CallLogListVC: ProfileManagerDelagate {
    func profileUpdate(userIDs: [String]) {
        if let _ = userIDs.first(where: { userID -> Bool in
            return callUserInfos.keys.contains { callLogUserID -> Bool in
                return callLogUserID == userID
            }
        }) {
            listView.reloadData()
        }
    }
}
