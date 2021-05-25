//
//  CreateVC.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/27.
//

import UIKit

class CreateVC: CreateBaseVC {
    
    private var type: CreateType {
        get {
            return navigation.type
        }
    }
    private var filter = [Friend]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listView.register(AvatarTitleTVCell.self, forCellReuseIdentifier: "AvatarTitleTVCell")
        searchShow = true
        listViewShow = true
        search.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if type == .call {
            title = "New Call"
        } else if type == .chat {
            title = "New Chat"
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listView.reloadData()
        FriendManager.shared.addDelegate(self)
        ProfileManager.shared.addDelegate(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        FriendManager.shared.removeDelegate(self)
        ProfileManager.shared.removeDelegate(self)
    }
    
    @IBAction func clickCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    private func addFriend() {
        let alert = UIAlertController(title: "New Friend", message: nil, preferredStyle: .alert)

        let done = UIAlertAction(title: "Confirm", style: .default) { _ in
            if let accountID = alert.textFields?.first?.text {
                self.loading("Searching ...", true)
                FriendManager.shared.addFriend(accountID)
            }
            self.removeAllObserve()
        }
        done.isEnabled = false
        alert.addAction(done)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.removeAllObserve()
        }
        alert.addAction(cancel)
        
        alert.addTextField { textfield in
            self.observe(name: UITextField.textDidChangeNotification, object: textfield, queue: OperationQueue.main) {_ in
                done.isEnabled = textfield.hasText
            }
            textfield.placeholder = "Enter a friend's account"
            textfield.keyboardType = .alphabet
        }
        
        present(alert, animated: true, completion: nil)
    }
}

extension CreateVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AvatarTitleTVCell.avatarSize() + 12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            performSegue(withIdentifier: "goCreateGroup", sender: nil)
        } else if indexPath.section == 1 {
            addFriend()
        } else {
            let friends = isSearching ? filter : FriendManager.shared.friends
            guard friends.count > indexPath.row else {
                return
            }
            
            let friend = friends[indexPath.row]
            let cell = tableView.cellForRow(at: indexPath) as! AvatarTitleTVCell
            select(friend, profile: (cell.avatar, cell.title, cell.imgViewAvatar.contentMode))
        }
    }
    
    private func select(_ friend: Friend, profile: (UIImage?, String?, UIView.ContentMode)) {
        if type == .call {
            outgoingCall(friend)
        } else if type == .chat {
            navigation.createDelegate?.createNC(navigation, selectedFriend: friend, profile: profile)
        }
    }
    
    private func outgoingCall(_ friend: Friend) {
        dismiss(animated: true) {
            let nickname = ProfileManager.shared.getUserNickname(friend.userID) ?? friend.userID
            CallManager.shared.startCall(userID: friend.userID, name: nickname)
        }
    }
}

extension CreateVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if FriendManager.shared.friends.count == 0 || isSearching {
                return 0
            }
            
            if type == .call {//TODO: 未實作群組通話
                return 0
            }
            return 1
        } else if section == 1 {
            if isSearching {
                return 0
            }
            return 1
        }
        
        if isSearching {
            return filter.count
        }
        
        return FriendManager.shared.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AvatarTitleTVCell", for: indexPath) as? AvatarTitleTVCell else {
            return UITableViewCell()
        }

        if indexPath.section == 0 {
            setupCreateGroupCell(cell)
            
        } else if indexPath.section == 1 {
            cell.isSystem = true
            cell.title = "New Friend"
            cell.avatar = UIImage(systemName: "person.badge.plus.fill")
            
        } else {
            cell.isSystem = false
            cell.avatar = UIImage(systemName: "person.crop.circle.fill")
            cell.title = ""
            
            let friends = isSearching ? filter : FriendManager.shared.friends
            if indexPath.row < friends.count {
                let userID = friends[indexPath.row].userID
                let (nickname, avatar) = ProfileManager.shared.getUserProfile(userID)
                cell.title = nickname ?? "Unknown(\(friends[indexPath.row].userID))"
                
                if let img = avatar {
                    cell.avatar = img
                    cell.imgViewAvatar.contentMode = .scaleAspectFill
                } else {
                    cell.avatar = UIImage(systemName: "person.crop.circle.fill")
                    cell.imgViewAvatar.contentMode = .scaleAspectFit
                }
            }
        }

        return cell
    }
    
    private func setupCreateGroupCell(_ cell: AvatarTitleTVCell) {
        cell.isSystem = true
        cell.avatar = UIImage(systemName: "person.2.fill")
        if type == .call {
            cell.title = "New Group Call"
        } else if type == .chat {
            cell.title = "New Group"
        }
    }
}


extension CreateVC: FriendManagerDelegate {
    func friendManagerSearchFriendFail(_ errMsg: String) {
        endLoading()
        AppUtility.alert("Search failed: " + errMsg)
    }
    
    func friendManagerWillAddFriend() {
        loading("Join friends ...", true)
    }
    
    func friendManagerDidAddFriend(_ success: Bool, _ errMsg: String?) {
        endLoading()
        if success {
            AppUtility.alert("Join successfully")
        } else {
            AppUtility.alert("Failed to join: " + errMsg!)
        }
    }
    
    func friendManagerChangedFriends() {
        listView.reloadData()
    }
    
}

extension CreateVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filter.removeAll()
        let f = FriendManager.shared.friends.filter({(ProfileManager.shared.getUserNickname($0.userID) ?? "Unknow \($0.userID)").contains(searchText)})
        filter.append(contentsOf: f)
        listView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filter.removeAll()
        listView.reloadData()
    }
}

extension CreateVC: ProfileManagerDelagate {
    func profileUpdate(userIDs: [String]) {
        var friends = FriendManager.shared.friends
        if isSearching {
            friends = navigation.selectedFriendIndexArray.map { FriendManager.shared.friends[$0] }
        }
        if let _ = userIDs.first(where: { userID -> Bool in
            return friends.contains { friend -> Bool in
                return friend.userID == userID
            }
        }) {
            listView.reloadData()
        }
    }
}
