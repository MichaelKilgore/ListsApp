//
//  User.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI

class User: ObservableObject {
    static var callStack: [[AnyHashable: Any]] = []
    
    @Published var userInfo: UserInfo
    @Published var lists: [ShoppingList]
    
    init(userInfo: UserInfo, lists: [ShoppingList]) {
        self.userInfo = userInfo
        self.lists = lists
    }
    
    convenience init(sampleUser: String) {
        self.init(userInfo: UserInfo(email: "billy.bob@gmail.com", username: "BillyBob", password: "asdf", deviceToken: "asdfa", invites: []), lists: [ShoppingList(_id: "asdkfjasldfk", host: "billy.bob@gmail.com", shoppingListName: "Shopping List", users: [ShoppingListUser(email: "billy.bob@gmail.com", username: "mkilgore2000")], body: [BodyItem]())])
    }
    
    convenience init(emptyUser: String) {
        self.init(userInfo: UserInfo(email: "", username: "", password: "", deviceToken: "", invites: []), lists: [])
    }
}
