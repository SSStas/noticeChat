//
//  ContentView.swift
//  NoticeChat
//
//  Created by Mac on 10.01.2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var user: userProfile
    
    func getUser() {
        self.user.listen()
    }
    
    var body: some View {
        Group {
            if self.user.user != nil {
                mainView(datas: groupObserver(uid: self.user.user!.uid))
            } else {
                loginView()
            }
        }.onAppear(perform: self.getUser)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
