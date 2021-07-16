//
//  AppDelegate.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/16.
//

import UIKit
import PushKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var rootVC: UIViewController?
    private var voipRegistry: PKPushRegistry?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupAPNS()
        setupSDK()
        
        _ = CallVC.shared
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if CallVC.shared.window == window || CallStatusBarVC.shared.window == window {
            return .portrait
        }
        
        return .all
    }
    
    func changeLoginVC() {
        rootVC = window?.rootViewController
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() as UIViewController? {
            window?.rootViewController = vc
        }
    }
    
    func changeMainVC() {
        if let vc = rootVC {
            window?.rootViewController = vc
        }
    }
    
    func resetApp() {
        window?.rootViewController = UIStoryboard( name: "Main", bundle: nil).instantiateInitialViewController()
    }
    
    //MARK: - Setup
    private func setupSDK() {
        SDKManager.shared.initSDK { (success) in
            if !success {
                self.changeLoginVC()
            }
        }
    }

    private func setupAPNS() {
        registerAPNS()
        registerPushKit()
    }

    private func registerAPNS() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
            DispatchQueue.main.async {
                if let err = error {
                    print("APNS request authorization fail: " + err.localizedDescription)
                } else {
                    if granted {
                        UIApplication.shared.registerForRemoteNotifications()
                        print("APNS request authorization succeeded!")
                    } else {
                        print("APNS request authorization is not granted!")
                    }
                }
            }
        }
    }

    private func registerPushKit() {
        voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry?.delegate = self
        voipRegistry?.desiredPushTypes = [.voIP]
    }
    
    //MARK -
    private func hexadecimalString(_ data: Data) -> String {
        return data.reduce("", {$0 + String(format: "%02X", $1)})
    }
    
    //MARK: - APNS
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let apnsToken = hexadecimalString(deviceToken)
        SDKManager.shared.updateApnsToken(apnsToken)
        print("ApnsToken = " + apnsToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Register APNS error!")
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let message = LTSDK.parsePushNotification(withNotify: response.notification.request.content.userInfo)
        let sender = message.displayName.count > 0 ? message.displayName : message.senderID
        let msgType: LTMessageType = LTMessageType(rawValue: message.msgType) ?? .unknown
        let content = AppUtility.getContent(msgType, content: message.msgContent)
        let apns = "\n receiver = " + message.receiver + "\n sender = " + sender + "\n content = " + content + "\n msgType = \(message.msgType)"
        AppUtility.alert("Click a apns." + apns)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .alert, .badge])
    }
}

extension AppDelegate: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("didInvalidatePushTokenForType")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let voipToken = hexadecimalString(pushCredentials.token)
        SDKManager.shared.updateVoipToken(voipToken)
        print("VoipToken = " + voipToken)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        if type == .voIP {
            CallManager.shared.parseIncomingPushWithNotify(payload.dictionaryPayload)
        }
        
        DispatchQueue.main.async {
            completion()
        }
    }
}

