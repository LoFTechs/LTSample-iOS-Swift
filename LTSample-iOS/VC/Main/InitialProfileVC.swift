//
//  InitialProfileVC.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/23.
//

import UIKit

class InitialProfileVC: LTVC {
    @IBOutlet weak private var imgViewAvatar: UIImageView!
    @IBOutlet weak private var btnAvatar: UIButton!
    @IBOutlet weak private var tfNickname: LTLimitTextField!
    @IBOutlet weak private var scrollView: UIScrollView!
    
    private var waitConnected = false
    private var setNicknameSuccess = true
    private var setAvatarSuccess = true
    private var isSelectDeleteAvatar = false
    
    private var selectedAvatar: UIImage?
    
    private lazy var editAvatarHelper:EditAvatarHelper = {
        return EditAvatarHelper(vc: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nickname = UserInfo.nickname
        if nickname.count > 0 {
            tfNickname.text = nickname
        }
        
        if let img = UserInfo.avatar {
            imgViewAvatar.image = img
            imgViewAvatar.contentMode = .scaleAspectFill
        } else {
            imgViewAvatar.contentMode = .scaleAspectFit
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observe(name: UITextField.textDidChangeNotification, object: tfNickname, queue: OperationQueue.main) {_ in
            self.navigationItem.rightBarButtonItem?.isEnabled = self.checkInput()
        }
        
        observe(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: OperationQueue.main) {
            guard let keyboardFrame = $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

            let keyboardScreenEndFrame: CGRect = keyboardFrame.cgRectValue
            let h = keyboardScreenEndFrame.height
            let safeBottom: CGFloat = self.view.window?.safeAreaInsets.bottom ?? 0.0
            let contentBottom = h - self.scrollView.bounds.height + self.scrollView.contentSize.height + safeBottom * 2 // Magic number safeBottom * 2
            self.scrollView.contentInset.bottom = contentBottom
            self.scrollView.verticalScrollIndicatorInsets.bottom = contentBottom
            self.scrollView.scrollToBottom(false)
            
            if AppUtility.isLand() {
                self.scrollView.contentOffset.y += safeBottom * 0.5 //Magic number
            }
        }
        
        if !tfNickname.isFirstResponder && UserInfo.nickname.count == 0 {
            tfNickname.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeAllObserve()
        IMManager.shared.removeDelegate(self)
    }
    
    override func viewDidLayoutSubviews() {
        imgViewAvatar.circle()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func clickDone() {
        IMManager.shared.addDelegate(self)
        if IMManager.shared.isConnected {
            setProfile()
        } else {
            waitConnected = true
            loading("Connecting ...", true)
        }
    }
    
    @IBAction func clickEditAvatar() {
        editAvatarHelper.clickEditAvatar(avatar: UserInfo.avatar)
    }
    
    private func checkInput() -> Bool {
        if tfNickname.text?.count == 0 || (tfNickname.text == UserInfo.nickname && selectedAvatar == nil && !isSelectDeleteAvatar) {
            return false
        }
        
        return true
    }
    
    private func setProfile() {
        loading("Setting up ...", true)
        
        if selectedAvatar != nil || isSelectDeleteAvatar {
            setAvatarSuccess = false
            IMManager.shared.setMyAvatar(selectedAvatar)
        }
        
        if tfNickname.text!.count > 0 && tfNickname.text != UserInfo.nickname {
            setNicknameSuccess = false
            IMManager.shared.setMyNickname(tfNickname.text!)
        }
    }
    
    private func checkDone() {
        if setAvatarSuccess && setNicknameSuccess {
            endLoading()
            if let navi = navigationController, navi.viewControllers.count > 1 {
                navigationItem.rightBarButtonItem?.isEnabled = self.checkInput()
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

extension InitialProfileVC: IMManagerDelegate {
    func onConnected() {
        if waitConnected {
            setProfile()
            waitConnected = false
        }
    }
    
    func onSetMyNickname(_ userProfile: [AnyHashable : Any]?) {
        guard let _ = userProfile, let nickname = userProfile?["nickname"] as? String else {
            AppUtility.alert("Setting failed")
            endLoading()
            return
        }
        print("nickname = " + nickname)
        setNicknameSuccess = true
        UserInfo.saveNickname(nickname)
        checkDone()
    }
    
    func onSetMyAvatar(_ userProfile: [AnyHashable: Any]?) {
        guard let _ = userProfile, let profileImageID = userProfile?["profileImageID"] as? String else {
            AppUtility.alert("Setting failed")
            endLoading()
            return
        }
        print("profileImageID = " + profileImageID)
        setAvatarSuccess = true
        selectedAvatar = nil
        isSelectDeleteAvatar = false
        checkDone()
    }
}

extension InitialProfileVC: EditAvatarProtocol {
    func deleteHandler() {
        self.selectedAvatar = nil
        self.imgViewAvatar.image = UIImage(systemName: "person.circle.fill")
        self.imgViewAvatar.contentMode = .scaleAspectFit
        self.setAvatarSuccess = false
        self.isSelectDeleteAvatar = true
        self.navigationItem.rightBarButtonItem?.isEnabled = self.checkInput()
    }
    
    func editHandler(isLoadingPicker: Bool) {
        if isLoadingPicker {
            loading("Read album ...", true)
        } else {
            endLoading()
        }
    }
    
    func completionHandler(avatar: UIImage?) {
        if let image = avatar {
            selectedAvatar = image.scaleToLimit(512)
            imgViewAvatar.image = selectedAvatar
            imgViewAvatar.contentMode = .scaleAspectFill
            self.navigationItem.rightBarButtonItem?.isEnabled = self.checkInput()
        }
    }
}
