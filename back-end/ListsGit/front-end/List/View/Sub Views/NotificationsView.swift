//
//  NotificationsView.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI

struct NotificationsView: View {
    // MARK: - PROPERTY
    
    @EnvironmentObject var user: User
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.colorScheme) var colorScheme

    @State private var showingPaymentAlert = false
    
    @State var IndexBeingDeleted: Int = -1
    
    @State private var refreshingID = UUID()
    
    //COLOR
    @AppStorage("CustomColorActive") var customColor: Bool = false
    private let defaults = UserDefaults.standard
    
    @EnvironmentObject var BackgroundColors: BackgroundColors
    
    // MARK: - FUNCTION
    
    func getUser(item: String) -> String {
        let components = item.components(separatedBy: "-")
        return components[1]
    }
    
    func getList(item: String) -> String {
        let components = item.components(separatedBy: "-")
        return components[0]
    }
    
    func DeleteRow(index: Int, Accept: Bool) {
        
        //TODO: Tell server the item was removed from the list.
        if (Accept == true) {
            //tell server to add user to list and update users list.
            NetworkManager.shared.acceptInvite(for: user.userInfo.email, password: user.userInfo.password, listID: user.userInfo.invites[index].listID) { result in
                switch result {
                case .success(let resp):
                    print("invite accept executed successfully. \(resp)")
                case .failure(let err):
                    print("failure occurred: \(err)")
                }
            }
        } else {
            //decline
            //func declineInvite(for email: String, password: String, listID: String, withCompletion completion: @escaping (Result<Message, NetworkError>) -> Void) {
            NetworkManager.shared.declineInvite(for: user.userInfo.email, password: user.userInfo.password, listID: user.userInfo.invites[index].listID) { result in
                switch result {
                case .success(let resp):
                    print("invite declined successfully. \(resp)")
                case .failure(let err):
                    print("failure occurred: \(err)")
                }
            }
        }
        user.userInfo.invites.remove(at: index)
        self.refreshingID = UUID()
    } //: DeleteRow
    
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
                    //Invites
                    ForEach(Array(zip(user.userInfo.invites.indices, user.userInfo.invites)), id: \.0) { index, element in
                        Button(action: {
                            IndexBeingDeleted = index
                            showingPaymentAlert = true
                        }) {
                            InvitesListView(ListID: element.listID, ListName: element.listName)
                                .cornerRadius(16)
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .alert(isPresented: $showingPaymentAlert) {
                                    Alert(title: Text("Invite Request"),
                                          message: Text("Do you accept this invite to join \(element.listName)?"),
                                          primaryButton: .destructive(Text("Decline")) {
                                            //Delete item from invites notify server

                                            DeleteRow(index: IndexBeingDeleted, Accept: false)
                                          },
                                          secondaryButton: .destructive(Text("Accept")) {
                                            //delete item from invites and notify server
                                            DeleteRow(index: IndexBeingDeleted, Accept: true)
                                          }
                                    )
                                }
                        } //: Button
                    } //: ForEach
                    .id(refreshingID)
                } //: List
                .navigationBarTitle("Invites", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Text("")
                            Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.black)
                            }	
                            .foregroundColor(.black)
                        }
                    }
                }
            } //ZStack
        } //: NavigationView
        .hiddenNavigationBarStyle()
    }
}

// MARK: - PREVIEW
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
            .environmentObject(User(sampleUser: ""))
    }
}
