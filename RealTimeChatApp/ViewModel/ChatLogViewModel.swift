//
//  ChatLogViewModel.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 28/09/23.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatLogViewModel: ObservableObject {
  @Published var chatText: String = ""
  @Published var errorMessage: String = ""
  @Published var chatMessages = [ChatMessages]()
  @Published var count = 0
  
  let chatUser: ChatUser?
  
  init(chatUser: ChatUser?) {
    self.chatUser = chatUser
    fetchMessages()
  }
  
  private func fetchMessages() {
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
            let docId = change.document.documentID
            let data = change.document.data()
            self.chatMessages.append(.init(documentId: docId, data: data))
          }
        })
        
        DispatchQueue.main.async {
          self.count += 1
        }
      }
  }
  
  func handleSend() {
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
      self.chatText = ""
      self.count += 1
      print("Recipient saved message as well")
    }
  }
}
