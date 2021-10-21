//
//  SettingsListItemView.swift
//  List
//
//  Created by Michael Kilgore on 9/12/21.
//

import SwiftUI

struct SettingsListItemView: View {
    // MARK: - PROPERTY
    
    @Environment(\.colorScheme) var colorScheme
    
    let text: String
    let value: String
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            colorScheme == .dark ? Color.black : Color.white
            HStack {
                Text("\(text)")
                Spacer()
                Text("\(value)")
            }
            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            .padding()
        }
    }
}

// MARK: - PREVIEW
struct SettingsListItemView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsListItemView(text: "email:", value: "mkilgore2000@gmail.com")
            .previewLayout(.sizeThatFits)
            .padding()
        
    }
}
