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
    
    static var isNew: Bool = true   // using for determine of the need for sorting
    
    @Published var data = [datatype]()
    var handle: ListenerRegistration?
    var isUploading: Bool   // show: Is uploading a new data now
    @Published var news: Int
    var lastDate: Date
    
    init(groupID: String, uid: String, lastDate: Date, author: String) {
        self.lastDate = lastDate
        self.news = 0
        self.isUploading = false
        let db = Firestore.firestore().collection("\(groupID)")
        
        self.handle = db.order(by: "date").addSnapshotListener { (snap, err) in
            if err != nil {
                print("*** LOCAL ERROR *** \n\((err?.localizedDescription)!)")
                return
            }
            var isAdded = false
            self.isUploading = true
            for i in snap!.documentChanges {
                
                let lastIsAdded = isAdded
                if i.type == .added {
                    isAdded = true
                    let from = i.document.get("fromUID") as! String
                    let to = i.document.get("toUID") as? String ?? ""
                    let date = (i.document.get("date") as! Timestamp).dateValue()
                    
                    if uid != author && !(uid == from || (from == author && (uid == to && to != "" || to == ""))) {
                        isAdded = lastIsAdded
                        continue
                    }
                    
                    let msgData = datatype(id: i.document.documentID, fromUID: from, date: date as Date, msg: i.document.get("msg") as! String, type: i.document.get("type") as? String ?? "ma")
                    self.data.append(msgData)
                    
                    if date > lastDate && from != uid {
                        self.news += 1
                    }
                }
                
                if i.type == .modified {
                    for j in 0..<self.data.count {
                        if self.data[j].id == i.document.documentID {
                            self.data[j].msg = i.document.get("msg") as! String
                            self.data[j].type = i.document.get("type") as! String
                            break
                        }
                    }
                }
                
                if i.type == .removed {
                    for j in 0..<self.data.count {
                        if self.data[j].id == i.document.documentID {
                            self.data.remove(at: j)
                            break
                        }
                    }
                }
                
            }
            
            // say at least one group has a new message
            self.isUploading = false
            if !observer.isNew && isAdded {
                observer.isNew = true
            }
        }
    }
    
    func getLast() -> datatype? {
        return self.data.last
    }
    
    func unbind() {
        if handle != nil {
            handle!.remove()
        }
    }
    
    deinit {
        print("remove group")
        unbind()
    }
}

/*
    type = [m/i] + [added(a)/update(u)/new(n)]
        m - simple text message
        i - image message
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
    var handle: ListenerRegistration?
    var uid: String
    
    init(uid: String) {
        print("init groups")
        self.uid = uid
        let db = Firestore.firestore().collection("info")
        self.handle = db.whereField("usersID", arrayContains: self.uid).addSnapshotListener { (snap, err) in
            if err != nil {
                print("*** LOCAL ERROR *** \n\((err?.localizedDescription)!)")
                return
            }
            
            for i in snap!.documentChanges {

                if i.type == .added {
                    let lastDate = (i.document.get("usersLastUpdate.\(uid)") as! Timestamp).dateValue()
                    let id = i.document.documentID
                    let author = i.document.get("author") as! String
                    let gData = groupDatatype(id: id, name: i.document.get("name") as! String, author: author, messages: observer(groupID: id, uid: uid, lastDate: lastDate, author: author))
                    self.data.append(gData)
                } else if i.type == .modified {
                    for j in 0..<self.data.count {
                        if self.data[j].id == i.document.documentID {
                            self.data[j].name = i.document.get("name") as! String
                            break
                        }
                    }
                }
                if i.type == .removed {
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
        self.data.sort(by: {($0.messages.data.last?.date ?? Date()) < ($1.messages.data.last?.date ?? Date())})
    }
    
    func unbind() {
        if handle != nil {
            handle!.remove()
            for i in 0..<self.data.count {
                self.data[i].messages.unbind()
            }
            self.data.removeAll()
        }
    }
    
    deinit {
        print("deinit group")
        unbind()
    }
}

struct groupDatatype: Identifiable {
    var id: String
    var name: String
    var author: String
    var messages: observer
}
