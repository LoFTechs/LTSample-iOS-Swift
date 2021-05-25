//
//  GetAuthenVC.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/23.
//

import UIKit

class GetAuthenVC: UIViewController {
    
    private var isSuccess = false
    private var isAppear = false
    private var isLaunched = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserInfo.userID.count == 0 {
            return
        }
        isLaunched = true
        getAuthenInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isAppear = true
        if isLaunched {
            checkNickname()
        } else {
            getAuthenInfo()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    private func getAuthenInfo() {
        SDKManager.shared.getAuthenInfo { success in
            DispatchQueue.main.async {
                if success {
                    self.isSuccess = success
                    self.checkNickname()
                } else {
                    AppUtility.alert("Unable to obtain authentication information")
                    //TODO: 例外處理
                }
            }
        }
    }
    
    private func checkNickname() {
        if isAppear && isSuccess {
            if UserInfo.nickname.count > 0 {
                performSegue(withIdentifier: "goMainVC", sender: nil)
            } else {
                performSegue(withIdentifier: "goInitialProfile", sender: nil)
            }
        }
    }
    
}
