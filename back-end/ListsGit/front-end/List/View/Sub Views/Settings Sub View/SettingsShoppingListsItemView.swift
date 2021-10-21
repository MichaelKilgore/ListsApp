//
//  SettingsShoppingListsItemView.swift
//  List
//
//  Created by Michael Kilgore on 9/12/21.
//

import SwiftUI

struct SettingsShoppingListsItemView: View {
    // MARK: - PROPERTY
    
    let listIndex: Int
    
    @State private var showingAlert = false
    
    @EnvironmentObject var user: User
    
    // MARK: - FUNCTION
    func DeleteRow() {
        print("The index being removed is: \(listIndex).")
        
        NetworkManager.shared.deleteList(for: user.userInfo.email, password: user.userInfo.password, listID: user.lists[listIndex]._id) { result in
            switch result {
            case .success(let resp):
                print("User successfully deleted a list with: \(resp)")
            case .failure(let err):
                print("user failed to delete list with error: \(err)")
            }
        }
        
        withAnimation {
            user.lists.remove(at: listIndex)
            print("deletion successful")
        }
        
    }
    
    // MARK: - BODY
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if listIndex < user.lists.count {
                    Text("\(user.lists[listIndex].shoppingListName)")
                        .font(.custom("Sans Serif", size: 24))
                    Text("by \(user.lists[listIndex].host)")
                        .font(.custom("Sans Serif", size: 12))
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Are you sure you want to delete the \(user.lists[listIndex].shoppingListName) list?"),
                    message: Text("This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        DeleteRow()
                    },
                    secondaryButton: .cancel()
                )
            } //: ALERT
            Spacer()
            Image(systemName: "minus.circle.fill")
                .onTapGesture {
                    showingAlert = true
                }
                .foregroundColor(Color.red)
        }//: HStack
    }
}

// MARK: - PREVIEW
struct SettingsShoppingListsItemView_Previews: PreviewProvider {
    
    static var previews: some View {
        SettingsShoppingListsItemView(listIndex: 0)
            .previewLayout(.sizeThatFits)
            .padding()
            .environmentObject(User(sampleUser: ""))
    }
}
