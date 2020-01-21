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
    
    @Published var data = [datatype]()
    
    init() {
        
        let db = Firestore.firestore().collection("group1")
        
        db.addSnapshotListener { (snap, err) in
            if err != nil {
                print("*** LOCAL ERROR *** \n\((err?.localizedDescription)!)")
                return
            }
            for i in snap!.documentChanges {
                
                if i.type == .added && i.document.get("msg") != nil {
                    let msgData = datatype(id: i.document.documentID, type: 0, msg: i.document.get("msg") as! String)
                    self.data.append(msgData)
                }
            }
        }
    }
}

/*
    types:
        0 - simple text message
        1 - image message
        2 - poll message
 */
struct datatype: Identifiable {
    var id: String
    var type: Int8
    var msg : String
}
