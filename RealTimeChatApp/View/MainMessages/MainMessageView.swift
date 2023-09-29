//
//  MainMessageView.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 26/09/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct MainMessageView: View {
  @ObservedObject private var authViewModel = AuthViewModel()
  @ObservedObject private var mainMessageViewModel = MainMessageViewModel()
  
  @State var shouldShowOptions: Bool = false
  @State var shouldShowNewMessagesScreen: Bool = false
  @State var shouldNavigateToLogChatView: Bool = false
  @State var selectedChatUser: ChatUser?
  
  var body: some View {
    NavigationView {
      VStack {
        customNavBar
        messageView
        
        NavigationLink("", isActive: $shouldNavigateToLogChatView) {
          ChatLogView(chatUser: selectedChatUser)
        }
      }
      .onAppear {
        if(!authViewModel.isUserCurrentlyLogOut && mainMessageViewModel.recentMessages.count == 0) {
          DispatchQueue.main.async {
            mainMessageViewModel.fetchRecentMessages()
          }
          print("HOREEEEE")
        }
      }
      .overlay(newMessageButton, alignment: .bottom)
      .navigationBarHidden(true)
    }
  }
  
  private var customNavBar: some View {
    HStack(spacing: 16) {
      WebImage(url: URL(string: mainMessageViewModel.chatUser?.profileImageUrl ?? ""))
        .resizable()
        .scaledToFill()
        .frame(width: 50, height: 50)
        .clipped()
        .cornerRadius(50)
        .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color(.label), lineWidth: 1))
        .shadow(radius: 5)
      
      VStack(alignment: .leading, spacing: 4) {
        let email = mainMessageViewModel.chatUser?.email.components(separatedBy: "@").first ?? ""
        Text(email)
          .font(.system(size: 24, weight: .bold))
        
        HStack {
          Circle()
            .foregroundColor(.green)
            .frame(width: 14, height: 14)
          
          Text("online")
            .font(.system(size: 14))
            .foregroundColor(Color(.lightGray))
        }
      }
      Spacer()
      Button {
        shouldShowOptions.toggle()
      } label: {
        Image(systemName: "gear")
          .font(.system(size: 24, weight: .bold))
          .foregroundColor(Color(.label))
      }

    }
    .padding()
    .actionSheet(isPresented: $shouldShowOptions) {
      .init(title: Text("Settings"), message: Text("Apa opsi yang ingin anda pilih?"), buttons: [
        .destructive(Text("Sign Out"), action: {
          print("handle sign out")
          authViewModel.handleSignOut()
          mainMessageViewModel.resetData()
        }),
        .cancel()
      ])
    }
    .fullScreenCover(isPresented: $authViewModel.isUserCurrentlyLogOut) {
      LoginView()
        .onDisappear {
          DispatchQueue.main.async {
            mainMessageViewModel.fetchCurrentUser()
            mainMessageViewModel.fetchRecentMessages()
          }
          print("HOREEEEE")
        }
      .environmentObject(authViewModel)
    }
  }
  
  private var messageView: some View {
    ScrollView {
      ForEach(mainMessageViewModel.recentMessages) { recentMessage in
        VStack {
          Button {
            let data = ChatUser(uid: mainMessageViewModel.chatUser?.uid == recentMessage.toId ? recentMessage.fromId : recentMessage.toId, email: recentMessage.email, profileImageUrl: recentMessage.profileImageUrl)
            self.selectedChatUser = data
            shouldNavigateToLogChatView.toggle()
          } label: {
            HStack(spacing: 16) {
              WebImage(url: URL(string: recentMessage.profileImageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipped()
                .cornerRadius(64)
                .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 5)
              
              VStack(alignment: .leading) {
                HStack {
                  Text(recentMessage.email)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(.label))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                  
                  Spacer()
                  
                  Text(recentMessage.timestamp.toDateString(withFormat: "HH:mm"))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(.label))
                }
                
                HStack {
                  Text(recentMessage.text)
                    .font(.system(size: 14))
                    .foregroundColor(Color(.lightGray))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                 
                  Spacer()
                  
                  Text("Jam")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(.label))
                    .opacity(0)
                }
              }
            }
          }
          
          Divider()
            .padding(.vertical, 8)
        }
        .padding(.horizontal)
      }
    }
    .padding(.bottom, 50)
  }
  
  private var newMessageButton: some View {
    Button {
      shouldShowNewMessagesScreen.toggle()
    } label: {
      HStack {
        Spacer()
        Text("+ New Messages")
          .font(.system(size: 14, weight: .bold))
        Spacer()
      }
      .foregroundColor(.white)
      .padding(.vertical)
      .background(Color.blue)
      .cornerRadius(24)
      .padding(.horizontal)
      .shadow(radius: 15)
    }
    .fullScreenCover(isPresented: $shouldShowNewMessagesScreen) {
      CreateNewMessageView(didSelectNewUser: { user in
        self.shouldNavigateToLogChatView.toggle()
        self.selectedChatUser = user
      })
    }
  }
}

//struct MainMessageView_Previews: PreviewProvider {
//  static var previews: some View {
//    MainMessageView()
//  }
//}

//public class MainMessageRouter {
//  @ObservedObject var mainMessageViewModel: MainMessageViewModel
//
//  init(_ mainMessageViewModel: MainMessageViewModel) {
//    self.mainMessageViewModel = mainMessageViewModel
//  }
//
//  func linkBuilder<Content: View>(for recentMessage: RecentMessage, @ViewBuilder content: () -> Content) -> some View {
//    NavigationLink(
//      destination: self.makeDetailView(for: recentMessage)) {
//      content()
//    }
//  }
//
//  func makeDetailView(for recentMessage: RecentMessage) -> some View {
//    var selectedUser: ChatUser?
//
//    mainMessageViewModel.fetchSelectedUser(selectedRecentMessage: recentMessage) { chatUser in
//      selectedUser = chatUser
//      print(chatUser)
//    }
//
//    print(selectedUser, "ASAS")
//
//    return ChatLogView(chatUser: selectedUser)
//  }
//}
