//
//  ChatLogView.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 28/09/23.
//

import SwiftUI
import Firebase

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
        ForEach(chatLogViewModel.chatMessages) { message in
          VStack {
            if message.fromId == Auth.auth().currentUser?.uid {
              HStack {
                Spacer()
                
                HStack {
                  Text(message.text)
                    .foregroundColor(.white)
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(9)
              }
            } else {
              HStack {
                HStack {
                  Text(message.text)
                    .foregroundColor(.black)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(9)
                
                Spacer()
              }
            }
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

//struct ChatLogView_Previews: PreviewProvider {
//  static var previews: some View {
//    NavigationView {
//      ChatLogView(chatUser: .init(data: ["uid": "XLLX8EKfA8RN7f6kKoDb1YpXu002", "email": "kadafi@gmail.com"]))
//    }
//    MainMessageView()
//  }
//}
