//
//  SDKManager.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/19.
//

import Foundation

class SDKManager {
    
    static let shared = SDKManager()
    
    private var apnsToken: String = ""
    private var voipToken: String = ""
    private lazy var httpClientHelper = HttpClientHelper()
    
    func initSDK(_ completion: @escaping (Bool) ->Void) {
        
        guard let licenseKey = Config.licenseKey, licenseKey.count > 0,
              let ltsdkAuthAPI = Config.ltsdkAuthAPI, ltsdkAuthAPI.count > 0 else {
            print("Please set Config.plist and UserInfo.plist in project.")
            completion(false)
            return
        }
        
        guard UserInfo.userID.count > 0, UserInfo.uuid.count > 0 else {
            completion(false)
            return
        }
        
        let options = LTSDKOptions()
        options.licenseKey = licenseKey
        options.url = ltsdkAuthAPI
        options.userID = UserInfo.userID
        options.uuid = UserInfo.uuid
        
        //LTSDK
        LTSDK.initWith(options) { (response) in
            DispatchQueue.main.async {
                if response.returnCode == .success {
                    print("Init SDK success")
                    if UserInfo.userID.count == 0 {
                        print("Please log in or register.")
                        completion(false)
                        return
                    }
                    completion(true)
                    
                } else if response.returnCode == .notCurrentUser {
                    LTSDK.clean()
                    self.initSDK(completion)
                } else {
                    print(response.returnMessage)
                    completion(false)
                }
            }
        }
        
        
        //LTCallManager
        CallManager.shared.initSDK()
    }
    
    func getAuthenInfo(_ completion: @escaping (Bool) ->Void) {
        LTSDK.getUsersWithCompletion { (rp, users) in
            DispatchQueue.main.async {
                if rp.returnCode == .success {
                    if let user = LTSDK.getUserWithUserID(UserInfo.userID) {
                        //LTIMManager
                        IMManager.shared.initSDK(user)
                        DownloadManager.shared.setManager(user: user)
                        completion(true)
                    } else {
                        print("No user")
                        completion(false)
                    }
                    
                } else {
                    print(rp.returnMessage)
                    completion(false)
                }
            }
        }
    }
    
    //MARK: - APNS
    func updateApnsToken(_ token: String) {
        apnsToken = token
        uploadNotificationKey(nil)
    }

    func updateVoipToken(_ token: String) {
        voipToken = token
        uploadNotificationKey(nil)
    }
    
    func uploadNotificationKey(_ completion: ((Bool) ->Void)?) {
        NSLog("uploadNotificationKey:" + apnsToken + " " + voipToken)
        if apnsToken.count == 0 || voipToken.count == 0 {
            if let handler = completion {
                handler(false)
            }
            return
        }
        
        let isDebug = _isDebugAssertConfiguration()
        
        LTSDK.updateNotificationKey(withAPNSToken: apnsToken, voipToken: voipToken, cleanOld: true, isDebug: isDebug) { (response) in
            DispatchQueue.main.async {
                if response.returnCode == .success {
                    NSLog("uploadNotificationKey Success")
                    if let handler = completion {
                        handler(true)
                    }
                } else if let handler = completion {
                    handler(false)
                }
            }
        }
    }
    
    //MARK: - Register
    func register(_ account: String, password: String, completion: ((ReturnCode) ->Void)?) {
        httpClientHelper.register(account, password: password) { (returnCode) in
            self.returnAction(returnCode, completion: completion)
        }
    }
    
    func login(_ account: String, password: String, completion: ((ReturnCode) ->Void)?) {
        httpClientHelper.login(account, password: password) { (returnCode) in
            self.returnAction(returnCode, completion: completion)
        }
    }

    func logout() {
        IMManager.shared.disconnect()
        IMManager.shared.terminate()
        FriendManager.shared.clean()
        FileManager.default.removeCachePath()
        LTSDK.clean()
        UserInfo.delete()
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.resetApp()
        delegate.changeLoginVC()
    }
    
    private func returnAction(_ returnCode: ReturnCode, completion: ((ReturnCode) ->Void)?) {
        if returnCode == .success {
            initSDK { (success) in
                if success {
                    completion?(returnCode)
                } else {
                    completion?(.failed)
                }
            }
        } else {
            completion?(returnCode)
        }
    }
    
}
