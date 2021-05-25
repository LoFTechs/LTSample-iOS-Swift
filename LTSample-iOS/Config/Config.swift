//
//  Config.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/19.
//

import Foundation

class Config {

    private static let config = Config.loadConfig()!
    private static func loadConfig() -> NSDictionary! {
        let path = Bundle.main.path(forResource: "Config", ofType: "plist") ?? ""
        let url = URL.init(fileURLWithPath: path, isDirectory: false)
        let userInfo = NSDictionary.init(contentsOf: url)
        return userInfo
    }
    
    class var brandID: String? {
        get {
            return config.object(forKey: "Brand_ID") as? String
        }
    }
    
    class var ltsdkAPI: String? {
        get {
            return config.object(forKey: "LTSDK_API") as? String
        }
    }
    
    class var ltsdkAuthAPI: String? {
        get {
            return config.object(forKey: "Auth_API") as? String
        }
    }
    
    class var turnkey: String? {
        get {
            return config.object(forKey: "LTSDK_TurnKey") as? String
        }
    }
    
    class var developerAccount: String? {
        get {
            return config.object(forKey: "Developer_Account") as? String
        }
    }
    
    class var developerPassword: String? {
        get {
            return config.object(forKey: "Developer_Password") as? String
        }
    }
    
    class var licenseKey: String? {
        get {
            return config.object(forKey: "License_Key") as? String
        }
    }
}
