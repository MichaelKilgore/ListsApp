//
//  newAccountViewFunctions.swift
//  List
//
//  Created by Michael Kilgore on 9/10/21.
//

import SwiftUI

func validEmail(text: String) -> Bool {
    var containsAtSymbol: Bool = false
    if (text.count >= 3) {
        for i in text {
            if (i == "@") {
                containsAtSymbol = true
            }
            if (i == " ") {
                return false
            }
            if (i == "-") {
                return false
            }
        }
    }
    if (containsAtSymbol == true) {
        return true
    }
    return false
}

func validPassword(text: String) -> Bool {
    let length = text.count
    var containsNum: Bool = false
    if (length >= 8 && length <= 15) {
        for i in text {
            if (i.isNumber) {
                containsNum = true
                break
            }
        }
    } else {
        return false
    }
    
    if (containsNum == true) {
        return true
    }
    
    return false
    
}

func passwordsMatch(one: String, two: String) -> Bool {
    if (one == two) {
        return true
    }
    return false
}

func validName(text: String) -> Bool {
    let length = text.count
    if length > 3 {
        return true
    }
    return false
}

