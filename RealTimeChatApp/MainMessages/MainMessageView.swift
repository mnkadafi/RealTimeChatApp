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
  @State var chatUser: ChatUser?
  
  var body: some View {
    NavigationView {
      VStack {
        customNavBar
        messageView
        
        NavigationLink("", isActive: $shouldNavigateToLogChatView) {
          ChatLogView(chatUser: chatUser)
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
        }),
        .cancel()
      ])
    }
    .fullScreenCover(isPresented: $authViewModel.isUserCurrentlyLogOut) {
      LoginView()
        .onDisappear {
          mainMessageViewModel.fetchCurrentUser()
        }
      .environmentObject(authViewModel)
    }
  }
  
  private var messageView: some View {
    ScrollView {
      ForEach(mainMessageViewModel.recentMessages) { recentMessage in
        VStack {
          NavigationLink {
            Text("DESTINASI")
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
                Text(recentMessage.email)
                  .font(.system(size: 16, weight: .bold))
                  .foregroundColor(Color(.label))
                
                Text(recentMessage.text)
                  .font(.system(size: 14))
                  .foregroundColor(Color(.lightGray))
                  .multilineTextAlignment(.leading)
                  .lineLimit(2)
              }
              
              Spacer()
              
              Text("22d")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.label))
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
        self.chatUser = user
      })
    }
  }
}

struct MainMessageView_Previews: PreviewProvider {
  static var previews: some View {
//    MainMessageView()
//      .preferredColorScheme(.dark)
    
    MainMessageView()
  }
}
