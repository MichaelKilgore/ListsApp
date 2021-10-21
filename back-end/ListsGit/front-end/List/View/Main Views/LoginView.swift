//
//  LoginView.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI
import SwiftKeychainWrapper

struct LoginView: View {
    // MARK: - PROPERTY
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @EnvironmentObject var user: User
    
    @State private var email = ""
    @State private var password = ""
    @State private var newAccount: Bool = false
    @State private var forgotPassword: Bool = false
    @State private var incorrectLogin: String = " "
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            BubblyBackground()
                .ignoresSafeArea()
            
            VStack {
                Text("Shopping Lists")
                    .font(.largeTitle)
                    .padding([.top, .bottom], 40)
                Image(systemName: "cart")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                    .padding(.bottom, 50)
                VStack(alignment: .leading, spacing: 15) {
                    InputField(defaultText: "Email", text: $email)
                    SecureInputField(defaultText: "Password", text: $password)
                } //: VSTACK
                .padding([.leading, .trailing], 27.5)
                .padding(.vertical, 20)
                Button(action: {
                    NetworkManager.shared.login(for: email, password: password, deviceToken: user.userInfo.deviceToken) { result in
                            switch result {
                            case .success(let resp):
                                print("User successfully logged in.")
                                let prevDT: String = user.userInfo.deviceToken
                                user.userInfo = resp.userInfo
                                user.userInfo.deviceToken = prevDT
                                user.userInfo.password = password
                                user.lists = resp.lists
                                KeychainWrapper.standard.set((user.userInfo.email), forKey: "email")
                                KeychainWrapper.standard.set((user.userInfo.password), forKey: "password")
                                //TODO: Maybe add this back but asynchronously? idk it doesn't seem to work so far.
                                /*for i in 0..<user.lists.count {
                                    for j in 0..<user.lists[i].body.count {
                                        if user.lists[i].body[j].containsImage {
                                            NetworkManager.shared.getImage(for: user.userInfo.email, password: user.userInfo.password, imageID: user.lists[i].body[j].id) { result in
                                                switch result {
                                                case .success(let resp):
                                                    print("User successfully logged in.")
                                                    user.lists[i].body[j].image = resp
                                                case .failure(let err):
                                                    print("Failed with error: \(err).")
                                                }
                                            }
                                        }
                                    }
                                }*/
                                print("Wtf is good hommy.")
                                isLoggedIn = true
                            case .failure(let err):
                                print("Hello?")
                                print("user login request failed with error: \(err)")
                                incorrectLogin = "Invalid login credentials given."
                            }
                        }
                }) {
                    Text("Sign In")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.white)
                        .cornerRadius(15.0)
                } //: BUTTON
                Spacer()
                
                Text(incorrectLogin)
                    .foregroundColor(Color.red)
                    .padding()
                    
                Button(action: {
                    forgotPassword = true
                }) {
                    Text("Forgot password")
                        .foregroundColor(Color.white)
                        .padding()
                } //: Button
                .padding(-5)
                .sheet(isPresented: $forgotPassword) {
                    ForgotPasswordView()
                }
                
                Button(action: {
                    newAccount = true
                }) {
                    Text("Don't have an account? Sign up")
                        .foregroundColor(Color.white)
                        .padding()
                } //: Button
                .padding(.bottom, 30)
                .sheet(isPresented: $newAccount) {
                    NewAccountView()
                }
            } //: VSTACK
        } //: ZSTACK
    }
}

// MARK: - PREVIEW
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewDevice("iPhone 12 Pro")
            .environmentObject(User(sampleUser: ""))
    }
}
