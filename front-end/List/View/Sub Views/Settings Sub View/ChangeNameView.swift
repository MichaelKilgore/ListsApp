//
//  ChangeNameView.swift
//  List
//
//  Created by Michael Kilgore on 9/13/21.
//

import SwiftUI

struct ChangeNameView: View {
    // MARK: - PROPERTY
        
    @EnvironmentObject var BackgroundColors: BackgroundColors
    @EnvironmentObject var user: User
    @AppStorage("CustomColorActive") var customColor: Bool = false
    
    @State var newName: String = ""
    @State var failed: String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            if !customColor {
                Color(hex: 0x81C7F5)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color(red: Double(BackgroundColors.red), green: Double(BackgroundColors.green), blue: Double(BackgroundColors.blue))
                .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                Text("To change your username enter it into the text box below and then press the submit changes button.")
                    .padding()
                
                InputField(defaultText: "username", text: $newName)
                    .padding([.leading, .trailing], 27.5)
                    .padding(.vertical, 20)
                
                Button(action: {
                    if newName.count > 2 && newName.count < 51 {
                        user.userInfo.username = newName
                        //tell server you changed the username
                        //func changeUsername(for email: String, password: String, username: String, withCompletion completion: @escaping (Result<Message, NetworkError>) -> Void) {
                        NetworkManager.shared.changeUsername(for: user.userInfo.email, password: user.userInfo.password, username: user.userInfo.username) { result in
                            switch result {
                            case .success(let resp):
                                switch POST(rawValue: resp.response) {
                                case .SUCCESS:
                                    print("Success.")
                                case .SERVER_ERROR:
                                    failed = "A server error occurred."
                                default:
                                    failed = "A server error occurred."
                                }
                            case .failure(let err):
                                print("user login request failed with error: \(err)")
                                failed = "A server error occurred."
                            }
                        }

                    } else {
                        failed = "The username must have a length between 3 and 50 characters long."
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Submit Changes")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.green)
                        .cornerRadius(15.0)
                } //: BUTTON
                
                Text(failed)
                    .foregroundColor(Color.red)
                    .padding()
            } //: VSTACK
            .onAppear(perform: {
                newName = user.userInfo.username
            })
        } //: ZSTACK
    } //: BODY
}

// MARK: - PREVIEW
struct ChangeNameView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeNameView()
            .environmentObject(User(sampleUser: ""))
            .environmentObject(BackgroundColors())
        
    }
}
