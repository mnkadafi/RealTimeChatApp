//
//  MainMessageViewModel.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 26/09/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class MainMessageViewModel: ObservableObject {
  @Published var chatUser: ChatUser?
//  @Published var selectedChatUser: ChatUser?
  @Published var recentMessages = [RecentMessage]()
  @Published var errorMessage: String = ""
  
  init() {
    fetchCurrentUser()
    fetchRecentMessages()
  }
  
  func fetchRecentMessages() {
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
          
          if let index = self.recentMessages.firstIndex(where: { rm in
            return rm.id == docId
          }) {
            self.recentMessages.remove(at: index)
          }
          
          do {
            let rm = try change.document.data(as: RecentMessage.self)
            self.recentMessages.insert(rm, at: 0)
          } catch {
            print(error)
          }
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
      
      do {
        let data = try snapshot?.data(as: ChatUser.self)
        self.chatUser = data
      } catch {
        print(error)
      }
    }
  }
  
  func resetData() {
    self.chatUser = nil
    self.recentMessages = [RecentMessage]()
    self.errorMessage = ""
  }
}
