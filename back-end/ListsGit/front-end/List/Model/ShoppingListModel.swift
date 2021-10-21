//
//  ShoppingListModel.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import Foundation

struct ShoppingList: Codable {
    var _id: String
    var host: String
    var shoppingListName: String
    var users: [ShoppingListUser]
    var body: [BodyItem]
}


