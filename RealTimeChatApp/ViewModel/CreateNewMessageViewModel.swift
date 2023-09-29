//
//  CreateNewMessageViewModel.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 28/09/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class CreateNewMessageViewModel: ObservableObject {
  @Published var users = [ChatUser]()
  @Published var errorMessage: String = ""
  @Published var selectedNewUserMessage: ChatUser?
  
  init() {
    fetchAllUsers()
  }
  
  func fetchAllUsers() {
    Firestore.firestore().collection("users")
      .whereField("uid", isNotEqualTo: Auth.auth().currentUser?.uid ?? "")
      .getDocuments { documentsSnapshot, error in
        if let error = error {
          self.errorMessage = "Failed to fetch all users \(error)"
          print("Failed to fetch all users", error)
          return
        }
        
        documentsSnapshot?.documents.forEach({ snapshot in
          do {
            let data = try snapshot.data(as: ChatUser.self)
            self.users.append(data)
          } catch {
            print(error)
          }
        })
      }
  }
}
