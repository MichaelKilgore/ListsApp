//
//  ListsView.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI

struct ListsView: View {
    // MARK: - PROPERTY
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var user: User
    
    @State var newListViewPresented: Bool = false
    
    @State var offset: CGFloat = UIScreen.screenWidth
    
    //COLOR
    @AppStorage("CustomColorActive") var customColor: Bool = false
    private let defaults = UserDefaults.standard
    @EnvironmentObject var BackgroundColors: BackgroundColors
    
    @State var notificationViewPresented: Bool = false

    // MARK: - FUNCTION
    
    // MARK: - BODY
    var body: some View {
        ZStack {
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
                        ForEach(Array(zip(user.lists.indices, user.lists)), id: \.0) { index, element in
                            NavigationLink(destination: ShoppingListView(listIndex: index, email: user.userInfo.email)) {
                                ShoppingListItemView(shoppingList: element)
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                            }
                        } // LOOP
                    } // SCROLL
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 25.0, height: 25.0)
                                .overlay(
                                    VStack {
                                        Text("")
                                    }
                                )
                                .onTapGesture {
                                    withAnimation() {
                                        self.offset = CGFloat(0.0)
                                    }
                                }
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                                
                        } //LEFT
                        
                        ToolbarItem(placement: .principal) {
                            NavigationLink(destination: NotificationsView()) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .resizable()
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                                    .frame(width: 40.0, height: 40.0)
                                    .padding(10)
                                    .overlay(
                                        VStack {
                                            Text("")
                                            if user.userInfo.invites.count != 0 {
                                                Circle()
                                                    .fill(Color.red)
                                                    .frame(width: 15, height: 15, alignment: .center)
                                                    .offset(x: 20, y: -15)
                                            }
                                        }
                                    )
                                    .onTapGesture(perform: {
                                        notificationViewPresented = true
                                    })
                                    .fullScreenCover(isPresented: $notificationViewPresented, content: NotificationsView.init)
                            }
                        } // CENTER
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 25.0, height: 25.0)
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                                .overlay(
                                    Text("")
                                )
                                .onTapGesture {
                                    newListViewPresented = true
                                }
                                .fullScreenCover(isPresented: $newListViewPresented, content: NewListView.init)
                        } // RIGHT
                    } //: TOOLBAR
                } // ZSTACK
            } // NAVIGATION
            .zIndex(1)
            SettingsView(offset: $offset)
                    .transition(.move(edge: .trailing))
                    .offset(x: offset)
                    .zIndex(2)
        } // ZSTACK
        .onAppear(perform: {
            let savedRed = defaults.double(forKey: "red")
            let savedGreen = defaults.double(forKey: "green")
            let savedBlue = defaults.double(forKey: "blue")
            
            BackgroundColors.red = Double(savedRed)
            BackgroundColors.green = Double(savedGreen)
            BackgroundColors.blue = Double(savedBlue)
        })
    }
}

// MARK: - PREVIEW
struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        ListsView()
            .previewDevice("iPhone 12 Pro")
            .environmentObject(User(sampleUser: ""))
            .environmentObject(BackgroundColors())
    }
}
