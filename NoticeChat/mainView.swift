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
    @ObservedObject var datas = observer()
    @State var msg = ""
    
    var body: some View {
        VStack {
            List {
                ForEach(self.datas.data) { i in
                    if i.type == 0 {
                        textBubble(data: i)
                    }
                }
                .onDelete { (index) in
                    // remove data on Firestore
                    let id = self.datas.data[index.first!].id
                    let db = Firestore.firestore().collection("group1")
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
    }
    
    // write a new data on firestore
    func addData(input: String) {
        
        let db = Firestore.firestore()
        let msg = db.collection("group1").document()
        
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
            chatView().tabItem {
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
