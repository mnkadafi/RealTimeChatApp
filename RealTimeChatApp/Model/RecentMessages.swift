//
//  RecentMessages.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 28/09/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct RecentMessage: Identifiable, Codable {
  @DocumentID var id: String?
  let text, email: String
  let fromId, toId: String
  let profileImageUrl: String
  let timestamp: Date
}
