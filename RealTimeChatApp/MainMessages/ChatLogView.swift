//
//  ChatLogView.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 28/09/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class ChatLogViewModel: ObservableObject {
  @Published var chatText: String = ""
  @Published var errorMessage: String = ""
  let chatUser: ChatUser?
  
  init(chatUser: ChatUser?) {
    self.chatUser = chatUser
  }
  
  func handleSend() {
    guard let fromId = Auth.auth().currentUser?.uid else { return }
    guard let toId = chatUser?.uid else { return }
    
    let document = Firestore.firestore().collection("messages")
      .document(fromId)
      .collection(toId)
      .document()
    
    let messageData = ["from": fromId, "toId": toId, "text": chatText, "timestamp": Timestamp()] as [String: Any]
    
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
      print("Recipient saved message as well")
    }
  }
}

struct ChatLogView: View {
  @ObservedObject var chatLogViewModel: ChatLogViewModel
  let chatUser: ChatUser?
  
  init(chatUser: ChatUser?) {
    self.chatUser = chatUser
    self.chatLogViewModel = .init(chatUser: chatUser)
  }
  
  var body: some View {
    ZStack {
      messagesView
      
      VStack(spacing: 0) {
        Spacer()
        chatBottomBar
          .padding(.bottom, 28)
          .background(Color.white)
      }
      .edgesIgnoringSafeArea(.bottom)
    }
    .navigationTitle(chatUser?.email ?? "")
    .navigationBarTitleDisplayMode(.inline)
  }
  
  private var messagesView: some View {
    ScrollView {
      VStack {
        ForEach(0..<15) { num in
          HStack {
            Spacer()
            
            HStack {
              Text("FAKE MESSAGE \(num)")
                .foregroundColor(.white)
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(9)
          }
          .padding(.horizontal)
          .padding(.top, 8)
        }
      }
      .padding(.bottom, 50)
      
      HStack { Spacer() }
    }
    .background(Color(.init(white: 0.95, alpha: 1)))
  }
  
  private var chatBottomBar: some View {
    HStack(spacing: 16) {
      Image(systemName: "photo.on.rectangle")
        .font(.system(size: 24))
        .foregroundColor(Color(.darkGray))
      
      ZStack(alignment: .leading) {
        DescriptionPlaceholder()
        TextEditor(text: $chatLogViewModel.chatText)
          .autocorrectionDisabled(true)
          .opacity(chatLogViewModel.chatText.isEmpty ? 0.5 : 1)
      }
      .frame(height: 40)
      
      Button {
        chatLogViewModel.handleSend()
      } label: {
        Text("Send")
          .foregroundColor(.white)
      }
      .padding(.horizontal)
      .padding(.vertical, 8)
      .background(Color.blue)
      .cornerRadius(4)
    }
    .padding(.horizontal)
    .padding(.vertical, 8)
  }
}

private struct DescriptionPlaceholder: View {
  var body: some View {
    HStack {
      Text("Description")
        .foregroundColor(Color(.gray))
        .font(.system(size: 17))
        .padding(.leading, 5)
        .padding(.top, -4)
      
      Spacer()
    }
  }
}

struct ChatLogView_Previews: PreviewProvider {
  static var previews: some View {
//    NavigationView {
//      ChatLogView(chatUser: .init(data: ["uid": "XLLX8EKfA8RN7f6kKoDb1YpXu002", "email": "kadafi@gmail.com"]))
//    }
    MainMessageView()
  }
}
