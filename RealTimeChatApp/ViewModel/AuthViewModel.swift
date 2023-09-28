//
//  AuthViewModel.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 25/09/23.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class AuthViewModel: ObservableObject {
  @Published var loginStatusMessage: String = ""
  @Published var isUserCurrentlyLogOut: Bool = false
  
  init() {
    DispatchQueue.main.async {
      self.isUserCurrentlyLogOut = Auth.auth().currentUser?.uid == nil
    }
  }
  
  func createNewAccount(email: String, password: String, image: UIImage?) {
    if(email == "" && password == "" && image == nil) {
      print("Email, password and profile picture must not be empty")
      self.loginStatusMessage = "Email, password and profile picture must not be empty"
      return
    }
    
    guard let image = image else { return }
    
    Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
      if let error = error {
        print("Failed to create new Account. ", error)
        self.loginStatusMessage = "Failed to create new Account. \(error)"
        return
      }
      
      guard let user = authResult?.user else { return }

      print("Successfully created user: \(user.email ?? "")")
      self.loginStatusMessage = "Successfully created user: \(user.email ?? "")"
      self.persistImageToStorage(image: image)
    }
  }
  
  func signInAccount(email: String, password: String) {
    Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
      if let error = error {
        print("Failed to login user. ", error)
        self?.loginStatusMessage = "Failed to login user. \(error)"
        return
      }
      
      guard let user = authResult?.user else { return }
      
      print("Successfully logged in as user: \(user.email ?? "")")
      self?.loginStatusMessage = "Successfully logged in as user: \(user.email ?? "")"
      self?.isUserCurrentlyLogOut = false
    }
  }
  
  func persistImageToStorage(image: UIImage) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let ref = Storage.storage().reference(withPath: uid)
    guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
    ref.putData(imageData) { metadata, error in
      if let error = error {
        print("Failed to push image to Storage: ", error)
        self.loginStatusMessage = "Failed to push image to Storage: \(error)"
        return
      }
      
      ref.downloadURL { url, error in
        if let error = error {
          print("Failed to retrieve downloadUrl: ", error)
          self.loginStatusMessage = "Failed to retrieve downloadUrl: \(error)"
          return
        }
        
        guard let url = url else { return }
        print("Successfully storage image into Storage: \(url.absoluteString)")
        self.loginStatusMessage = "Successfully storage image into Storage: \(url.absoluteString)"
        self.storeUserInformation(imageProfileUrl: url)
      }
    }
  }
  
  func storeUserInformation(imageProfileUrl: URL) {
    guard let currentUser = Auth.auth().currentUser else { return }
    let userData = ["email": currentUser.email ?? "", "uid": currentUser.uid, "profileImageUrl": imageProfileUrl.absoluteString]
    Firestore.firestore().collection("users")
      .document(currentUser.uid)
      .setData(userData) { error in
        if let error = error {
          print("Failed to store user information: ", error)
          self.loginStatusMessage = "Failed to store user information: \(error)"
          return
        }
        
        print("Successfully store user information")
        self.loginStatusMessage = "Successfully store user information"
        self.isUserCurrentlyLogOut = false
      }
  }
  
  func handleSignOut() {
    try? Auth.auth().signOut()
    isUserCurrentlyLogOut.toggle()
  }
}
