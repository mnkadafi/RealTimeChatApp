//
//  MainMessageViewModel.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 26/09/23.
//

import SwiftUI
import Firebase

class MainMessageViewModel: ObservableObject {
  @Published var chatUser: ChatUser?
  @Published var errorMessage: String = ""
  
  init() {    
    fetchCurrentUser()
  }
  
  func fetchCurrentUser() {
    guard let uid = Auth.auth().currentUser?.uid else {
      errorMessage = "Couldn't find firebase user id"
      return
    }
    errorMessage = "\(uid)"
    Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
      if let error = error {
        self.errorMessage = "Failed to fetch current user \(error)"
        print("Failed to fetch current user", error)
      }
      
      guard let data = snapshot?.data() else {
        self.errorMessage = "No data found."
        return
      }

      self.chatUser = .init(data: data)
    }
  }
}
