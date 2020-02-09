//
//  chatData.swift
//  NoticeChat
//
//  Created by Mac on 10.01.2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class observer : ObservableObject{
    
    static var isNew: Bool = true
    
    @Published var data = [datatype]()
    var isUploading: Bool   // show: Is uploading a new data now
    @Published var news: Int
    var lastDate: Date
    
    init(groupID: String, uid: String, lastDate: Date) {
        self.lastDate = lastDate
        self.news = 0
        self.isUploading = false
        let db = Firestore.firestore().collection("\(groupID)")
        
        db.order(by: "date").addSnapshotListener { (snap, err) in
            if err != nil {
                print("*** LOCAL ERROR *** \n\((err?.localizedDescription)!)")
                return
            }
            var isAdded = false
            self.isUploading = true
            for i in snap!.documentChanges {
                
                if i.type == .added {
                    var message = String()
                    var type = "0a"
                    isAdded = true
                    
                    if i.document.get("msg") != nil {
                        message = i.document.get("msg") as! String
                    } else {
                        message =  i.document.get("msg") as! String     // исправить на img
                        type = "1a"
                    }
                    
                    type += (i.document.get("new") != nil) ? "n" : "-"
                    print(type)
                    
                    let date = (i.document.get("date") as! Timestamp).dateValue()
                    let msgData = datatype(id: i.document.documentID, fromUID: i.document.get("fromUID") as! String, date: date as Date, msg: message, type: type)
                    self.data.append(msgData)
                    
                    if date > lastDate {
                        self.news += 1
                    }
                }
                
            }
            
            // say at least one group has a new message
            self.isUploading = false
            if !observer.isNew && self.news > 0 && isAdded {
                observer.isNew = true
            }
        }
    }
    
    func getLast() -> datatype? {
        return self.data.last
    }
}

/*
    type = [0/1] + [added(a)/update(u)] + [new(n)/-] + [documentID if new]
        0 - simple text message
        1 - image message
 */
struct datatype: Identifiable {
    var id: String
    var fromUID: String
    var date: Date
    var msg : String
    var type: String
}


class groupObserver : ObservableObject {
    
    @Published var data = [groupDatatype]()
    
    init(uid: String) {
        
        let db = Firestore.firestore().collection("info")
        db.whereField("usersID", arrayContains: uid).addSnapshotListener(includeMetadataChanges: true) { (snap, err) in
            if err != nil {
                print("*** LOCAL ERROR *** \n\((err?.localizedDescription)!)")
                return
            }
            
            for i in snap!.documentChanges {
                
                if i.type == .added {
                    let lastDate = (i.document.get("usersLastUpdate.\(uid)") as! Timestamp).dateValue()
                    let id = i.document.documentID
                    let gData = groupDatatype(id: id, name: i.document.get("name") as! String, author: i.document.get("author") as! String, messages: observer(groupID: id, uid: uid, lastDate: lastDate))
                    self.data.append(gData)
                } else if i.type == .modified {
                    for j in 0..<self.data.count {
                        if self.data[j].id == i.document.documentID {
                            self.data[j].name = i.document.get("name") as! String
                        }
                    }
                } else if i.type == .removed {
                    for j in 0..<self.data.count {
                        if self.data[j].id == i.document.documentID {
                            self.data.remove(at: j)
                            break
                        }
                    }
                }
                
            }
            
        }
    }
    
    func sorting() {
        print("sorting")
        self.data.sort(by: {($0.messages.data.last?.date ?? Date()) > ($1.messages.data.last?.date ?? Date())})
    }
}

struct groupDatatype: Identifiable {
    var id: String
    var name: String
    var author: String
    var messages: observer
}
