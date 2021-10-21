//
//  AddNewListItemView.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI

//AddNewListItemView(listIndex: listIndex)

struct AddNewListItemView: View {
    // MARK: - PROPERTY
    
    let listIndex: Int
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var user: User
    
    @State var newBody: String = ""
    @State var newLink: String = ""
    
    @State var isShowingPhotoLibrary: Bool = false
        
    
    //COLOR
    @AppStorage("CustomColorActive") var customColor: Bool = false
    private let defaults = UserDefaults.standard
    @EnvironmentObject var BackgroundColors: BackgroundColors
    
    //IMAGE
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
                            var newBodyItem = BodyItem(id: UUID().uuidString, user: ShoppingListUser(email: user.userInfo.email, username: user.userInfo.email), text: newBody, hyperLink: newLink, containsImage: false, image: nil)
                            
                            if image == UIImage() {
                                print("no image :(")
                                newBodyItem = BodyItem(id: UUID().uuidString, user: ShoppingListUser(email: user.userInfo.email, username: user.userInfo.email), text: newBody, hyperLink: newLink, containsImage: false, image: nil)
                            } else {
                                print("Image acknowledged!")
                                newBodyItem = BodyItem(id: UUID().uuidString, user: ShoppingListUser(email: user.userInfo.email, username: user.userInfo.email), text: newBody, hyperLink: newLink, containsImage: false, image: image)
                            }
                            
                            user.lists[listIndex].body.append(newBodyItem)
                            
                            NetworkManager.shared.addListItem(for: user.userInfo.email, username: user.userInfo.username, password: user.userInfo.password, listID: user.lists[listIndex]._id, text: newBody, hyperLink: newLink, image: image) { result in
                                switch result {
                                case .success(let resp):
                                    let ind = user.lists[listIndex].body.count-1
                                    if resp.path == "" { //: ERROR wtf?
                                        user.lists[listIndex].body[ind].containsImage = false
                                    } else {
                                        user.lists[listIndex].body[ind].containsImage = true
                                    }
                                    user.lists[listIndex].body[ind].id = resp.id
                                case .failure(let err):
                                    print("body insertion failure with error: \(err)")
                                }
                            }

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
        } //: NavigationView
        .hiddenNavigationBarStyle()
    }
}

// MARK: - PREVIEW
struct AddNewListItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewListItemView(listIndex: 0)
            .previewDevice("iPhone 12")
            .environmentObject(User(sampleUser: ""))
            .environmentObject(BackgroundColors())
    }
}
