//
//  createAccountView.swift
//  NoticeChat
//
//  Created by Mac on 18.01.2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import SwiftUI
import FirebaseFirestore

struct createAccountView: View {
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var error: String?
    @State var value : CGFloat = 0
    @EnvironmentObject var user: userProfile
    @Environment(\.presentationMode) var presentationMode
    
    func signUp() {
        self.error = nil
        
        self.user.signUp(email: self.email, password: self.password) { (res, err) in
            if let error = err {
                self.error = "\(error.localizedDescription)"
                return
            }
            
            // create a new user on firestore
            let db = Firestore.firestore()
            let msg = db.collection("users").document(res!.user.uid)
            
            msg.setData(["username":self.username]) { (err) in
                if err != nil {
                    self.error = "\(err!.localizedDescription)"
                    return
                }
            }
            
            self.username = ""
            self.email = ""
            self.password = ""
        }
    }
    
    var body: some View {
        VStack {
            Text("Join in NoticeChat!")
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
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 10.0)
                    .cornerRadius(10)
                TextField("Email", text: $email)
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
                self.signUp()
            }){
                Text("Sign in")
                    .font(.system(size: 25))
            }
            
            Spacer()
                .frame(height: self.value)
            
        }
        .animation(.spring())
        .onAppear(perform: {
            self.forKeyboard()
        })
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
