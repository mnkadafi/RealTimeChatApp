//
//  ChatMessages.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 28/09/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct FirebaseConstants {
  static let fromId = "fromId"
  static let toId = "toId"
  static let text = "text"
  static let timestamp = "timestamp"
  static let profileImageUrl = "profileImageUrl"
  static let email = "email"
}

struct ChatMessages: Identifiable, Codable {
  @DocumentID var id: String?
  let fromId, toId, text: String
}
