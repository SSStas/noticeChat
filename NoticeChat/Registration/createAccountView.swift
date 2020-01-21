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
    @EnvironmentObject var user: userProfile
    @Environment(\.presentationMode) var presentationMode
    
    func signUp() {
        self.user.signUp(email: self.email, password: self.password) { (res, err) in
            if let error = err {
                print("*** LOCAL ERROR *** \n\((error.localizedDescription))")
                return
            }
            
            // create a new user on firestore
            let db = Firestore.firestore()
            let msg = db.collection("users").document(res!.user.uid)
            
            msg.setData(["username":self.username, "groups": []]) { (err) in
                if err != nil {
                    print("*** LOCAL ERROR *** \n\((err)!)")
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
                self.presentationMode.wrappedValue.dismiss()
                //self.user.setUser(login: self.login, email: self.email, password: self.password)
                self.signUp()
            }){
                Text("Sign in")
                    .font(.system(size: 20))
            }
        }
    }
}
