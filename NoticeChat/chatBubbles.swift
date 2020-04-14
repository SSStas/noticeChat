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
    @ObservedObject var data: datatype
    @Binding var groupID: String
    @State var isMarked: Bool
    @State var name: String = "§ User does not found"
    
    var body: some View {
        HStack {
            
            if self.data.fromUID == self.user.user?.uid {
                Spacer()
            }
            
            VStack(alignment: self.data.fromUID == self.user.user?.uid ? .trailing : .leading) {
                HStack {
                    if self.data.type[1] == "n" && self.user.user != nil && self.user.user!.uid == self.data.fromUID {
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
                
                Text((self.data.type[1] != "u" ? "Added" : "Update") + " \(self.getDate(date: self.data.date))")
                .font(.system(size: 10))
                .multilineTextAlignment(self.data.fromUID == self.user.user?.uid ? .trailing : .leading)
                .padding(.all, 5.0)
            }
            
            if self.data.fromUID != self.user.user?.uid {
                Spacer()
            }
        }
        //.padding(.horizontal)
        .padding(.vertical, 3.0)
        .onAppear(perform: {
            if self.data.type[1] == "n" && self.user.user != nil && self.user.user!.uid != self.data.fromUID {
                let db =  Firestore.firestore().collection("\(self.groupID)").document(self.data.id)
                db.updateData([
                    "type": self.data.type[0] + "a",
                ]) { err in
                    if err != nil {
                        print("*** LOCAL ERROR *** \n\((err?.localizedDescription)!)")
                        return
                    }
                }
                self.data.type = self.data.type[0] + "a"
            }
        })
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
                Text("\(self.getTime(date: self.message.data.first?.date))")
                .multilineTextAlignment(.trailing)
                .font(.subheadline)
            }
            Spacer()
            HStack {
                Text("\(self.getUpdateText(message: self.message.data.first))")
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
                let name = message!.fromUID == self.user.user?.uid ? "Ты" : document.get("username") as! String
                if message!.type[0] == "m" {
                    if message!.msg.count > 50 {
                        self.text = name + ": " + String(message!.msg.prefix(50)) + "..."
                    } else {
                        self.text = name + ": " + message!.msg
                    }
                } else if message!.type[0] == "i" {
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


struct CustomActionSheet : View {
    
    @Binding var toUID: String?
    @State var toUsername: String?
    @State var groupID: String
    @State var author: String
    @State var usernamesList = [usersNames]()
    
    var body : some View {
        
        VStack {
            Text("Send to a specific person")
                .font(.title)
                .padding()
            Text("Choosed now: \(self.toUID != nil ? self.toUsername ?? "§ User does not found" : "Everyone")")
                .font(.body)
            if self.usernamesList.count > 0 {
                List(self.usernamesList) { uid in
                    Button(action: {
                        self.toUID = uid.id
                        self.toUsername = uid.username
                    }) {
                        Text(uid.username)
                    }
                }
            } else {
                Spacer()
                Text("You haven't no one to send message in this group!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            }
            Button(action: {
                self.toUID = nil
                self.toUsername = "Everyone"
            }) {
                Text("Send to all")
            }
            .padding()
        }
        .onAppear(perform: {
            self.getGroupUIDs()
        })
    }
    
    func getGroupUIDs() {
        self.usernamesList.removeAll()
        let db = Firestore.firestore()
        db.collection("info").document(self.groupID).getDocument() { (doc, err) in
            if let document = doc, document.exists {
                let usersID = document.get("usersID") as! [String]
                for i in 0..<usersID.count {
                    db.collection("users").document(usersID[i]).getDocument() { (doc2, err) in
                        if let document2 = doc2, document2.exists {
                            if usersID[i] != self.author {
                                let name = document2.get("username") as! String
                                self.usernamesList.append(usersNames(id: usersID[i], username: name))
                                if usersID[i] == self.toUID {
                                    self.toUsername = name
                                }
                            }
                        } else if usersID[i] == self.toUID {
                            self.toUsername = "§ User does not found"
                        }
                    }
                }
            }
        }
    }
}

struct usersNames: Identifiable {
    var id: String
    var username: String
}
