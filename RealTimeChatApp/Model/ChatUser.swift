//
//  ChatUser.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 28/09/23.
//

import SwiftUI

struct ChatUser: Identifiable, Decodable {
  var id: String { uid }
  let uid, email, profileImageUrl: String
  
  init(data: [String: Any]) {
    self.uid = data["uid"] as? String ?? ""
    self.email = data["email"] as? String ?? ""
    self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
  }
}
