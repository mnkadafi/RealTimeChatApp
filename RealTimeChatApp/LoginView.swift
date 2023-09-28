//
//  LoginView.swift
//  RealTimeChatApp
//
//  Created by Mochamad Nurkhayal Kadafi on 25/09/23.
//

import SwiftUI

struct LoginView: View {
  @EnvironmentObject var authViewModel: AuthViewModel

  @State private var isLoginMode: Bool = true
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var shouldShowImagePicker: Bool = false
  @State private var selectedImage: UIImage?
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 16) {
          Picker(selection: $isLoginMode) {
            Text("Login")
              .tag(true)
            Text("Create Account")
              .tag(false)
          } label: {
            Text("Picker Here")
          }
          .pickerStyle(SegmentedPickerStyle())
          
          if !isLoginMode {
            Button {
              shouldShowImagePicker.toggle()
            } label: {
              VStack {
                if let image = selectedImage {
                  Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 128, height: 128)
                    .cornerRadius(64)
                } else {
                  Image(systemName: "person.fill")
                    .font(.system(size: 64))
                    .padding()
                    .foregroundColor(Color(.label))
                }
              }
              .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color.black, lineWidth: 3))
            }
          }
          
          Group {
            TextField("Email", text: $email)
              .keyboardType(.emailAddress)
              .autocapitalization(.none)
            
            SecureField("Password", text: $password)
          }
          .padding(12)
          .background(Color.white)
          
          Button {
            handleAction()
          } label: {
            HStack {
              Spacer()
              Text(isLoginMode ? "Login" : "Create Account")
                .foregroundColor(Color.white)
                .padding(.vertical, 12)
                .font(.system(size: 14, weight: .semibold))
              Spacer()
            }
            .background(Color.blue)
            .cornerRadius(6)
          }
          
          Text(authViewModel.loginStatusMessage)
            .foregroundColor(.red)
        }
        .padding()
      }
      .navigationTitle(isLoginMode ? "Login" : "Create Account")
      .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
    }
    .navigationViewStyle(StackNavigationViewStyle())
    .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
      ImagePicker(image: $selectedImage)
    }
  }
  
  private func handleAction() {
    if isLoginMode {
      authViewModel.signInAccount(email: email, password: password)
    } else {
      authViewModel.createNewAccount(email: email, password: password, image: selectedImage)
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
      .environmentObject(AuthViewModel())
  }
}
