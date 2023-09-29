//
//  ChatLogViewModel.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 28/09/23.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class ChatLogViewModel: ObservableObject {
  @Published var chatText: String = ""
  @Published var errorMessage: String = ""
  @Published var chatMessages = [ChatMessages]()
  @Published var count = 0
  @Published var chatUser: ChatUser?
  @Published var currentUser: ChatUser?
  
  init(chatUser: ChatUser?) {
    self.chatUser = chatUser
    fetchCurrentUser()
    fetchMessages()
  }
  
  func fetchMessages() {
    guard let fromId = Auth.auth().currentUser?.uid else { return }
    guard let toId = chatUser?.uid else { return }
    
    Firestore.firestore().collection("messages")
      .document(fromId)
      .collection(toId)
      .order(by: "timestamp")
      .addSnapshotListener { querySnapshot, error in
        if let error = error {
          self.errorMessage = "Failed to listen for messages: \(error)"
          print("Failed to listen for messages: \(error)")
          return
        }
        
        querySnapshot?.documentChanges.forEach({ change in
          if change.type == .added {
            do {
              let cm = try change.document.data(as: ChatMessages.self)
              self.chatMessages.append(cm)
            } catch {
              print(error, "ERROR")
            }
          }
        })
        
        DispatchQueue.main.async {
          self.count += 1
        }
      }
  }
  
  func handleSend() {
    if self.chatText != "" {
      guard let fromId = Auth.auth().currentUser?.uid else { return }
      guard let toId = chatUser?.uid else { return }
      
      let document = Firestore.firestore().collection("messages")
        .document(fromId)
        .collection(toId)
        .document()
      
      let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: chatText, "timestamp": Timestamp()] as [String: Any]
      
      document.setData(messageData) { error in
        if let error = error {
          self.errorMessage = "Failed to save message into Firestore \(error)"
          print("Failed to save message into Firestore", error)
          return
        }
        
        self.errorMessage = "Successfully saved current user sending message"
        print("Successfully saved current user sending message")
        self.persistRecentMessage()
      }
      
      let recipientMessageDocument = Firestore.firestore().collection("messages")
        .document(toId)
        .collection(fromId)
        .document()
      
      recipientMessageDocument.setData(messageData) { error in
        if let error = error {
          self.errorMessage = "Failed to save message into Firestore \(error)"
          print("Failed to save message into Firestore", error)
          return
        }
        
        self.errorMessage = "Recipient saved message as well"
        self.count += 1
        self.chatText = ""
        print("Recipient saved message as well")
      }
    }
  }
  
  private func persistRecentMessage() {
    guard let chatUser = chatUser else { return }
    guard let senderUser = self.currentUser else {
      return
    }
    
    let senderRecentdocument = Firestore.firestore()
      .collection("recent_messages")
      .document(senderUser.uid)
      .collection("messages")
      .document(chatUser.uid)
    
    let senderData = [
      FirebaseConstants.timestamp: Timestamp(),
      FirebaseConstants.text: self.chatText,
      FirebaseConstants.fromId: senderUser.uid,
      FirebaseConstants.toId: chatUser.uid,
      FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
      FirebaseConstants.email: chatUser.email,
    ] as [String: Any]
    
    senderRecentdocument.setData(senderData) { error in
      if let error = error {
        self.errorMessage = "Failed to save to sender recent message \(error)"
        print("Failed to save to sender recent message", error)
        return
      }
    }
    
    let recipientData = [
      FirebaseConstants.timestamp: Timestamp(),
      FirebaseConstants.text: self.chatText,
      FirebaseConstants.fromId: senderUser.uid,
      FirebaseConstants.toId: chatUser.uid,
      FirebaseConstants.profileImageUrl: senderUser.profileImageUrl,
      FirebaseConstants.email: senderUser.email,
    ] as [String: Any]
    
    let recipientRecentdocument = Firestore.firestore()
      .collection("recent_messages")
      .document(chatUser.uid)
      .collection("messages")
      .document(senderUser.uid)
    
    recipientRecentdocument.setData(recipientData) { error in
      if let error = error {
        self.errorMessage = "Failed to save to recipient recent message \(error)"
        print("Failed to save to recipient recent message", error)
        return
      }
    }
    
    print("Successfully save recent message")
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
        self.currentUser = data
      } catch {
        print(error)
      }
    }
  }
  
  func resetData() {
    self.chatText = ""
    self.errorMessage = ""
    self.chatMessages = [ChatMessages]()
    self.count = 0
    self.chatUser = nil
  }
}
