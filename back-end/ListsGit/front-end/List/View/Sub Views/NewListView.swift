//
//  NewListView.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI

struct NewListView: View {
    // MARK: - PROPERTY
    
    @EnvironmentObject var user: User
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State var newList: String = ""
    
    //COLOR
    @AppStorage("CustomColorActive") var customColor: Bool = false
    private let defaults = UserDefaults.standard
    @EnvironmentObject var BackgroundColors: BackgroundColors
        
    // MARK: - FUNCTION
    
    // MARK: - BODY
    var body: some View {
        NavigationView {
            ZStack {
                if !customColor {
                    Color(hex: 0x81C7F5)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Color(red: Double(BackgroundColors.red), green: Double(BackgroundColors.green), blue: Double(BackgroundColors.blue))
                        .edgesIgnoringSafeArea(.all)
                }
                
                VStack {
                    InputField(defaultText: "List Name", text: $newList)
                        .padding()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Text("")
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Cancel")
                                    .font(.title3)
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                            }
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Text("")
                            Button(action: {
                                NetworkManager.shared.createNewList(for: user.userInfo.email, password: user.userInfo.password, listName: newList) { result in
                                    switch result {
                                    case .success(let resp):
                                        switch (POST(rawValue: resp.resp)) {
                                        case .SUCCESS:
                                            user.lists.append(ShoppingList(_id: resp.listID, host: user.userInfo.email, shoppingListName: newList, users: [ShoppingListUser(email: user.userInfo.email, username: user.userInfo.username)], body: [BodyItem]()))
                                        default:
                                            print("Server error occurred try again in 30 seconds.")
                                        }
                                    case .failure(let err):
                                        print("user failed to create a new list with error: \(err).")
                                    }
                                }
                                
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Save")
                                    .font(.title3)
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                            }
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                        }
                    }
                }
            } //: ZStack
        } //: NavigationView
        .hiddenNavigationBarStyle()
    }
}

// MARK: - PREVIEW
struct NewListView_Previews: PreviewProvider {
    static var previews: some View {
        NewListView()
            .environmentObject(BackgroundColors())
            .environmentObject(User(emptyUser: ""))
    }
}
