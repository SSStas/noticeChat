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
    @State var msg = ""
    @State var author: String
    
    var body: some View {
        VStack {
            List {
                ForEach(self.datas.data) { i in
                    if i.type.first == "0" {
                        textBubble(data: i, isMarked: self.author == i.fromUID)
                    }
                }
                .onDelete { (index) in
                    // remove data on Firestore
                    let id = self.datas.data[index.first!].id
                    let db = Firestore.firestore().collection("\(self.groupID)")
                    db.document(id).delete { (err) in
                        if err != nil {
                            print("*** LOCAL ERROR *** \n\((err?.localizedDescription)!)")
                            return
                        }
                        print("deleted Successfully")
                        self.datas.data.remove(atOffsets: index)
                    }
                }
            }.onAppear {
                UITableView.appearance().separatorStyle = .none
            }.onDisappear {
                UITableView.appearance().separatorStyle = .singleLine
            }
            HStack {
                
                TextField("msg", text: $msg)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    print(self.msg)
                    self.addData(input: self.msg)
                }) {
                    Text("Add")
                }.padding()
                
            }.padding()
        }
        .onAppear(perform: {
            for i in 0..<self.datas.data.count {
                if self.user.user!.uid != self.datas.data[i].fromUID && self.datas.data[i].type[2] == "n" {
                    let db =  Firestore.firestore().collection("\(self.groupID)").document(self.datas.data[i].id)
                    db.updateData([
                        "new": FieldValue.delete(),
                    ]) { err in
                        if err != nil {
                            print("*** LOCAL ERROR *** \n\((err?.localizedDescription)!)")
                            return
                        }
                    }
                    print(self.datas.data[i].type)
                    self.datas.data[i].type = self.datas.data[i].type[0 ..< 2] + "-"
                    print(self.datas.data[i].type)
                }
            }
        })
        .onDisappear {
            if self.datas.news > 0 {
                let db2 = Firestore.firestore().collection("info").document(self.groupID)
                let now = Date()
                db2.updateData(["usersLastUpdate" : [ self.user.user!.uid : now ]])
                self.datas.lastDate = now
                self.datas.news = 0
            }
        }
    }
    
    // write a new data on firestore
    func addData(input: String) {
        
        let db = Firestore.firestore()
        let msg = db.collection("\(self.groupID)").document()
        
        msg.setData(["fromUID":self.user.user?.uid ?? "", "date":Date(), "msg":input]) { (err) in
            if err != nil {
                print("*** LOCAL ERROR *** \n\((err)!)")
                return
            }
            print("success")
            self.msg = ""
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
                    ForEach(self.datas.data) { i in
                        ZStack {
                            groupBubble(message: i.messages, name: i.name)
                            NavigationLink(destination: chatView(datas: i.messages, groupID: i.id, author: i.author).navigationBarTitle("\(i.name)")) {
                                EmptyView()
                            }
                        }
                    }
                }//.id(UUID())
            } else {
                Text("No chats")
            }
            /*Button(action: {
                let db = Firestore.firestore().collection("info").document("group3")
                db.updateData([
                    "usersID": FieldValue.arrayUnion(["\(self.user.user!.uid)"])
                ])
            }) {
                Text("Group3")
            }*/
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
    
}

struct optionsView: View {
    
    @EnvironmentObject var user: userProfile
    
    var body: some View {
        VStack {
            Button(action: self.user.signOut) {
                Text("Sign out")
            }
        }
    }
}

struct mainView: View {
    
    @EnvironmentObject var user: userProfile
    @State var selectedView = 1
    
    var body: some View {
        TabView(selection: $selectedView) {
            Text("\(self.user.user!.uid)").tabItem {
                Text("Tab Label 1")
            }.tag(0)
            NavigationView {
                groupsView(datas: groupObserver(uid: self.user.user!.uid)).navigationBarTitle("Chats")
            }.tabItem {
                Text("Tab Label 2")
            }.tag(1)
            optionsView().tabItem {
                Text("Tab Label 3")
            }.tag(2)
        }
    }
}

struct mainView_Previews: PreviewProvider {
    static var previews: some View {
        mainView()
    }
}
