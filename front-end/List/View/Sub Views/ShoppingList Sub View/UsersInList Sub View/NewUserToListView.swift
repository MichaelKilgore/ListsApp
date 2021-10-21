//
//  NewUserToListView.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI

struct NewUserToListView: View {
    // MARK: - PROPERTY
    
    
    let listIndex: Int
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var user: User
    
    @State var newUser: String = ""
    @State var inviteSent: String = ""
    
    // MARK: - BODY
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: 0x81C7F5)
                    .edgesIgnoringSafeArea(.all)
                List {
                    Spacer()
                    InputField(defaultText: "New User Email", text: $newUser)
                    Button(action: {
                        //Send user invite
                        inviteSent = "Invite Request Sent!"
                        NetworkManager.shared.inviteUser(for: user.userInfo.email, password: user.userInfo.password, invitedUser: newUser, listID: user.lists[listIndex]._id, listName: user.lists[listIndex].shoppingListName) { result in
                            switch result {
                            case .success(let resp):
                                print("invite sent. \(resp)")
                            case .failure(let err):
                                print("failed with error: \(err).")
                            }
                        }
                    }) {
                        Text("Send Invite Request")
                            .font(.custom("Sans Serif", size: 24))
                            .frame(maxWidth: .infinity)
                            .padding(5)
                            .background(Color.green)
                            .cornerRadius(25)
                        
                        Text("\(inviteSent)")
                            .font(.custom("Sans Serif", size: 16))
                            .frame(maxWidth: .infinity)
                            .padding(5)
                            .foregroundColor(Color.green)
                            .cornerRadius(25)
                    } // BUTTON
                } //LIST
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Text("")
                            Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .foregroundColor(.white)
                        }
                    }
                } //: Toolbar
            } //: ZSTACK
        } //: Navigation View
        .hiddenNavigationBarStyle()
    }
}

// MARK: - PREVIEW
struct NewUserToListView_Previews: PreviewProvider {
    static var previews: some View {
        NewUserToListView(listIndex: 0)
            .environmentObject(User(sampleUser: ""))
    }
}
