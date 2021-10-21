//
//  ShoppingListBodyView.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI

struct ShoppingListBodyView: View {
    // MARK: - PROPERTY
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var user: User
    
    let listIndex: Int
    var bodyIndex: Int
    
    @State private var EditViewPageDisplayed: Bool = false
    @State var done: [Bool] = [false, false]
    var colorIndex: Int = Int.random(in: 0...10)
    
    @State var item: BodyItem
    
    @State var refresh: Bool = false
        
    // MARK: - PREVIEW
    var body: some View {
        Group {
            if (listIndex < user.lists.count && bodyIndex < user.lists[listIndex].body.count) {
            if (user.lists[listIndex].body[bodyIndex].image != nil) {
                VStack(spacing: 0) {
                    Image(uiImage: user.lists[listIndex].body[bodyIndex].getImage()!)
                        .resizable()
                        .frame(width: UIScreen.screenWidth-40, height: 250, alignment: .top)
                        .scaledToFill()
                        .clipped()
                        
                
                    if (item.hyperLink == "") {
                        HStack {
                            VStack {
                                HStack {
                                    Text("\(item.text)")
                                        .font(.title2)
                                        .fontWeight(.heavy)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .frame(width: UIScreen.screenWidth-140)
                                        .padding(.vertical, 10)
                                }
                                .frame(width: UIScreen.screenWidth-40)
                                .background(colorScheme == .dark ? Color.black : Color(hex: 0xDEE4E7) .opacity(0.8))
                            }
                        }
                    } else {
                        HStack {
                            VStack {
                                HStack {
                                    Text("\(item.text)")
                                        .font(.title2)
                                        .fontWeight(.heavy)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                        .frame(width: UIScreen.screenWidth-140)
                                        .padding(.vertical, 10)
                                }
                                .frame(width: UIScreen.screenWidth-40)
                                .background(colorScheme == .dark ? Color.black : Color(hex: 0xDEE4E7) .opacity(0.8))
                       
                                HStack {
                                    Group {
                                        Spacer()
                                        Link(destination: URL(string: item.hyperLink)!) {
                                            Image(systemName: "arrow.up.right.square")
                                        }
                                    }
                                }
                                .padding(.vertical, -10)
                                .padding(.horizontal, 10)

                            }
                            .padding(.vertical, 15)
                        } //HStack
                    }
                } //VStack
                .overlay(
                    ZStack {
                        HStack {
                            Spacer()
                            VStack {
                                Button (action: {
                                    if (done[0] == false) {
                                        EditViewPageDisplayed = true
                                    }
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .resizable()
                                        .frame(width: 30.0, height: 30.0)
                                        .padding(10)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                } //: BUTTON
                                .fullScreenCover(isPresented: $EditViewPageDisplayed) {
                                    UpdateExistingListItemView(listIndex: listIndex, bodyIndex: bodyIndex)
                                }
                                Spacer()
                            } //: VStack
                        } //: HStack
                        
                        LiquidSwipeView(leftData: SliderData(side: .left, startPosition: Double((Int(250)-0)/2)),originalLeftData: SliderData(side: .left, startPosition: Double((Int(250)-0)/2)),colorIndex: Int.random(in: 0...10), done: $done)
                        if (done[0] == true) {
                            HStack {
                                Button (action: {
                                    done[1] = true
                                }) {
                                        HStack {
                                            Image(systemName: "arrowshape.turn.up.backward.fill")
                                            Text("Undo")
                                                .font(.title2)
                                                .fontWeight(.heavy)
                                        } //: HStack
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.black)
                                        .cornerRadius(12)
                                        
                                } //: BUTTON
                                
                                Button (action: {
                                    DeleteRow()
                                }) {
                                    HStack {
                                        Text("Delete")
                                            .font(.title2)
                                            .fontWeight(.heavy)
                                    } //: HSTACK
                                    .padding()
                                    .foregroundColor(.red)
                                    .background(Color.black)
                                    .cornerRadius(12)
                                }
                                
                            } //: HSTACK
                        } //: IF
                    } //: ZStack
                )
            } else if (item.containsImage && user.lists[listIndex].body[bodyIndex].image == nil) {
                VStack(spacing: 0) {
                    
                    Image(uiImage: item.getImage() ?? UIImage())
                        .resizable()
                        .frame(width: UIScreen.screenWidth-40, height: 250, alignment: .top)
                        .scaledToFill()
                        .onAppear(perform: {
                            NetworkManager.shared.getImage(for: user.userInfo.email, password: user.userInfo.password, imageID: user.lists[listIndex].body[bodyIndex].id) { result in
                                switch result {
                                case .success(let resp):
                                    print("User successfully logged in.")
                                    user.lists[listIndex].body[bodyIndex].image = resp
                                    refresh.toggle()
                                case .failure(let err):
                                    print("Failed with error: \(err).")
                                }
                            }
                        })
                        .clipped()
                    
                    if (item.hyperLink == "") {
                        HStack {
                            VStack {
                                HStack {
                                    Text("\(item.text)")
                                        .font(.title2)
                                        .fontWeight(.heavy)
                                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                        .frame(width: UIScreen.screenWidth-140)
                                        .padding(.vertical, 10)
                                }
                                .frame(width: UIScreen.screenWidth-40)
                                .background(colorScheme == .dark ? Color.black : Color(hex: 0xDEE4E7) .opacity(0.8))
                            }
                        }
                    } else {
                        HStack {
                            VStack {
                                HStack {
                                    Text("\(item.text)")
                                        .font(.title2)
                                        .fontWeight(.heavy)
                                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                        .frame(width: UIScreen.screenWidth-140)
                                        .padding(.vertical, 10)
                                }
                                .frame(width: UIScreen.screenWidth-40)
                                .background(colorScheme == .dark ? Color.black : Color(hex: 0xDEE4E7) .opacity(0.8))

                       
                                HStack {
                                    Group {
                                        Spacer()
                                        Link(destination: URL(string: item.hyperLink)!) {
                                            Image(systemName: "arrow.up.right.square")
                                        }
                                    }
                                }
                                .padding(.vertical, -10)
                                .padding(.horizontal, 10)

                            }
                            .padding(.vertical, 15)
                        } //HStack
                    }
                } //VStack
                .background(Color.black)
                //.background(colorScheme == .dark ? Color.black : Color(hex: 0xDEE4E7) .opacity(0.8))
                //.opacity(0.8)
                .overlay(
                    ZStack {
                        HStack {
                            Spacer()
                            VStack {
                                Button (action: {
                                    if (done[0] == false) {
                                        EditViewPageDisplayed = true
                                    }
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .resizable()
                                        .frame(width: 30.0, height: 30.0)
                                        .padding(10)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                } //: BUTTON
                                .fullScreenCover(isPresented: $EditViewPageDisplayed) {
                                    UpdateExistingListItemView(listIndex: listIndex, bodyIndex: bodyIndex)
                                }
                                Spacer()
                            } //: VStack
                        } //: HStack
                        
                        LiquidSwipeView(leftData: SliderData(side: .left, startPosition: Double((Int(250)-0)/2)),originalLeftData: SliderData(side: .left, startPosition: Double((Int(250)-0)/2)),colorIndex: Int.random(in: 0...10), done: $done)
                        if (done[0] == true) {
                            HStack {
                                Button (action: {
                                    done[1] = true
                                }) {
                                        HStack {
                                            Image(systemName: "arrowshape.turn.up.backward.fill")
                                            Text("Undo")
                                                .font(.title2)
                                                .fontWeight(.heavy)
                                        } //: HStack
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.black)
                                        .cornerRadius(12)
                                        
                                } //: BUTTON
                                
                                Button (action: {
                                    DeleteRow()
                                }) {
                                    HStack {
                                        Text("Delete")
                                            .font(.title2)
                                            .fontWeight(.heavy)
                                    } //: HSTACK
                                    .padding()
                                    .foregroundColor(.red)
                                    .background(Color.black)
                                    .cornerRadius(12)
                                }
                                
                            } //: HSTACK
                        } //: IF
                    } //: ZStack
                )
            } else {
                if (item.hyperLink == "") {
                    HStack {
                        VStack {
                            HStack {
                                Text("\(item.text)")
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                    .frame(width: UIScreen.screenWidth-140)
                                    .padding(.vertical, 20)
                            }
                            .frame(width: UIScreen.screenWidth-40)
                        } //VStack
                    } //HStack
                    .background(colorScheme == .dark ? Color.black : Color(hex: 0xDEE4E7) .opacity(0.8))
                    .opacity(0.8)
                    .overlay(
                        ZStack {
                            HStack {
                                Spacer()
                                VStack {
                                    Button (action: {
                                        if (done[0] == false) {
                                            EditViewPageDisplayed = true
                                        }
                                    }) {
                                        Image(systemName: "pencil.circle.fill")
                                            .resizable()
                                            .frame(width: 30.0, height: 30.0)
                                            .padding(10)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    } //: BUTTON
                                    .fullScreenCover(isPresented: $EditViewPageDisplayed) {
                                        UpdateExistingListItemView(listIndex: listIndex, bodyIndex: bodyIndex)
                                    }
                                    Spacer()
                                } //: VStack
                            } //: HStack
                            LiquidSwipeView(leftData: SliderData(side: .left, startPosition: Double(30.0)), originalLeftData: SliderData(side: .left, startPosition: Double(30.0)), colorIndex: 0, done: $done)
                            if (done[0] == true) {
                                HStack {
                                    Button (action: {
                                        done[1] = true
                                    }) {
                                            HStack {
                                                Image(systemName: "arrowshape.turn.up.backward.fill")
                                                Text("Undo")
                                                    .font(.title2)
                                                    .fontWeight(.heavy)
                                            } //: HStack
                                            .padding()
                                            .foregroundColor(.white)
                                            .background(Color.black)
                                            .cornerRadius(12)
                                            
                                    } //: BUTTON
                                    
                                    Button (action: {
                                        DeleteRow()
                                    }) {
                                        HStack {
                                            Text("Delete")
                                                .font(.title2)
                                                .fontWeight(.heavy)
                                        } //: HSTACK
                                        .padding()
                                        .foregroundColor(.red)
                                        .background(Color.black)
                                        .cornerRadius(12)
                                    }
                                    
                                } //: HSTACK
                            } //: IF
                        } //: ZStack
                    )
                } else {
                    HStack {
                        VStack {
                            HStack {
                                Text("\(item.text)")
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                    .frame(width: UIScreen.screenWidth-140)
                                    .padding(.vertical, 10)
                            }
                            .frame(width: UIScreen.screenWidth-40)
                       
                            HStack {
                                Group {
                                    Spacer()
                                    Link(destination: URL(string: item.hyperLink)!) {
                                        Image(systemName: "arrow.up.right.square")
                                    }
                                } //GROUP
                            } //HStack
                            .padding(.vertical, -10)
                            .padding(.horizontal, 10)

                        } // VStack
                        .padding(.vertical, 15)
                    } //HStack
                    .background(colorScheme == .dark ? Color.black : Color(hex: 0xDEE4E7) .opacity(0.8))
                    .opacity(0.8)
                    .overlay(
                        ZStack {
                            HStack {
                                Spacer()
                                VStack {
                                    Button (action: {
                                        if (done[0] == false) {
                                            EditViewPageDisplayed = true
                                        }
                                    }) {
                                        Image(systemName: "pencil.circle.fill")
                                            .resizable()
                                            .frame(width: 30.0, height: 30.0)
                                            .padding(10)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    } //: BUTTON
                                    .fullScreenCover(isPresented: $EditViewPageDisplayed) {
                                        UpdateExistingListItemView(listIndex: listIndex, bodyIndex: bodyIndex)
                                    }
                                    Spacer()
                                } //: VStack
                            } //: HStack

                            LiquidSwipeView(leftData: SliderData(side: .left, startPosition: Double(40.0)), originalLeftData: SliderData(side: .left, startPosition: Double(40.0)), colorIndex: Int.random(in: 0...10), done: $done)
                            if (done[0] == true) {
                                HStack {
                                    Button (action: {
                                        done[1] = true
                                    }) {
                                            HStack {
                                                Image(systemName: "arrowshape.turn.up.backward.fill")
                                                Text("Undo")
                                                    .font(.title2)
                                                    .fontWeight(.heavy)
                                            } //: HStack
                                            .padding()
                                            .foregroundColor(.white)
                                            .background(Color.black)
                                            .cornerRadius(12)
                                            
                                    } //: BUTTON
                                    
                                    Button (action: {
                                        DeleteRow()
                                    }) {
                                        HStack {
                                            Text("Delete")
                                                .font(.title2)
                                                .fontWeight(.heavy)
                                        } //: HSTACK
                                        .padding()
                                        .foregroundColor(.red)
                                        .background(Color.black)
                                        .cornerRadius(12)
                                    }
                                    
                                } //: HSTACK
                            } //: IF
                        } //: ZStack
                    )
                } // else
            } //else
            }
        } //: Group
        .cornerRadius(12)
        .padding(10)
    } //: Body
    
    func firstCharacter(text: String) -> String {
        for i in text {
            return String(i)
        }
        return ""
    }
    
    func DeleteRow() {
        NetworkManager.shared.deleteListItem(for: user.userInfo.email, password: user.userInfo.password, listID: user.lists[listIndex]._id, bodyID: user.lists[listIndex].body[bodyIndex].id) { result in
            switch result {
            case .success(let resp):
                print("Deleted item with response: \(resp).")
            case .failure(let err):
                print("Failed to delete item with error: \(err).")
            }
        }
        user.lists[listIndex].body.remove(at: bodyIndex)
    }
    
}

// MARK: - PREVIEW
struct ShoppingListBodyView_Previews: PreviewProvider {
    @State static var listItem = BodyItem(id: "SDFSA", user: ShoppingListUser(email: "mkilgore2000@gmail.com", username: "mkilgore2000"), text: "food", hyperLink: "https://google.com", containsImage: false, image: nil)
    
    static var previews: some View {
        ShoppingListBodyView(listIndex: 0, bodyIndex: 0, item: listItem)
            .environmentObject(User(sampleUser: ""))
    }
}
