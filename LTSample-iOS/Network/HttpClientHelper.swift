//
//  HttpClientHelper.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/16.
//

import Foundation

enum ReturnCode: Int {
    case success = 0
    case failed = -1
    case wrongPassword = 601
    case accountNotExist = 602
    case accountAlreadyExists = 603
    case requiresPassword = 604
}

class HttpClientHelper {
    
    private var accessToken: String = ""
    private var accessTokenTime: TimeInterval = 0
    
    func login(_ account: String, password: String, completion: @escaping (ReturnCode) ->Void) {
        
        guard let brandID = Config.brandID, brandID.count > 0,
              let ltsdkAPI = Config.ltsdkAPI, ltsdkAPI.count > 0 else {
            completion(.failed)
            return
        }
        
        if self.accessToken.count == 0 || NSDate().timeIntervalSince1970 > self.accessTokenTime {
            getAccountToken { (success) in
                if success {
                    self.login(account, password: password, completion: completion)
                } else {
                    completion(.failed)
                }
            }
        } else {
            let dict: [String: Encodable] = ["semiUID": account, "semiUID_PW": password]
            
            var request = URLRequest(endpoint: "oauth2/authenticate", domain: ltsdkAPI)
            request.httpMethod = "POST"
            request.setValue(brandID, forHTTPHeaderField: "Brand-Id")
            request.setHTTPBody(dict)
            request.setBearerTokenAuth(self.accessToken)
            
            NetworkService.request(request) { (jsonObject, statusCode, error) in
                DispatchQueue.main.async {
                    var returnCode: Int = 0
                    if statusCode == 200 {
                        if let dict = jsonObject as? [AnyHashable: Any], let code = dict["returnCode"] as? Int {
                            returnCode = code
                            if returnCode == 0 {
                                UserInfo.save(dict)
                            }
                        }
                    }
                    completion(ReturnCode(rawValue: returnCode) ?? ReturnCode.failed)
                }
            }
        }
    }
    
    func register(_ account: String, password: String, completion: @escaping (ReturnCode) ->Void) {
        
        guard let brandID = Config.brandID, brandID.count > 0,
              let ltsdkAPI = Config.ltsdkAPI, ltsdkAPI.count > 0 else {
            completion(.failed)
            return
        }
        
        if self.accessToken.count == 0 || NSDate().timeIntervalSince1970 > self.accessTokenTime {
            getAccountToken { (success) in
                if success {
                    self.register(account, password: password, completion: completion)
                }
            }
        } else {
            var dict: [String: Encodable] = [:]
            dict["verifyMode"] = "turnkey"
            dict["turnkey"] = Config.turnkey
            dict["users"] = [["semiUID": account, "semiUID_PW": password]]
            
            var request = URLRequest(endpoint: "oauth2/register", domain: ltsdkAPI)
            request.httpMethod = "POST"
            request.setValue(Config.brandID, forHTTPHeaderField: "Brand-Id")
            request.setHTTPBody(dict)
            request.setBearerTokenAuth(self.accessToken)
            
            NetworkService.request(request) { (jsonObject, statusCode, error) in
                DispatchQueue.main.async {
                    var returnCode: Int = 0
                    if statusCode == 200 {
                        if let dict = jsonObject as? [AnyHashable: Any] {
                            if let code = dict["returnCode"] as? Int, let users = dict ["users"] as? [[AnyHashable: Any]] {
                                returnCode = code
                                if returnCode == 0 {
                                   if users.count > 0 {
                                        UserInfo.save(users.first!)
                                   }
                                } else {
                                    if users.count > 0, let user = users.first, let error = user["err"] as? Int {
                                        returnCode = error
                                    }
                                }
                            }
                        }
                    }
                    
                    completion(ReturnCode(rawValue: returnCode) ?? ReturnCode.failed)
                }
            }
        }
    }
    
    private func getAccountToken(_ completion: @escaping (Bool) ->Void) {
        
        guard let brandID = Config.brandID, brandID.count > 0,
              let ltsdkAuthAPI = Config.ltsdkAuthAPI, ltsdkAuthAPI.count > 0,
              let developerAccount = Config.developerAccount, developerAccount.count > 0,
              let developerPassword = Config.developerPassword, developerPassword.count > 0 else {
            completion(false)
            return
        }
        
        var request = URLRequest(endpoint: "oauth2/getDeveloperToken", domain: ltsdkAuthAPI)
        request.httpMethod = "POST"
        request.setValue(Config.brandID, forHTTPHeaderField: "Brand-Id")
        request.setHTTPBody(["scope": "tw:api:sdk"])
        request.setBasicAuth(developerAccount, password: developerPassword)
        
        NetworkService.request(request) { (jsonObject, statusCode, error) in
            var success = false
            if statusCode == 200 {
                if let dict = jsonObject as? [AnyHashable: Any], let accessToken = dict["accessToken"] as? String {
                    self.accessToken = accessToken
                    self.accessTokenTime = NSDate().timeIntervalSince1970 + 3600
                    success = true
                }
            }
            
            completion(success)
        }
    }
}
