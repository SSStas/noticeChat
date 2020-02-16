//
//  mainView.swift
//  NoticeChat
//
//  Created by Mac on 10.01.2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct chatView: View {
    
    @EnvironmentObject var user: userProfile
    @ObservedObject var datas: observer
    
    @State var groupID: String
    @State var author: String
    
    @State var msg = ""
    @State var value : CGFloat = 0
    @State var isAdded = false
    @State var isScrolling = true
    
    @State var choosen: String?
    @State var toUID: String?
    @State var showSheet = false
    
    var body: some View {
        VStack {
            CustomScrollView(scrollToEnd: self.isScrolling) {
                Group {
                    ForEach((1...30).reversed(), id: \.self) { _ in
                        Text("")
                    }
                    ForEach(self.datas.data) { i in
                        if i.type[0] == "m" {
                            textBubble(data: i, groupID: self.$groupID, isMarked: self.author == i.fromUID)
                                .contextMenu{
                                    Text("\(i.msg)")
                                    if self.user.user != nil && i.fromUID == self.user.user!.uid {
                                        Button(action: { self.choosen = i.id }) {
                                            HStack(spacing: 12) {
                                                Text("Rewrite")
                                                Image(systemName: "square.and.pencil")
                                            }
                                        }
                                        Button(action: { self.deleteData(id: i.id) }) {
                                            HStack(spacing: 12) {
                                                Text("Delete")
                                                Image(systemName: "trash")
                                            }
                                        }
                                    }
                              }
                        }
                    }
                }
            }
            .onAppear {
                UITableView.appearance().separatorStyle = .none
            }.onDisappear {
                UITableView.appearance().separatorStyle = .singleLine
            }
            
            // show the choosen message
            if self.choosen != nil {
                HStack {
                    Text("Rewrite: ")
                    Text(self.getChoosen())
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                    Spacer()
                    Button(action: { self.choosen = nil }) {
                        Image(systemName: "multiply")
                    }
                }
                .padding()
                .border(Color.black)
            }
            
            // for sending the message
            HStack {
                
                TextField("message", text: $msg)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if self.user.user != nil && self.user.user!.uid == self.author {
                    Button(action: {
                        self.showSheet.toggle()
                    }) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                    }.padding()
                }
                
                Button(action: {
                    print(self.msg)
                    if self.choosen == nil {
                        self.addData(input: self.msg)
                    } else {
                        self.updateData(input: self.msg, id: self.choosen!)
                    }
                }) {
                    Image(systemName: "arrow.right")
                }.padding()
                
            }
            .padding([.horizontal])
        }
        .offset(y: -self.value)
        .animation(.spring())
        .onAppear(perform: {
            self.forKeyboard()
        })
        .onAppear(perform: {
            print("onAppear")
            self.isScrolling = false
            self.toUID = nil
        })
        .onDisappear {
            print("onDisappear")
            if self.datas.news > 0 || self.isAdded {
                let db2 = Firestore.firestore().collection("info").document(self.groupID)
                let now = Date()
                db2.updateData(["usersLastUpdate.\(self.user.user!.uid)" : now])
                self.datas.lastDate = now
            }
            self.datas.news = 0
        }
        .sheet(isPresented: self.$showSheet) { CustomActionSheet(toUID: self.$toUID, groupID: self.groupID, author: self.author) }
    }
    
    // write a new data on firestore
    func addData(input: String) {
        
        let db = Firestore.firestore()
        let msg = db.collection("\(self.groupID)").document()
        
        if self.toUID == nil {
            msg.setData(["fromUID":self.user.user?.uid ?? "", "date":Date(), "msg":input, "type":"mn"]) { (err) in
                if err != nil {
                    print("*** LOCAL ERROR *** \n\((err)!)")
                    return
                }
                self.isAdded = true
                self.msg = ""
            }
        } else {
            msg.setData(["fromUID":self.user.user?.uid ?? "", "date":Date(), "msg":input, "type":"mn", "toUID":self.toUID!]) { (err) in
                if err != nil {
                    print("*** LOCAL ERROR *** \n\((err)!)")
                    return
                }
                self.isAdded = true
                self.msg = ""
                self.toUID = nil
            }
        }
    }
    
    func deleteData(id: String) {
        // remove data on Firestore
        let db = Firestore.firestore().collection("\(self.groupID)")
        db.document(id).delete { (err) in
            if err != nil {
                print("*** LOCAL ERROR *** \n\((err?.localizedDescription)!)")
                return
            }
            print("deleted Successfully")
        }
    }
    
    func updateData(input: String, id: String) {
        let db = Firestore.firestore()
        let msg = db.collection("\(self.groupID)").document(id)
        var isNew = false
        
        for i in 0..<self.datas.data.count {
            if self.datas.data[i].id == self.choosen && self.datas.data[i].type == "mn" {
                isNew = true
                break
            }
        }
        
        msg.updateData(["msg":input, "type":(!isNew ? "mu" : "mn")]) { (err) in
            if err != nil {
                print("*** LOCAL ERROR *** \n\((err?.localizedDescription)!)")
                return
            }
            self.choosen = nil
            self.msg = ""
        }
    }
    
    func getChoosen() -> String {
        for item in self.datas.data {
            if item.id == self.choosen && item.type[0] == "m" {
                return item.msg
            }
        }
        return ""
    }
    
    func forKeyboard() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
            let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
            let height = value.height
            
            self.value = height - 30.0
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
            
            self.value = 0
        }
    }
}



