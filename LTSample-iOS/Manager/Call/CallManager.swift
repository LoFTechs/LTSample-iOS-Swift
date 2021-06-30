//
//  CallManager.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/19.
//

import Foundation
import AVFoundation

protocol CallManagerDelegate: LTCallDelegate {
    func startOutgointCall(_ call: LTCall?, callName: String)
    func receiveIncomingCall(_ call: LTCall?, callName: String)
    func getCall() -> LTCall?
}

protocol CallLogDelegate: LTCallDelegate {
    func getCallLogs(_ cdrs: [LTCallCDRNotificationMessage])
}

class CallManager: NSObject {
    
    static let shared = CallManager()
    
    var callLogDelegate: CallLogDelegate?
    
    func initSDK() {
        //LTCallManager
        LTSDK.getCallCenterManager()?.delegate = self
        
        //CallKit
        var name = "SampleApp"
        if let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            name = displayName
        }
        LTCallKitProxy.sharedInstance().configureProvider(withLocalizedName: name, ringtoneSound: "", iconTemplateImage: UIImage(named: "appIcon")!)
        
    }
  
    func queryCDR(markTS: Double, afterN: Int) {
        
        guard let callCenterManager = LTSDK.getCallCenterManager() else {
            return
        }
        
        callCenterManager.queryCDR(withUserID: UserInfo.userID, markTS: Int(markTS), afterN: Int32(afterN)) { (response) in
            if response.returnCode == LTReturnCode.success {
                DispatchQueue.main.async {
                    self.callLogDelegate?.getCallLogs(response.cdrMessages)
                }
            } else {
                print("queryCDR %@", response.returnCode);
            }
        }
    }
    
    //MARK: - Call
    func startCall(accountID: String, callMode: LTCallMode = LTCallMode.voice) {
        LTSDK.getUserStatus(withSemiUIDs: [accountID]) { (rp, userStatuses) in
            if rp.returnCode == .success, let userStatus = userStatuses?.first {
                if userStatus.userID.count > 0, userStatus.canVOIP {
                    self.startCall(userID: userStatus.userID, name: accountID, callMode: callMode)
                } else {
                    print("The accountID is not a user.." )
                }
            }
        }
    }
    
    func startCall(userID: String, name: String = "", callMode: LTCallMode = LTCallMode.voice) {
        checkMicrophonePrivacy {
            if $0 {
                DispatchQueue.main.async {
                    let options = LTCallOptions.initWithUserIDBuilder { (builder) in
                        builder.userID = userID
                        builder.callMode = callMode
                    }
                    
                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    let vc = appdelegate.callRouter(callMode: callMode)
                    
                    if let call = LTSDK.getCallCenterManager()?.startCall(withUserID: UserInfo.userID, options: options, setDelegate: vc) {
                        
                        let callHandle = CXHandle.init(type: .generic, value: options.callID ?? name)
                        let callkitUpdate = CXCallUpdate()
                        callkitUpdate.remoteHandle = callHandle
                        callkitUpdate.localizedCallerName = name
                        callkitUpdate.hasVideo = (callMode == LTCallMode.video)
                        
                        LTCallKitProxy.sharedInstance().startOutgoingCall(call, update: callkitUpdate)
                        
                        vc.startOutgointCall(call, callName: name)
                    }
                }
            }
        }
    }
    
    //MARK: - Public Function
    func parseIncomingPushWithNotify(_ payload: [AnyHashable: Any]) {
        LTSDK.parseIncomingPush(withNotify: payload)

    }

    func checkMicrophonePrivacy(_ finished: ((Bool) -> Void)? = nil) {
        
        let privacyTitle = "APP needs access to your phone's microphone"
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            finished?(true)
        case .denied:
            finished?(false)
            showSettingsPrivacy(title: privacyTitle)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                DispatchQueue.main.async {
                    if granted {
                        finished?(true)
                    } else {
                        finished?(false)
                        self.showSettingsPrivacy(title: privacyTitle)
                    }
                }
            })
        @unknown default:
            fatalError()
        }
    }
    
    func checkCameraPrivacy(_ finished: ((Bool) -> Void)? = nil) {
        let mediaType = AVMediaType.video
        let privacyTitle = "APP needs access to your phone's camera"
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            finished?(true)
        case .denied:
            finished?(false)
            showSettingsPrivacy(title: privacyTitle)
        case .restricted:
            finished?(false)
            showSettingsPrivacy(title: privacyTitle)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType) { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        finished?(true)
                    } else {
                        finished?(false)
                        self.showSettingsPrivacy(title: privacyTitle)
                    }
                }
            }
        @unknown default:
            fatalError()
        }
    }
    
    func showSettingsPrivacy(title: String) {//
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Settings", style: .default) { _ in
            UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(action)
        alert.addAction(cancel)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

extension CallManager: LTCallCenterDelegate {
    
    func ltCallNotification(_ notificationMessage: LTCallNotificationMessage) {
        var callName = "Unknown user"
        if notificationMessage.callerInfo.semiUID.count > 0 {
            callName = ProfileManager.shared.getUserNickname(notificationMessage.callerInfo.userID) ?? notificationMessage.callerInfo.semiUID
        }
        
        let callkitUpdate = CXCallUpdate()
        callkitUpdate.remoteHandle = CXHandle.init(type: .generic, value: notificationMessage.callOptions?.callID ?? callName)
        callkitUpdate.localizedCallerName = callName
        callkitUpdate.hasVideo = (notificationMessage.callOptions?.callMode == LTCallMode.video)
                
        LTCallKitProxy.sharedInstance().startIncomingCall(with: callkitUpdate) { (error, callUUID) -> LTCallKitDelegate? in
            var callkitDelegate: LTCallKitDelegate? = nil
            if error == nil, let callOptions = notificationMessage.callOptions {
                
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                let vc = appdelegate.callRouter(callMode: callOptions.callMode)
                
                if let call = LTSDK.getCallCenterManager()?.startCall(with: notificationMessage, setDelegate: vc) {
                    if vc.getCall() != nil {
                        call.busyCall()
                    } else {
                        callkitDelegate = call
                        vc.receiveIncomingCall(call, callName: callName)
                    }
                }
            }
            return callkitDelegate
        }
    }
    
    func ltCallCDRNotification(_ notificationMessage: LTCallCDRNotificationMessage) {
        self.callLogDelegate?.getCallLogs([notificationMessage])
    }
    
}
