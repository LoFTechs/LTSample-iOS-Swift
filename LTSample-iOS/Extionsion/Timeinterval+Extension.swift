//
//  Timeinterval+Extension.swift
//  LTSample-iOS
//
//  Created by Sheng-Tsang Uou on 2021/5/14.
//

import Foundation

extension TimeInterval {
    func zeroTimeInDay() -> TimeInterval {
        let gmt = Int(TimeZone.current.secondsFromGMT())
        let time = Int(self)
        let zeroTime = (((time + gmt) / 86400) * 86400) - gmt
        return TimeInterval(zeroTime)
    }
    
    func timeFormat() -> String {
        let time = NSDate.now.timeIntervalSince1970
        let offset = self - time
        if offset < 86400 * 2 {
            Date.formatter.dateStyle = .short
            Date.formatter.timeStyle = .none
        } else if offset < 86400 * 7 {
            Date.formatter.dateFormat = "EEEE"
        } else {
            Date.formatter.dateStyle = .medium
            Date.formatter.timeStyle = .none
        }
        
        return Date.formatter.string(from: Date(timeIntervalSince1970: self))
    }
}
