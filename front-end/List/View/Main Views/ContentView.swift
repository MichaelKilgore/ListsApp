//
//  ContentView.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI
import SwiftKeychainWrapper


struct ContentView: View {
    // MARK: - PROPERTY
    
    @State private var showingAlert = false
    
    @EnvironmentObject var backgroundColors: BackgroundColors
    @EnvironmentObject var user: User
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    // MARK: - BODY
    var body: some View {
        Group {
            if isLoggedIn {
                ListsView()
                    .environmentObject(backgroundColors)
            } else {
                LoginView()
                    .environmentObject(backgroundColors)
            }
        } //: GROUP
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.setDeviceToken)) { obj in
            if let deviceToken = obj.userInfo?["deviceToken"] as? String {
                user.userInfo.deviceToken = deviceToken
                let retrievedEmail: String? = KeychainWrapper.standard.string(forKey: "email")
                let retrievedPassword: String? = KeychainWrapper.standard.string(forKey: "password")
                if (retrievedEmail != nil && retrievedPassword != nil) {
                    NetworkManager.shared.login(for: retrievedEmail!, password: retrievedPassword!, deviceToken: user.userInfo.deviceToken) { result in
                        switch result {
                        case .success(let resp):
                            print("User successfully logged in.")
                            let origDT: String = user.userInfo.deviceToken
                            user.userInfo = resp.userInfo
                            user.userInfo.password = retrievedPassword!
                            user.userInfo.deviceToken = origDT
                            user.lists = resp.lists
                        case .failure(let err):
                            print("Hello?")
                            print("user login request failed with error: \(err)")
                        }
                    }
                }
            }
        } //: ON RECIEVE
        /*.alert(isPresented: $showingAlert) {
            Alert(title: Text("Logged Out"), message: Text("Your account was logged in else where."), dismissButton: .default(Text("OK")))
        }*/
        
        
    }
}

// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 12 Pro")
            .environmentObject(User(sampleUser: ""))
            .environmentObject(BackgroundColors())
    }
}
