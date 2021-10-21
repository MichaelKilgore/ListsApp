//
//  UpdateExistingListItemView.swift
//  List
//
//  Created by Michael Kilgore on 9/24/21.
//

import SwiftUI

struct UpdateExistingListItemView: View {
    // MARK: - PROPERTY
    let listIndex: Int
    let bodyIndex: Int
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var user: User
    
    @State var isShowingPhotoLibrary: Bool = false
        
    
    //COLOR
    @AppStorage("CustomColorActive") var customColor: Bool = false
    private let defaults = UserDefaults.standard
    @EnvironmentObject var BackgroundColors: BackgroundColors
    
    @State var newBody: String = ""
    @State var newLink: String = ""
    @State var image: UIImage = UIImage()

    
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
                    ImageItemView(image: image)
                        .frame(width: 300, height: 300, alignment: .center)
                        .cornerRadius(12)
                        .onTapGesture {
                            isShowingPhotoLibrary = true
                        }
                    
                    InputField(defaultText: "Body", text: $newBody)
                        .padding()
                    
                    InputField(defaultText: "HyperLink", text: $newLink)
                        .padding()
                }
                .navigationBarItems(
                    leading:
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .font(.title3)
                                .foregroundColor(.white)
                        },
                    trailing:
                        Button(action: {
                            var newBodyItem = BodyItem(id: user.lists[listIndex].body[bodyIndex].id, user: ShoppingListUser(email: user.userInfo.email, username: user.userInfo.email), text: newBody, hyperLink: newLink, containsImage: false, image: nil)
                            
                            if image == UIImage() {
                                newBodyItem = BodyItem(id: user.lists[listIndex].body[bodyIndex].id, user: ShoppingListUser(email: user.userInfo.email, username: user.userInfo.email), text: newBody, hyperLink: newLink, containsImage: false, image: nil)
                                NetworkManager.shared.updateItem(for: user.userInfo.email, password: user.userInfo.password, listID: user.lists[listIndex]._id, bodyID: user.lists[listIndex].body[bodyIndex].id, text: newBody, hyperLink: newLink) { result in
                                    switch result {
                                    case .success(let resp):
                                        print("\(resp)")
                                    case .failure(let err):
                                        print(err)
                                    }
                                }
                            } else {
                                newBodyItem = BodyItem(id: user.lists[listIndex].body[bodyIndex].id, user: ShoppingListUser(email: user.userInfo.email, username: user.userInfo.email), text: newBody, hyperLink: newLink, containsImage: false, image: image) //TODO: NO IMAGE HERE FIX THIS....
                                NetworkManager.shared.updateItemWithImage(for: user.userInfo.email, password: user.userInfo.password, listID: user.lists[listIndex]._id, bodyID: user.lists[listIndex].body[bodyIndex].id, text: newBody, hyperLink: newLink, image: image) { result in
                                    switch result {
                                    case .success(let resp):
                                        print(resp)
                                    case .failure(let err):
                                        print(err)
                                    }
                                }
                            }
                            
                            user.lists[listIndex].body[bodyIndex] = newBodyItem
                            //networking tell the server we updated this item
                            
                            
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Save")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                )
            } //: ZSTACK
            .sheet(isPresented: $isShowingPhotoLibrary) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
            }
            .onAppear(perform: {
                newBody = user.lists[listIndex].body[bodyIndex].text
                newLink = user.lists[listIndex].body[bodyIndex].hyperLink
                if user.lists[listIndex].body[bodyIndex].image != nil {
                    image = user.lists[listIndex].body[bodyIndex].getImage()!
                }
            })
        } //: NavigationView
        .hiddenNavigationBarStyle()
    }
}

// MARK: - PREVIEW
struct UpdateExistingListItemView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateExistingListItemView(listIndex: 0, bodyIndex: 0)
    }
}
