//
//  MessageView.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 28/09/23.
//

import SwiftUI
import Firebase

struct MessageView: View {
  let message: ChatMessages
  
  var body: some View {
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
