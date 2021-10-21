//
//  UserInfo.swift
//  List
//
//  Created by Michael Kilgore on 9/26/21.
//

import SwiftUI

struct UserInfo: Codable {
    var email: String
    var username: String
    var password: String
    var deviceToken: String
    var invites: [InviteUser]
}
