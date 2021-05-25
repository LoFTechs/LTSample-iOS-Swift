//
//  Protocol.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/4/29.
//

import Foundation

protocol LTProtocol: AnyObject {
    var className: AnyClass { get }
}

class DelegatesObject {
    var delegateArray = [LTProtocol]()
    func addDelegate<T: LTProtocol>(_ object: T) {
        if let _ = delegateArray.firstIndex(where: { $0.className == object.className } ) {
            return
        }
        delegateArray.append(object)
    }
    
    func removeDelegate<T: LTProtocol>(_ object: T) {
        if let index = delegateArray.firstIndex(where: { $0.className === object.className }) {
            delegateArray.remove(at: index)
        }
    }
}
