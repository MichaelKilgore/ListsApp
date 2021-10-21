//
//  AppDelegate.swift
//  List
//
//  Created by Michael Kilgore on 9/25/21.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.SetupPushNotification(application: application)
        
        return true
    } //: FUNC
    
    func SetupPushNotification(application: UIApplication) -> () {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        { (granted,error) in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("User Notification permission denied: \(error?.localizedDescription ?? "error")")
            }
        }
    }
    
    /*
        Purpose: After the user registers for remote notifications, the users deviceToken is set.
     */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token: String = tokenString(deviceToken)
        let infoPassed: [String: String] = ["deviceToken": token]
        NotificationCenter.default.post(name: NSNotification.setDeviceToken, object: nil, userInfo: infoPassed)
    }
    
    //This is called if registering for remote notifications fails.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //Try again later.
        print("\(error)")
    }
    
    //Takes in remote notifications right here
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
            
        //User.shared.userInfo.email = "butthole"
        //print("Changed userInfo to: \(User.shared.userInfo.email)")
        
        User.callStack.append(userInfo)
        
        /*if let msg = userInfo["msg"] as? String {
            if (msg == "inviteRequest") {
                let dict = userInfo as! [String: String]
                //inviteRequest = { "listID": listID, "listName": listName }
                User.shared.userInfo.invites.append(InviteUser(listID: dict["listID"]!, listName: dict["listName"]!))
            } else if (msg == "userJoinsList") {
                let dict = userInfo as! [String: String]
                //userJoinsList = { "listID": listID, "email": email, "username": username }
                for i in 0..<User.shared.lists.count {
                    if (User.shared.lists[i]._id == dict["listID"]!) {
                        User.shared.lists[i].users.append(ShoppingListUser(email: dict["email"]!, username: dict["username"]!))
                    }
                } //: LOOP
            } else if (msg == "userLeavesList") {
                let dict = userInfo as! [String: String]
                //userLeavesList = { "listID": listID, "email": email }
                for i in 0..<User.shared.lists.count {
                    if User.shared.lists[i]._id == dict["listID"]! {
                        for j in 0..<User.shared.lists[i].users.count {
                            if User.shared.lists[i].users[j].email == dict["email"]! {
                                User.shared.lists[i].users.remove(at: j)
                            }
                        }
                    }
                }
            } else if (msg == "newBodyItem") {
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
                    
                    for i in 0..<User.shared.lists.count {
                        if User.shared.lists[i]._id == listID {
                            User.shared.lists[i].body.append(decodedResults!)
                        }
                    } //: LOOP
                }
            } else if (msg == "removeBodyItem") {
                /*
                    "msg": String,
                    "listID": listID,
                    "bodyID": bodyID
                 */
                let dict = userInfo as! [String: String]
                
                for i in 0..<User.shared.lists.count {
                    if User.shared.lists[i]._id == dict["listID"] {
                        for j in 0..<User.shared.lists[i].body.count {
                            if User.shared.lists[i].body[j].id == dict["bodyID"] {
                                User.shared.lists[i].body.remove(at: j)
                            }
                        } //: LOOP
                    }
                } //: LOOP
            } else if (msg == "editBodyItem") {
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
                    
                    for i in 0..<User.shared.lists.count {
                        if User.shared.lists[i]._id == listID {
                            for j in 0..<User.shared.lists[i].body.count {
                                if User.shared.lists[i].body[j].id == bodyID {
                                    User.shared.lists[i].body[j] = decodedResults!
                                }
                            } //: LOOP
                        }
                    } //: LOOP
                }
            } else if (msg == "logout") {
                /*KeychainWrapper.standard.removeObject(forKey: "email")
                KeychainWrapper.standard.removeObject(forKey: "password")
                
                isLoggedIn = false
                //have a pop up alert that user was logged in elsewhere.
                showingAlert = true*/
            } else {
                print("failed wtf?")
            }
        }*/
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Entering the foreground!")
        //NotificationCenter.default.post(name: NSNotification.enteredForeground, object: nil, userInfo: ["":""])
    }

    
    func tokenString(_ deviceToken: Data) -> String {
        let bytes = [UInt8](deviceToken)
        var token = ""
        for byte in bytes {
            token += String(format: "%02x", byte)
        }
        
        return token
    }
}

extension NSNotification {
    static let setDeviceToken = Notification.Name.init("setDeviceToken")
    
    static let inviteRequest = Notification.Name.init("inviteRequest")
    
    static let userJoinsList = Notification.Name.init("userJoinsList")
    static let userLeavesList = Notification.Name.init("userLeavesList")
    
    static let newBodyItem = Notification.Name.init("newBodyItem")
    static let removeBodyItem = Notification.Name.init("removeBodyItem")
    static let editBodyItem = Notification.Name.init("editBodyItem")

    static let logout = Notification.Name.init("logout")
}
