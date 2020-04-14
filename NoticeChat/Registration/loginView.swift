//
//  loginView.swift
//  NoticeChat
//
//  Created by Mac on 22.01.2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import SwiftUI

struct loginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var error: String?
    @State var value : CGFloat = 0
    @EnvironmentObject var user: userProfile
    
    func signIn() {
        self.error = nil
        
        self.user.signIn(email: self.email, password: self.password) { (res, err) in
            if err != nil {
                self.error = "Wrong email or password"
                return
            }
            self.email = ""
            self.password = ""
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to NoticeChat!")
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20.0)
                
                if self.error != nil {
                    Text("\(self.error!)")
                    .font(.system(size: 20))
                    .lineLimit(nil)
                    .foregroundColor(Color.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20.0)
                }
                
                VStack(alignment: .center) {
                    TextField("Email address", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 10.0)
                        .cornerRadius(10)
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 10.0)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 10.0)
                
                Button(action: {
                    self.signIn()
                }){
                    Text("Enter")
                        .font(.system(size: 25))
                }
                
                HStack {
                    Text("Or you can register")
                    NavigationLink(destination: createAccountView()) {
                        Text("here")
                    }
                }
                
                Spacer()
                    .frame(height: self.value)
                
            }
            .animation(.spring())
            .onAppear(perform: {
                self.forKeyboard()
            })
        }
    }
    
    func forKeyboard() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
            let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            let height = value.height
            
            self.value = height - 20.0
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
            
            self.value = 0
        }
    }
}
