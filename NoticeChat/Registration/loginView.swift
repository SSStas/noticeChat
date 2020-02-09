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
    @EnvironmentObject var user: userProfile
    
    func signIn() {
        self.user.signIn(email: self.email, password: self.password) { (res, err) in
            if let error = err {
                print("*** LOCAL ERROR *** \n\((error.localizedDescription))")
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
                        .font(.system(size: 20))
                }
                
                HStack {
                    Text("Or you can register")
                    NavigationLink(destination: createAccountView()) {
                        Text("here")
                    }
                }
                
            }
        }
    }
}

struct loginView_Previews: PreviewProvider {
    static var previews: some View {
        loginView()
    }
}
