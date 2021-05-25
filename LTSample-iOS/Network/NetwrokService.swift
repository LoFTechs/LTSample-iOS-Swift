//
//  NetwrokService.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/16.
//

import Foundation

class NetworkService {
    typealias URLSessionCompleteBlock = (Any?, Int, Error?) ->Void
    
    
    class func request(_ request : URLRequest, handler: @escaping URLSessionCompleteBlock) {
        let service = NetworkService()
        service.sync(request, handler: handler)
    }
    
    func sync(_ request: URLRequest, handler: URLSessionCompleteBlock?) {
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: nil)
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let completion = handler else {
                return
            }
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            var json: Any? = nil
            if let data = data {
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: [])
                } catch {
                    
                }
            }


            completion(json, status, error)
        })
        
        task.resume()
    }

}
