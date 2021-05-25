//
//  CreateSelectVC.swift
//  LTSample-iOS
//
//  Created by 游勝滄 on 2021/4/28.
//

import UIKit

class CreateSelectVC: CreateBaseVC {
    
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var layoutCollectionHeight: NSLayoutConstraint!
    
    private var titleView: TwoLineTitleView = {
        let view = TwoLineTitleView()
        view.title = "Add Participants"
        view.subTitle = "0 people selected"
        return view
    }()
    
    private var filter = [Friend]()
    private var allFriends: [Friend] {
        get {
            if let ignore = navigation.ignore, ignore.count > 0 {
                return FriendManager.shared.friends.filter {
                    return !ignore.contains($0.userID)
                }
            }
            return FriendManager.shared.friends
        }
    }
    
    override func viewDidLoad() {
        layoutCollectionHeight.constant = 0
        super.viewDidLoad()
        searchShow = true
        listViewShow = true
        listView.register(AvatarTitleTVCell.self, forCellReuseIdentifier: "AvatarTitleTVCell")
        listView.isEditing = true
        collectionView.register(AvatarCVCell.self, forCellWithReuseIdentifier: "AvatarCVCell")
        search.hidesNavigationBarDuringPresentation = false
        search.searchBar.delegate = self
        navigationItem.titleView = titleView
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ProfileManager.shared.addDelegate(self)
        listView.reloadData()
        collectionView.reloadData()
        checkSelected()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ProfileManager.shared.removeDelegate(self)
    }
    
    @IBAction private func clickNext() {
        if navigation.type == .invite {
            if let chID = navigation.currentChannel?.chID {
                let members = navigation.selectedFriendIndexArray.map {
                    FriendManager.shared.friends[$0]
                }.map({ friend -> LTMemberModel in
                    let member = LTMemberModel()
                    member.userID = friend.userID
                    member.roleID = .participant
                    return member
                })
                IMManager.shared.inviteChannelMember(chID: chID, members: members)
            }
            clickCancel()
        }
        performSegue(withIdentifier: "goCreateGroupProfile", sender: nil)

    }
    
    @IBAction private func clickCancel() {
        if navigationController?.viewControllers.count == 1 {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func checkSelected() {
        let show: CGFloat = navigation.selectedFriendIndexArray.count > 0 ? 108 : 0
        titleView.subTitle = "\(navigation.selectedFriendIndexArray.count) people selected"
        if show != layoutCollectionHeight.constant {
            UIView.animate(withDuration: 0.15) {
                self.layoutCollectionHeight.constant = show
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func removeSelectIndex(_ index: Int, animated: Bool = false) {
        if !animated {
            navigation.selectedFriendIndexArray.remove(at: index)
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            checkSelected()
            return
        }
        
        if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? AvatarCVCell {
            cell.animatedDisappear {
                self.removeSelectIndex(index)
            }
        } else {
            removeSelectIndex(index)
        }
    }
}

extension CreateSelectVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AvatarTitleTVCell.avatarSize() + 12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filter.count == 0 {
            navigation.selectedFriendIndexArray.append(indexPath.row)
        } else {
            let friend = filter[indexPath.row]
            if let index = allFriends.firstIndex(where: { $0.userID == friend.userID}) {
                navigation.selectedFriendIndexArray.append(index)
            }
        }
        checkSelected()
        collectionView.insertItems(at: [IndexPath(item: navigation.selectedFriendIndexArray.count - 1, section: 0)])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        var indexRow = indexPath.row
        if isSearching {
            let friend = filter[indexPath.row]
            if let index = allFriends.firstIndex(where: { $0.userID == friend.userID}) {
                indexRow = index
            }
        }
        
        if let index = navigation.selectedFriendIndexArray.firstIndex(where: { $0 == indexRow } ) {
            removeSelectIndex(index, animated: true)
        }
    }
}

extension CreateSelectVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filter.count
        }
        
        return allFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AvatarTitleTVCell", for: indexPath) as? AvatarTitleTVCell else {
            return UITableViewCell()
        }
        
        cell.isSystem = false
        cell.avatar = UIImage(systemName: "person.crop.circle.fill")
        let friends = isSearching ? filter : allFriends
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
        
        var indexRow = indexPath.row
        if isSearching {
            let friend = filter[indexPath.row]
            if let index = allFriends.firstIndex(where: { $0.userID == friend.userID}) {
                indexRow = index
            }
        }
        
        if let _ = navigation.selectedFriendIndexArray.firstIndex(where: { $0 == indexRow } ) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
        return cell
    }
}

extension CreateSelectVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let avatarCell = cell as? AvatarCVCell else {
            return
        }
        let size = collectionView.bounds.size
        let interFrame = CGRect(x: collectionView.contentOffset.x, y: 0, width: size.width, height: size.height).intersection(cell.frame)
        if interFrame.width > 20 {
            avatarCell.animatedAppear()
        }
    }
    
     func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let avatarCell = cell as? AvatarCVCell else {
            return
        }
        avatarCell.removeAllAnimation()
    }
    
}

extension CreateSelectVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = navigation.selectedFriendIndexArray.count
        navigationItem.rightBarButtonItem?.isEnabled = count > 0
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCVCell", for: indexPath) as? AvatarCVCell else {
            return UICollectionViewCell()
        }
        
        cell.title = ""
        cell.avatar = UIImage(systemName: "person.crop.circle.fill")
        cell.delegate = self
        if indexPath.row < navigation.selectedFriendIndexArray.count {
            let index = navigation.selectedFriendIndexArray[indexPath.row]
            let friends = allFriends
            if index < friends.count {
                let userID = friends[index].userID
                let (nickname, avatar) = ProfileManager.shared.getUserProfile(userID)
                cell.title = nickname ?? "Unknown(\(friends[index].userID))"
                
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

}

extension CreateSelectVC: AvatarCVCellDelegate {
    func avatarCVCellDidClickClose(_ cell: AvatarCVCell) {
        if let index = collectionView.indexPath(for: cell)?.row {
            if index < navigation.selectedFriendIndexArray.count {
                let indexPath = IndexPath(row: navigation.selectedFriendIndexArray[index], section: 0)
                listView.deselectRow(at: indexPath, animated: true)
            }
            removeSelectIndex(index, animated: true)
        }
    }
}

extension CreateSelectVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filter.removeAll()
        let f = allFriends.filter({(ProfileManager.shared.getUserNickname($0.userID) ?? "Unknow \($0.userID)").contains(searchText)})
        filter.append(contentsOf: f)
        listView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filter.removeAll()
        listView.reloadData()
    }
}

extension CreateSelectVC: ProfileManagerDelagate {
    func profileUpdate(userIDs: [String]) {
        
        var friends = allFriends
        if isSearching {
            friends = navigation.selectedFriendIndexArray.map { allFriends[$0] }
        }
        if let _ = userIDs.first(where: { userID -> Bool in
            return friends.contains { friend -> Bool in
                return friend.userID == userID
            }
        }) {
            listView.reloadData()
            collectionView.reloadData()
        }
    }
}
