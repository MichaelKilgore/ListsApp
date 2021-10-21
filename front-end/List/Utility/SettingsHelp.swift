//
//  SettingsHelp.swift
//  List
//
//  Created by Michael Kilgore on 9/15/21.
//

import SwiftUI

class SettingsHelp: ObservableObject {
    @Published var displayed: Bool
    
    init() {
        self.displayed = false
    }
}
