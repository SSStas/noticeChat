//
//  userProfile.swift
//  NoticeChat
//
//  Created by Mac on 10.01.2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseAuth
import Combine

class userProfile: ObservableObject {
    var didChange = PassthroughSubject<userProfile, Never>()
    @Published var user: User?  {
        didSet {
            self.didChange.send(self)
        }
    }
    var handle: AuthStateDidChangeListenerHandle?
    
    func listen() {
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
                let userID = user.uid
                let db = Firestore.firestore().collection("users").document(userID)
                db.getDocument { (snap, err) in
                    if err != nil {
                        self.user = nil
                        print("*** LOCAL ERROR *** \n\(err!.localizedDescription)")
                        return
                    }
                    // Get user value
                    if let doc = snap {
                        self.user = User(uid: user.uid, email: user.email, username: doc.get("username") as? String ?? "")
                    } else {
                        self.user = nil
                        print("Document does not exist")
                    }
                }
                
            } else {
                self.user = nil
            }
        })
    }
    
    func signUp(email: String, password: String, handler: @escaping AuthDataResultCallback) {
        Auth.auth().createUser(withEmail: email, password: password, completion: handler)
    }
    
    func signIn(email: String, password: String, handler: @escaping AuthDataResultCallback) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            print("Error signing")
        }
    }
    
    func unbind() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    deinit {
        unbind()
    }
}

struct User {
    var uid: String
    var username: String
    var email: String?
    
    init(uid: String, email: String?, username: String) {
        self.uid = uid
        self.email = email
        self.username = username
    }
}
