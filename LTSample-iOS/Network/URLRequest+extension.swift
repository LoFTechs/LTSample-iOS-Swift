//
//  URLRequest+extension.swift
//  JK-iOS
//
//  Created by shanezhang on 2021/4/9.
//

import Foundation

extension URLRequest {

    init(endpoint: String, domain: String) {        
        let url = String(domain.suffix(1)) == "/" ? URL.init(string: domain + endpoint) : URL.init(string: domain + "/" + endpoint)
        self.init(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10)
    }
    
    mutating func setBasicAuth(_ username: String, password: String) {
        let authStr = "\(username):\(password)"
        let authData = authStr.data(using: String.Encoding.ascii)
        
        if let base64Encoded = authData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) {
            let authValue = "Basic \(base64Encoded)"
            setValue(authValue, forHTTPHeaderField: "Authorization")
        }
    }
    
    mutating func setHTTPBody(_ reguestObject: [String: Any]) {
        
        if !JSONSerialization.isValidJSONObject(reguestObject) {
            print("is not a valid json object")
        }
        
        let data = try? JSONSerialization.data(withJSONObject: reguestObject, options: [])
        setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        httpBody = data
    }
    
    mutating func setBearerTokenAuth(_ accessToken: String) {
        let bearer = "Bearer " + accessToken
        setValue(bearer, forHTTPHeaderField: "Authorization")
    }
}
