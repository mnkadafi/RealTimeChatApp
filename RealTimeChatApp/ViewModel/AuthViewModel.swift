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
  @Published var isLoading: Bool = false
  @Published var loginStatusMessage: String = ""
  @Published var isUserCurrentlyLogOut: Bool = false
  
  init() {
    DispatchQueue.main.async {
      self.isUserCurrentlyLogOut = Auth.auth().currentUser?.uid == nil
    }
  }
  
  func createNewAccount(email: String, password: String, image: UIImage?) {
    isLoading = true
    
    if(email == "" || password == "" || image == nil) {
      print("Email, password and profile picture must not be empty")
      self.loginStatusMessage = "Email, password and profile picture must not be empty"
      self.isLoading = false
      return
    }
    
    guard let image = image else {
      self.isLoading = false
      return
    }
    
    Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
      if let error = error {
        print("Failed to create a new Account. ", error)
        self.loginStatusMessage = "Failed to create a new Account. Please fill in the email correctly"
        self.isLoading = false
        return
      }
      
      guard let user = authResult?.user else { return }

      print("Successfully created user: \(user.email ?? "")")
      self.persistImageToStorage(image: image)
      self.isLoading = false
    }
  }
  
  func signInAccount(email: String, password: String) {
    isLoading = true
    
    Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
      if let error = error {
        print("Failed to login user. ", error)
        self?.loginStatusMessage = "Failed to login user. Please try again with the correct email and password."
        self?.isLoading = false
        return
      }
      
      guard let user = authResult?.user else { return }
      
      print("Successfully logged in as user: \(user.email ?? "")")
      self?.isLoading = false
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
        self.loginStatusMessage = "Failed to push image to Storage."
        self.isLoading = false
        return
      }
      
      ref.downloadURL { url, error in
        if let error = error {
          print("Failed to retrieve downloadUrl: ", error)
          self.isLoading = false
          return
        }
        
        guard let url = url else { return }
        print("Successfully storage image into Storage: \(url.absoluteString)")
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
          self.isLoading = false
          return
        }
        
        print("Successfully store user information")
        self.loginStatusMessage = "Successfully store user information"
        self.isUserCurrentlyLogOut = false
        self.isLoading = false
      }
  }
  
  func handleSignOut() {
    try? Auth.auth().signOut()
    isUserCurrentlyLogOut.toggle()
  }
}
