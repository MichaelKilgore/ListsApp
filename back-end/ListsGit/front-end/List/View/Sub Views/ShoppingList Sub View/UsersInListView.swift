//
//  UsersInListView.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI

struct UsersInListView: View {
    // MARK: - PROPERTY
    @State private var addingNewUser: Bool = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var user: User
    
    let listIndex: Int
    
    var list: ShoppingList {
        return user.lists[listIndex]
    }
    
    //COLOR
    @AppStorage("CustomColorActive") var customColor: Bool = false
    private let defaults = UserDefaults.standard
    @EnvironmentObject var BackgroundColors: BackgroundColors
    
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
                
                ScrollView {
                    Group {
                        ForEach((0..<list.users.count), id: \.self) {
                            Text("\(list.users[$0].email)")
                                .font(.custom("Sans Serif", size: 24))
                                .frame(maxWidth: .infinity)
                                .padding(5)
                                .background(/*list.users[$0].UserColor*/Color.red)
                                .cornerRadius(25)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                    } //: Group
                    if (list.host == user.userInfo.email) {
                        Button(action: {
                            addingNewUser = true
                        }) {
                            Text("Add new Users")
                                .font(.custom("Sans Serif", size: 24))
                                .frame(maxWidth: .infinity)
                                .padding(5)
                                .background(Color.green)
                                .cornerRadius(25)
                        } // BUTTON
                        .sheet(isPresented: $addingNewUser) {
                            NewUserToListView(listIndex: listIndex)
                         }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                    } //IF
                } //: List
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Text("")
                            Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .foregroundColor(.white)
                        }
                    }
                } //: toolbar
            }//: ZSTACK
        } //: NAVIGATION VIEW
        .hiddenNavigationBarStyle()
    }
}

// MARK: - PREVIEW
struct UsersInListView_Previews: PreviewProvider {
    static var previews: some View {
        UsersInListView(listIndex: 0)
            .environmentObject(User(sampleUser: ""))
    }
}
