//
//  InvitesListView.swift
//  List
//
//  Created by Michael Kilgore on 9/10/21.
//

import SwiftUI

struct InvitesListView: View {
    //: - PROPERTIES
    @Environment(\.colorScheme) var colorScheme
    
    @State var ListID: String
    @State var ListName: String
    //: - BODY
    var body: some View {
        HStack {
            Spacer()
            Text("\(ListName)")
                .foregroundColor(colorScheme == .dark ? .white : .black)
            Spacer()
        } //: HStack
        .multilineTextAlignment(.center)
        .padding()
        .cornerRadius(16)
        .background(colorScheme == .dark ? Color.black : Color(hex: 0xDEE4E7) .opacity(0.8))
    } //: Body
}

//: - PREVIEW
struct InvitesListView_Previews: PreviewProvider {
    @State static var ListName: String = "Grocery Store"
    @State static var FirstName: String = "Michael"
    
    static var previews: some View {
        InvitesListView(ListID: ListName, ListName: FirstName)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
