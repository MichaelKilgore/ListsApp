//
//  ShoppingListItemView.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI

struct ShoppingListItemView: View {
    // MARK: - PROPERTY
    
    @Environment(\.colorScheme) var colorScheme
    
    //listItem
    let shoppingList: ShoppingList
    
    // MARK: - BODY
    var body: some View {
        HStack {
            Text(shoppingList.shoppingListName)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .lineLimit(1)
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
            Spacer()
        
            if (shoppingList.users.count < 4) {
                HStack {
                    ForEach((0..<shoppingList.users.count), id: \.self) {
                        Text("\(firstCharacter(text: shoppingList.users[$0].username))")
                            .padding(5)
                            .font(.system(size: 13))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .background(Circle().fill(/*shoppingList.Users[$0].UserColor*/Color.red).shadow(radius: 3))
                    } //: ForEach
                }
                .padding(.horizontal, 20)
            } else {
                ForEach((0..<3), id: \.self) {
                    Text("\(firstCharacter(text: shoppingList.users[$0].username))")
                        .padding(5)
                        .font(.system(size: 13))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .background(Circle().fill(/*shoppingList.users[$0].UserColor*/Color.red).shadow(radius: 3))
                }
                Text("...")
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .padding(.horizontal, 20)
            }
        } //: HSTACK
        .padding(.vertical, 10) //0xFFDC00
        .background(colorScheme == .dark ? Color.black : Color(hex: 0xDEE4E7) .opacity(0.8))
        .cornerRadius(12)
    } //: BODY
    
    func firstCharacter(text: String) -> String {
        for i in text {
            return String(i)
        }
        return ""
    }
}

// MARK: - PREVIEW
struct ShoppingListItemView_Previews: PreviewProvider {
    static var previews: some View {
        
        ShoppingListItemView(shoppingList: ShoppingList(_id: "asdkfjasldfk", host: "mkilgore2000@gmail.com", shoppingListName: "Kilgore List", users: [ShoppingListUser(email: "mkilgore2000@gmail.com", username: "mkilgore2000")], body: [BodyItem]()))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
