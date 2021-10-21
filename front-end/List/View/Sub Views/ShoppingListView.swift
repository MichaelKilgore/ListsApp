//
//  ShoppingListView.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI

struct ShoppingListView: View {
    // MARK: - PROPERTY
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var user: User
    @Environment(\.colorScheme) var colorScheme

    let listIndex: Int
    let email: String
    
    @State var newListItemViewPresented: Bool = false
    
    //COLOR
    @AppStorage("CustomColorActive") var customColor: Bool = false
    private let defaults = UserDefaults.standard
    @EnvironmentObject var BackgroundColors: BackgroundColors
    
    // MARK: - BODY
    var body: some View {
        NavigationView {
            if listIndex < user.lists.count {
            ZStack {
                if !customColor {
                    Color(hex: 0x81C7F5)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Color(red: Double(BackgroundColors.red), green: Double(BackgroundColors.green), blue: Double(BackgroundColors.blue))
                        .edgesIgnoringSafeArea(.all)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        if listIndex < user.lists.count {
                            ForEach(Array(user.lists[listIndex].body.enumerated()), id: \.element.id) { index, element in
                                ShoppingListBodyView(listIndex: listIndex, bodyIndex: index, item: element)
                                    .padding(.horizontal)
                            } //: ForEach
                        }
                    }
                    //.onDelete(perform: DeleteRow)
                } //: SCROLLVIEW
                .navigationBarTitle(user.lists[listIndex].shoppingListName)
                .edgesIgnoringSafeArea(.all)
                .padding(.top, 0.3)
                .navigationViewStyle(StackNavigationViewStyle())
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
                                    .frame(width: 25.0, height: 25.0)
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                            }
                            .foregroundColor(.white)
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        NavigationLink(destination: UsersInListView(listIndex: listIndex)) {
                            HStack {
                                Text("")
                                Image(systemName: "info.circle.fill")
                                    .resizable()
                                    .frame(width: 30.0, height: 30.0)
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                            } //: HStack
                        } //: NavigationLink
                    } //LEFT
                    
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 25.0, height: 25.0)
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .onTapGesture {
                                newListItemViewPresented = true
                            }
                            .fullScreenCover(isPresented: $newListItemViewPresented) {
                                AddNewListItemView(listIndex: listIndex)
                            }
                        // .fullScreenCover(isPresented: $newListViewPresented, content: NewListView.init)
                    } //RIGHT
                } //: Toolbar
            } //: ZStack
            }
        } //: NavigationView
        .hiddenNavigationBarStyle()
    }
}

// MARK: - PREVIEW
struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView(listIndex: 0, email: "mkilgore2000@gmail.com")
            .previewDevice("iPhone 12")
            .environmentObject(User(sampleUser: ""))
    }
}
