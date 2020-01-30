//
//  chatBubbles.swift
//  NoticeChat
//
//  Created by Mac on 22.01.2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import SwiftUI
import FirebaseFirestore

struct textBubble: View {
    @EnvironmentObject var user: userProfile
    @State var data: datatype
    @State var name: String = "§ User does not found"
    
    var body: some View {
        HStack {
            
            if self.data.fromUID == self.user.user?.uid {
                Spacer()
            }
            
            VStack(alignment: self.getPos()) {
                VStack(alignment: self.getPos()) {
                    if self.data.fromUID != self.user.user?.uid{
                        Text("\(self.getUsername(uid: self.data.fromUID))")
                            .font(.system(size: 12))
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.leading)
                            .padding([.top, .leading, .trailing], 5.0)
                    }
                        
                    Text(self.data.msg)
                        .font(.system(size: 22))
                        .foregroundColor(Color.white)
                        .padding(.all, 7.0)
                }
                .background(Color.blue)
                .cornerRadius(10)
                
                Text("Added \(self.getDate(date: self.data.date))")
                .font(.system(size: 10))
                .multilineTextAlignment(self.getPosText())
                    .padding(.all, 5.0)
            }
            
            if self.data.fromUID != self.user.user?.uid {
                Spacer()
            }
        }
    }
    
    func getPosText() -> TextAlignment {
        if self.data.fromUID == self.user.user?.uid {
            return .trailing
        } else {
            return .leading
        }
    }
    
    func getPos() -> HorizontalAlignment {
        if self.data.fromUID == self.user.user?.uid {
            return .trailing
        } else {
            return .leading
        }
    }
    
    func getUsername(uid: String) -> String {
        let db = Firestore.firestore().collection("users").document("\(uid)")
        db.getDocument() { (doc, err) in
            if let document = doc, document.exists {
                self.name = document.get("username") as! String
            }
        }
        return self.name
    }

    
    func getDate(date: Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "dd-MM-yyyy HH:mm:ss"
        return format.string(from: date)
    }
}

