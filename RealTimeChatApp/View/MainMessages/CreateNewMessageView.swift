//
//  CreateNewMessageView.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 28/09/23.
//

import SwiftUI
import Kingfisher

struct CreateNewMessageView: View {
  @Environment(\.presentationMode) var presentationMode
  @ObservedObject var createNewMessageViewModel = CreateNewMessageViewModel()
  
  let didSelectNewUser: (ChatUser) -> ()
  
  var body: some View {
    NavigationView {
      ScrollView {
        ForEach(createNewMessageViewModel.users) { user in
          Button {
            presentationMode.wrappedValue.dismiss()
            createNewMessageViewModel.selectedNewUserMessage = user
            didSelectNewUser(user)
          } label: {
            HStack(spacing: 16) {
              KFImage(URL(string: user.profileImageUrl))
                .resizable()
                .setProcessor(ResizingImageProcessor(referenceSize: CGSize(width: 50 * UIScreen.main.scale, height: 50 * UIScreen.main.scale), mode: .aspectFit))
                .loadImmediately()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 5)
             
              Text(user.email)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(.label))
              
              Spacer()
            }
          }
          .padding(.horizontal)
          .padding(.vertical, 8)
          
          Divider()
        }
      }
      .navigationTitle("New Message")
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarLeading) {
          Button {
            presentationMode.wrappedValue.dismiss()
          } label: {
            Text("Cancel")
          }
        }
      }
    }
  }
}

//struct CreateNewMessageView_Previews: PreviewProvider {
//  static var previews: some View {
//    CreateNewMessageView(didSelectNewUser: { _ in
//
//    })
//    MainMessageView()
//  }
//}
