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
    @State var isMarked: Bool
    
    var body: some View {
        HStack {
            
            if self.data.fromUID == self.user.user?.uid {
                Spacer()
            }
            
            VStack(alignment: self.data.fromUID == self.user.user?.uid ? .trailing : .leading) {
                HStack {
                    if self.data.type[2] == "n" {
                        VStack {
                            Spacer()
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 9, height: 9)
                                .padding(.bottom, 10)
                        }
                    }
                    
                    VStack(alignment: self.data.fromUID == self.user.user?.uid ? .trailing : .leading) {
                        if self.data.fromUID != self.user.user?.uid {
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
                    .background(self.isMarked ? Color.purple : Color.blue)
                    .cornerRadius(10)
                }
                
                Text((self.data.type[1] == "a" ? "Added" : "Update") + " \(self.getDate(date: self.data.date))")
                .font(.system(size: 10))
                .multilineTextAlignment(self.data.fromUID == self.user.user?.uid ? .trailing : .leading)
                .padding(.all, 5.0)
            }
            
            if self.data.fromUID != self.user.user?.uid {
                Spacer()
            }
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

struct groupBubble: View {
    @EnvironmentObject var user: userProfile
    @ObservedObject var message: observer
    var name: String
    @State var text: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("\(self.name)")
                    .fontWeight(.bold)
                    .font(.system(size: 20))
                    .multilineTextAlignment(.leading)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
                Text("\(self.getTime(date: self.message.data.last?.date))")
                .multilineTextAlignment(.trailing)
                .font(.subheadline)
            }
            Spacer()
            HStack {
                Text("\(self.getUpdateText(message: self.message.data.last))")
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                Spacer()
                if self.message.news > 0 {
                    VStack {
                        Text("\(self.message.news)")
                            .fontWeight(.medium)
                            .font(.callout)
                            .padding(8)
                            .background(Color.blue)
                            .cornerRadius(40)
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
            }
        }
    }
    
    func getUpdateText(message: datatype?) -> String {
        if message == nil { return "" }
        
        let db = Firestore.firestore().collection("users").document("\(message!.fromUID)")
        db.getDocument { (doc, err) in
            if let document = doc, document.exists {
                let name = document.get("username") as! String
                if message!.type[0] == "0" {
                    if message!.msg.count > 50 {
                        self.text = name + ": " + String(message!.msg.prefix(50)) + "..."
                    } else {
                        self.text = name + ": " + message!.msg
                    }
                } else if message!.type[0] == "1" {
                    self.text = name + ": " + "Photo"
                }
            }
        }
        
        return self.text
    }
    
    func getTime(date: Date?) -> String {
        if date == nil { return "--:--"}
        let format = DateFormatter()
        var extraStr = ""
        switch Calendar.current.component(.day, from: date!) {
        case Calendar.current.component(.day, from: Date()):
            format.dateFormat = "HH:mm"
            extraStr = "today "
            break
        case Calendar.current.component(.day, from: Date()) - 1:
            format.dateFormat = "HH:mm"
            extraStr = "yesterday "
            break
        default:
            format.dateFormat = "dd-MM-yyyy"
        }
        return extraStr + format.string(from: date!)
    }
}
