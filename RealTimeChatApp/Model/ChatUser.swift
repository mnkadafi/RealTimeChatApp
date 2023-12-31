//
//  ChatUser.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 28/09/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ChatUser: Identifiable, Codable {
  @DocumentID var id: String?
  let uid, email, profileImageUrl: String
}