struct groupsView: View {
    
    @EnvironmentObject var user: userProfile
    @ObservedObject var datas: groupObserver
    @State var timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            if !self.datas.data.isEmpty {
                List {
                    ForEach(self.datas.data.reversed()) { i in
                        ZStack {
                            groupBubble(message: i.messages, name: i.name)
                                .contextMenu{
                                  if self.user.user != nil {
                                      Button(action: { self.deleteGroup(id: i.id) }) {
                                          HStack(spacing: 12) {
                                            Text("Leave group")
                                              Image(systemName: "arrowshape.turn.up.left.circle")
                                          }
                                      }
                                  }
                                }
                            NavigationLink(destination: chatView(datas: i.messages, groupID: i.id, author: i.author).navigationBarTitle("\(i.name)")) {
                                EmptyView()
                            }
                        }
                    }

                }.id(UUID())
                
            } else {
                Text("No chats")
                    .font(.title)
                    .foregroundColor(Color.gray)
            }
        
        }.onReceive(self.timer, perform: { _ in
            if observer.isNew {
                for item in self.datas.data {
                    if item.messages.isUploading { return }
                }
                observer.isNew = false
                self.datas.sorting()
                return
            }
        })
        .onAppear(perform: {
            self.timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
        })
    }
    
    func deleteGroup(id: String) {
        let db = Firestore.firestore().collection("info").document(id)
        db.updateData([
            "usersID": FieldValue.arrayRemove(["\(self.user.user!.uid)"]),
            "usersLastUpdate.\(self.user.user!.uid)" : FieldValue.delete()
        ]) { (err) in
            if err != nil {
                print("*** LOCAL ERROR *** \n\((err?.localizedDescription)!)")
                return
            }
            for i in 0..<self.datas.data.count {
                if id == self.datas.data[i].id {
                    self.datas.data.remove(at: i)
                    return
                }
            }
            print("del")
            return
        }
    }
    
}



struct optionsView: View {
    
    @EnvironmentObject var user: userProfile
    @ObservedObject var datas: groupObserver
    @State var username: String
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Username:")) {
                    HStack {
                        TextField("Username", text: self.$username)
                            .font(.body)
                            .padding(.horizontal, 10.0)
                            .cornerRadius(10)
                        if self.user.user != nil && self.username != self.user.user!.username {
                            Button(action: {
                                self.updateUsername()
                            }) {
                                Text("update")
                                    .font(.callout)
                            }
                        }
                    }
                }
                Section(header: Text("Email:")) {
                    Text("\(self.user.user?.email ?? "None")")
                        .font(.body)
                }
                Section(header: Text("Exit:")) {
                    HStack {
                        Spacer()
                        Button(action: {
                            self.user.signOut()
                            if self.user.user == nil {
                                self.datas.unbind()
                                print("delete all data")
                            }
                        }) {
                            Text("Sign out")
                                .foregroundColor(Color.red)
                        }
                        Spacer()
                    }
                }
            }
            .onAppear {
                UITableView.appearance().separatorStyle = .none
            }.onDisappear {
                UITableView.appearance().separatorStyle = .singleLine
            }
        }
    }
    
    func updateUsername() {
        let db = Firestore.firestore().collection("users").document(self.user.user!.uid)
        db.updateData(["username": self.username])
        self.user.user!.username = self.username
    }
    
}

struct createView: View {

    @EnvironmentObject var user: userProfile
    @ObservedObject var datas: groupObserver
    @State var id: String = ""
    @State var error: String?

    var body: some View {
        VStack {
            Text("Join to the new group!")
                .font(.title)
            if self.error != nil {
                Text("\(self.error!)")
                    .font(.system(size: 20))
                    .foregroundColor(Color.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20.0)
            }
            TextField("Enter id of group", text: $id)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 10.0)
                .cornerRadius(10)
            Button(action: {
                self.appendGroup(id: self.id)
                self.id = ""
            }) {
                Text("Enter")
                    .font(.body)
            }
        }
        .onAppear(perform: {
            self.error = nil
        })
    }
    
    func appendGroup(id: String) {
        if id == "" { return }
        let db = Firestore.firestore().collection("info").document(id)
        if self.user.user == nil {
            self.error = "User not initialized"
            return
        }
        for item in self.datas.data {
            if item.id == id { return }
        }
        db.updateData([
            "usersID": FieldValue.arrayUnion(["\(self.user.user!.uid)"]),
            "usersLastUpdate.\(self.user.user!.uid)" : Date()
        ]) { (err) in
            if err != nil {
                self.error = "Can't find group with id: \"\(id)\""
            }
        }
    }
    
}

struct mainView: View {
    
    @EnvironmentObject var user: userProfile
    @ObservedObject var datas: groupObserver
    @State var selectedView = 1
    
    var body: some View {
        TabView(selection: $selectedView) {
            createView(datas: self.datas).tabItem {
                Image(systemName: "person.3.fill")
                Text("New group")
            }.tag(0)
            NavigationView {
                groupsView(datas: self.datas).navigationBarTitle("Chats")
            }.tabItem {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                Text("Chats")
            }.tag(1)
            NavigationView {
                optionsView(datas: self.datas, username: self.user.user!.username).navigationBarTitle("Options")
            }.tabItem {
                Image(systemName: "gear")
                Text("Options")
            }.tag(2)
        }
    }
    
}
