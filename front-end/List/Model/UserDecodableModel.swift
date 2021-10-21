//
//  UserDecodableModel.swift
//  List
//
//  Created by Michael Kilgore on 9/28/21.
//

import Foundation

struct UserDecodable: Codable {
    var response: Int
    var userInfo: UserInfo
    var lists: [ShoppingList]
}
