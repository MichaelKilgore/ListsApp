//
//  InputField.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI

struct InputField: View {
    // MARK: - PROPERTY
    
    @Environment(\.colorScheme) var colorScheme
    let defaultText: String
    @Binding var text: String
    
    // MARK: - BODY
    var body: some View {
        TextField(self.defaultText, text: self.$text)
            .foregroundColor(colorScheme == .dark ? .black : .white)
            .padding()
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 2)
            )
    }
}

// MARK: - PREVIEW
struct InputField_Previews: PreviewProvider {
    @State static var text: String = ""
    
    static var previews: some View {
        InputField(defaultText: "Email", text: $text)
    }
}
