//
//  SecureInputField.swift
//  List
//
//  Created by Michael Kilgore on 9/10/21.
//

import SwiftUI

struct SecureInputField: View {
    //MARK: - PROPERTIES
    let defaultText: String
    @Binding var text: String
    
    //MARK: - BODY
    var body: some View {
        SecureField(defaultText, text: self.$text)
            .padding()
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 2)
            )
    }
}

//MARK: - PREVIEW
struct SecureInputField_Previews: PreviewProvider {
    static let defaultText: String = "Password"
    @State static var text: String = ""
    
    
    static var previews: some View {
        SecureInputField(defaultText: defaultText, text: $text)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
