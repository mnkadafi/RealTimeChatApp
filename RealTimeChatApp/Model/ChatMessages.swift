//
//  ChatMessages.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 28/09/23.
//

import SwiftUI

struct FirebaseConstants {
  static let fromId = "fromId"
  static let toId = "toId"
  static let text = "text"
}

struct ChatMessages: Identifiable {
  var id: String { documentId }
  let documentId: String
  let fromId, toId, text: String
  
  init(documentId: String, data: [String: Any]) {
    self.documentId = documentId
    self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
    self.toId = data[FirebaseConstants.toId] as? String ?? ""
    self.text = data[FirebaseConstants.text] as? String ?? ""
  }
}
