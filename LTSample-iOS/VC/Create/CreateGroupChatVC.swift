//
//  CreateGroupChatVC.swift
//  LTSample-iOS
//
//  Created by 游勝滄 on 2021/5/2.
//

import UIKit

class CreateGroupChatVC: CreateBaseVC {
    
    private var isNotFirstLayout = true
    private var numberSectionView: UITableViewHeaderFooterView = {
        let view = UITableViewHeaderFooterView()
        view.textLabel?.text = "0 people selected"
        view.textLabel?.font = .systemFont(ofSize: 14)
        view.textLabel?.textColor = .systemGray
        return view
    }()
    private let profileCell: CreateGroupChatProfileCell = {
        guard let cell = UINib(nibName: "CreateGroupChatProfileCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as? CreateGroupChatProfileCell else {
            return CreateGroupChatProfileCell()
        }
        
        return cell
    }()
    
    private let collectionCell = CollectionViewTVCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listViewShow = true
        profileCell.delegate = self
        profileCell.avatar = navigation.avatar
        profileCell.subject = navigation.subject
        checkCreateAvailable()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observe(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: OperationQueue.main) {
            guard let keyboardFrame = $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            
            let keyboardScreenEndFrame: CGRect = keyboardFrame.cgRectValue
            self.listView.contentInset.bottom = keyboardScreenEndFrame.height
        }
        ProfileManager.shared.addDelegate(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = profileCell.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeAllObserve()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ProfileManager.shared.removeDelegate(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isNotFirstLayout {
            listView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
        }
        isNotFirstLayout = false
    }
    
    private func setupCollectionView() {
        collectionCell.collectionView.delegate = self
        collectionCell.collectionView.dataSource = self
        collectionCell.collectionView.register(AvatarCVCell.self, forCellWithReuseIdentifier: "AvatarCVCell")
        let w = AppUtility.deviceWidth * 0.25
        collectionCell.flowLayout?.itemSize = CGSize(width: w, height: 108)
        collectionCell.flowLayout?.minimumInteritemSpacing = 0
    }
    
    private func numberOfRowInCollectionView() -> Int {
        let w = AppUtility.deviceWidth * 0.25
        let numberOfRow = Int(listView.bounds.width / w)
        let count = navigation.selectedFriendIndexArray.count
        let row = count / numberOfRow + (count % numberOfRow > 0 ? 1 : 0)
        return row
    }
    
    private func checkNumberSecitonTitle() {
        numberSectionView.textLabel?.text = "\(navigation.selectedFriendIndexArray.count) people selected"
        numberSectionView.textLabel?.sizeToFit()
    }
    
    private func checkCreateAvailable() {
        let canCreate = (navigation.selectedFriendIndexArray.count > 0 && profileCell.subject.count > 0)
        navigationItem.rightBarButtonItem?.isEnabled = canCreate
    }
    
    @IBAction private func clickCreate() {
        let friends = navigation.selectedFriendIndexArray.map { FriendManager.shared.friends[$0] }
        loading("Creating ...", true)
        IMManager.shared.createGroupChannel(friends, subject: navigation.subject, avatar: navigation.avatar) { (success, chID) in
            self.endLoading()
            if success {
                self.navigation.createDelegate?.createNC(self.navigation, createdChannel: chID, profile: (self.navigation.avatar ?? UIImage(systemName: "person.3.fill"), self.navigation.subject, self.profileCell.imgAvatar.contentMode))
            } else {
                AppUtility.alert("Creation failure")
            }
        }
    }
    
}

extension CreateGroupChatVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 26
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 140
        }
        
        if navigation.selectedFriendIndexArray.count == 0 {
            return 0
        }
        
        if let space = collectionCell.flowLayout?.minimumLineSpacing {
            let row = numberOfRowInCollectionView()
            return CGFloat(row) * 108 + CGFloat(row - 2) * space
        }
 
        return 44
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 1 {
            numberSectionView.textLabel?.font = .systemFont(ofSize: 12)
        }
    }
}

extension CreateGroupChatVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            checkNumberSecitonTitle()
            return numberSectionView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            return profileCell
        }

        return collectionCell
    }
    
}

extension CreateGroupChatVC: UICollectionViewDelegate {

}

extension CreateGroupChatVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return navigation.selectedFriendIndexArray.count
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
            let friends = FriendManager.shared.friends
            if index < friends.count {
                let userID = friends[index].userID
                let (nickname, avatar) = ProfileManager.shared.getUserProfile(userID)
                cell.title = nickname ?? "Unknown(\(userID))"
                
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

extension CreateGroupChatVC: CreateGroupChatProfileCellDelegate {
    func CreateGroupChatProfileCellDidClickAvatar(_ cell: CreateGroupChatProfileCell) {
        guard let _ = navigation.avatar else {
            selectImage()
            return
        }
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let remove = UIAlertAction(title: "Reset Avatar", style: .destructive) { _ in
            self.navigation.avatar = nil
            self.profileCell.avatar = nil
        }
        
        let select = UIAlertAction(title: "Select", style: .default) { _ in
            self.selectImage()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        sheet.addAction(remove)
        sheet.addAction(select)
        sheet.addAction(cancel)
        
        present(sheet, animated: true, completion: nil)
    }
    
    private func selectImage() {
        loading("Reading album...", true)
        DispatchQueue.main.async {
            let vc = UIImagePickerController()
            vc.modalPresentationStyle = .fullScreen
            vc.delegate = self
            self.present(vc, animated: true, completion:{
                self.endLoading()
            })
        }
    }
    
    func CreateGroupChatProfileCellSubjectDidChange(_ cell: CreateGroupChatProfileCell) {
        navigation.subject = cell.subject
        checkCreateAvailable()
    }

}

extension CreateGroupChatVC: AvatarCVCellDelegate {
    func avatarCVCellDidClickClose(_ cell: AvatarCVCell) {
        if let indexPath = collectionCell.collectionView.indexPath(for: cell) {
            cell.animatedDisappear {
                let old = self.numberOfRowInCollectionView()
                self.navigation.selectedFriendIndexArray.remove(at: indexPath.row)
                let new = self.numberOfRowInCollectionView()
                if old != new {
                    self.listView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
                }
                self.collectionCell.collectionView.deleteItems(at: [indexPath])
                self.checkNumberSecitonTitle()
                self.checkCreateAvailable()
            }
        }
    }
}

extension CreateGroupChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            navigation.avatar = image.scaleToLimit(512)
            profileCell.avatar = navigation.avatar
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CreateGroupChatVC: ProfileManagerDelagate {
    func profileUpdate(userIDs: [String]) {
        let friends = navigation.selectedFriendIndexArray.map { FriendManager.shared.friends[$0] }
        if let _ = userIDs.first(where: { userID -> Bool in
            return friends.contains { friend -> Bool in
                return friend.userID == userID
            }
        }) {
            collectionCell.collectionView.reloadData()
        }
    }
}
