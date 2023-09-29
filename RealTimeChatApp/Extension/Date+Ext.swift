//
//  String+Ext.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 28/09/23.
//

import SwiftUI

extension Date {
  func toDateString(withFormat format: String = "yyyy-MM-dd HH:mm:ss") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale(identifier: "id_ID")
    dateFormatter.timeZone = TimeZone(identifier: "Asia/Jakarta")
    let str = dateFormatter.string(from: self)
    
    return str
  }
}
