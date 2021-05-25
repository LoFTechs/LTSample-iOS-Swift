//
//  Date+Format.swift
//  JK-iOS
//
//  Created by Ting Wei Zhang on 2021/3/7.
//

import Foundation

extension Date {
    static let formatter = DateFormatter()
    
    func dateFormat() -> String {//TODO:最近日期 hh:ss > 昨天 > 星期 > mm > yyy:mm
        
        Date.formatter.doesRelativeDateFormatting = true
        Date.formatter.locale = .current
        Date.formatter.timeZone = .current
        
        if Calendar.current.isDateInToday(self) {
            Date.formatter.dateStyle = .none
            Date.formatter.timeStyle = .short
        } else if Calendar.current.isDateInYesterday(self) {
            Date.formatter.dateStyle = .short
            Date.formatter.timeStyle = .none
        } else if Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear) {
            Date.formatter.dateFormat = "EEEE"
        } else {
            Date.formatter.dateStyle = .medium
            Date.formatter.timeStyle = .none
        }
        
        return Date.formatter.string(from: self)
    }
}
