//
//  UIWindowSegue.swift
//  SwiftSample
//
//  Created by Sheng-Tsang Uou on 2020/12/16.
//

import UIKit

class UIWindowSegue: UIStoryboardSegue {
    override func perform() {
        let app = UIApplication.shared.delegate as! AppDelegate
        app.window?.rootViewController = destination
    }
}
