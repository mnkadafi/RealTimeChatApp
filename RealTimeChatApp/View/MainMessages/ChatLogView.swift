//
//  ChatLogView.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 28/09/23.
//

import SwiftUI

struct ChatLogView: View {
  @ObservedObject var chatLogViewModel: ChatLogViewModel
  @State var value: CGFloat = 0
  
  let selectedChatUser: ChatUser?
  let emptyScrollToString = "Empty"
  
  init(chatUser: ChatUser?) {
    self.selectedChatUser = chatUser
    self.chatLogViewModel = .init(chatUser: chatUser)
  }
  
  var body: some View {
    ZStack {
      messagesView
      
      VStack(spacing: 0) {
        Spacer()
        chatBottomBar
          .padding(.bottom, self.value == 0 ? 28 : 0)
          .background(Color.white)
      }
      .offset(y: -self.value)
      .animation(.spring())
      .onAppear {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notif in
          let value = notif.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
          let height = value.height
          
          self.value = height-32
        }
      }
      .edgesIgnoringSafeArea(.bottom)
    }
    .navigationTitle(selectedChatUser?.email ?? "")
    .navigationBarTitleDisplayMode(.inline)
  }
  
  private var messagesView: some View {
    ScrollView {
      ScrollViewReader { scrollViewProxy in
        VStack {
          VStack {
            ForEach(chatLogViewModel.chatMessages) { message in
              MessageView(message: message)
            }
          }
          .padding(.bottom, 50)
          
          HStack { Spacer() }
            .id(emptyScrollToString)
        }
        .onReceive(chatLogViewModel.$count) { _ in
          withAnimation(.easeOut(duration: 0.5)) {
            scrollViewProxy.scrollTo(emptyScrollToString, anchor: .bottom)
          }
        }
      }
    }
    .background(Color(.init(white: 0.95, alpha: 1)))
    .onTapGesture {
      self.dismissKeyboard()
    }
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
      .background(Color(.init(white: 0.95, alpha: 1)))
      .frame(height: 40)
      
      Button {
        self.dismissKeyboard()
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
  
  private func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    self.value = 0
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
