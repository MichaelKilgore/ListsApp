//
//  PushKitMessageTypeEnum.swift
//  List
//
//  Created by Michael Kilgore on 10/14/21.
//

import Foundation

enum MSG:Int {
    case INVITE_REQUEST = 0
    case USER_JOINS_LIST = 1
    case USER_LEAVES_LIST = 2
    case NEW_BODY_ITEM = 3
    case REMOVE_BODY_ITEM = 4
    case EDIT_BODY_ITEM = 5
    case LOGOUT = 6
}

enum POST:Int {
    case SUCCESS = 0
    case INVALID_LOGIN = 1
    case INVALID_REQUEST = 2
    case SERVER_ERROR = 3
}
