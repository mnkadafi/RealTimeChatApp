//
//  MainMessageViewModel.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 26/09/23.
//

import SwiftUI
import Firebase

struct RecentMessage: Identifiable {
  var id: String { documentId }
  let documentId: String
  let text, fromId, toId: String
  let email, profileImageUrl: String
  let timestamp: Timestamp
  
  init(documentId: String, data: [String: Any]) {
    self.documentId = documentId
    self.text = data[FirebaseConstants.text] as? String ?? ""
    self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
    self.toId = data[FirebaseConstants.toId] as? String ?? ""
    self.email = data[FirebaseConstants.email] as? String ?? ""
    self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
    self.timestamp = data[FirebaseConstants.timestamp] as? Timestamp ?? Timestamp(date: Date())
  }
}

class MainMessageViewModel: ObservableObject {
  @Published var chatUser: ChatUser?
  @Published var recentMessages = [RecentMessage]()
  @Published var errorMessage: String = ""
  
  init() {
    fetchCurrentUser()
    fetchRecentMessages()
  }
  
  private func fetchRecentMessages() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    Firestore.firestore()
      .collection("recent_messages")
      .document(uid)
      .collection("messages")
      .order(by: "timestamp")
      .addSnapshotListener { querySnapshot, error in
        if let error = error {
          self.errorMessage = "Failed to listen for recent messages: \(error)"
          print("Failed to listen for recent messages: \(error)")
          return
        }
        
        querySnapshot?.documentChanges.forEach({ change in
          let docId = change.document.documentID
          let data = change.document.data()
          
          if let index = self.recentMessages.firstIndex(where: { rm in
            return rm.documentId == docId
          }) {
            self.recentMessages.remove(at: index)
          }
          
          self.recentMessages.insert(.init(documentId: docId, data: data), at: 0)
        })
      }
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
