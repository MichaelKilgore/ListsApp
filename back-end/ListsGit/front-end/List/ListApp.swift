//
//  ListApp.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI

@main
struct ListApp: App {
    // MARK: - PROPERTY
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    
    @State var user: User = User(emptyUser: "")
    @State var backgroundColors: BackgroundColors = BackgroundColors()
    
    // MARK: - BODY
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(user)
                .environmentObject(backgroundColors)
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        print("app is now active.")
                        for i in 0..<User.callStack.count {
                            let userInfo = User.callStack[i]
                            
                            if let msg = userInfo["msg"] as? Int {
                                if (MSG(rawValue: msg) == .INVITE_REQUEST) {
                                    // if let uniqueListName = obj.userInfo?["UniqueListName"] as? String {
                                    let dict = userInfo as! [String: Any]
                                    print("HERE:")
                                    print(dict)
                                    //inviteRequest = { "listID": listID, "listName": listName }
                                    user.userInfo.invites.append(InviteUser(listID: dict["listID"] as! String, listName: dict["listName"] as! String))
                                } else if (MSG(rawValue: msg) == .USER_JOINS_LIST) {
                                    let dict = userInfo as! [String: String]
                                    //userJoinsList = { "listID": listID, "email": email, "username": username }
                                    for i in 0..<user.lists.count {
                                        if (user.lists[i]._id == dict["listID"]!) {
                                            user.lists[i].users.append(ShoppingListUser(email: dict["email"]!, username: dict["username"]!))
                                        }
                                    } //: LOOP
                                } else if (MSG(rawValue: msg) == .USER_LEAVES_LIST) {
                                    let dict = userInfo as! [String: String]
                                    //userLeavesList = { "listID": listID, "email": email }
                                    for i in 0..<user.lists.count {
                                        if user.lists[i]._id == dict["listID"]! {
                                            for j in 0..<user.lists[i].users.count {
                                                if user.lists[i].users[j].email == dict["email"]! {
                                                    user.lists[i].users.remove(at: j)
                                                }
                                            }
                                        }
                                    }
                                } else if (MSG(rawValue: msg) == .NEW_BODY_ITEM) {
                                    /*newBodyItem = {
                                        "body": newBodyItem,
                                        "listID": String,
                                        "msg": String
                                    }
                                     */
                                    if let msg2 = userInfo as? [String: Any] {
                                        let dict = msg2["body"] as! [String: Any]
                                        let listID = msg2["listID"] as! String
                                        
                                        let data = try? JSONSerialization.data(withJSONObject: dict)
                                        
                                        let decodedResults = try? JSONDecoder().decode(BodyItem.self, from: data!)
                                        
                                        for i in 0..<user.lists.count {
                                            if user.lists[i]._id == listID {
                                                user.lists[i].body.append(decodedResults!)
                                            }
                                        } //: LOOP
                                    }
                                } else if (MSG(rawValue: msg) == .REMOVE_BODY_ITEM) {
                                    /*
                                        "msg": String,
                                        "listID": listID,
                                        "bodyID": bodyID
                                     */
                                    let dict = userInfo as! [String: String]
                                    
                                    for i in 0..<user.lists.count {
                                        if user.lists[i]._id == dict["listID"] {
                                            for j in 0..<user.lists[i].body.count {
                                                if user.lists[i].body[j].id == dict["bodyID"] {
                                                    user.lists[i].body.remove(at: j)
                                                }
                                            } //: LOOP
                                        }
                                    } //: LOOP
                                } else if (MSG(rawValue: msg) == .EDIT_BODY_ITEM) {
                                    /*
                                     "body": newBodyItem,
                                     "listID": String,
                                     "bodyID": String,
                                     "msg": String
                                     */
                                    if let msg = userInfo as? [String: Any] {
                                        let dict = msg["body"] as! [String: Any]
                                        let listID = msg["listID"] as! String
                                        let bodyID = msg["bodyID"] as! String
                                        
                                        let data = try? JSONSerialization.data(withJSONObject: dict)
                                        
                                        let decodedResults = try? JSONDecoder().decode(BodyItem.self, from: data!)
                                        
                                        for i in 0..<user.lists.count {
                                            if user.lists[i]._id == listID {
                                                for j in 0..<user.lists[i].body.count {
                                                    if user.lists[i].body[j].id == bodyID {
                                                        user.lists[i].body[j] = decodedResults!
                                                    }
                                                } //: LOOP
                                            }
                                        } //: LOOP
                                    }
                                } else if (MSG(rawValue: msg) == .LOGOUT) {
                                    /*KeychainWrapper.standard.removeObject(forKey: "email")
                                    KeychainWrapper.standard.removeObject(forKey: "password")
                                    
                                    isLoggedIn = false
                                    //have a pop up alert that user was logged in elsewhere.
                                    showingAlert = true*/
                                } else {
                                    print("failed wtf?")
                                }
                            }
                        }
                        User.callStack = []
                    case .background:
                        print("entering background")
                    case .inactive:
                        print("entering inactivity")
                    @unknown default:
                        print("here we are.")
                    }
                }
        }
    }
}
