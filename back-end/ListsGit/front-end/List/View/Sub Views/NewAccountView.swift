//
//  NewAccountView.swift
//  List
//
//  Created by Michael Kilgore on 9/10/21.
//

import SwiftUI

struct NewAccountView: View {
    // MARK: - PROPERTY
    
    @State var Email = ""
    @State var Password = ""
    @State var PasswordConfirmed = ""
    @State var Username = ""
    @State var failed = ""
    @State var failedColor: Color = Color.red
    
    // MARK: - BODY
    var body: some View {
        VStack {
            Text("Create an account")
            InputField(defaultText: "Username", text: $Username)
                .padding(.vertical, 10)
            InputField(defaultText: "Email", text: $Email)
                .padding(.vertical, 10)
            SecureInputField(defaultText: "Password", text: $Password)
                .padding(.vertical, 10)
            SecureInputField(defaultText: "Reenter password", text: $PasswordConfirmed)
                .padding(.vertical, 10)
            Button(action: {
                print("Here")
                if (validEmail(text: Email) && validPassword(text: Password) && passwordsMatch(one: Password, two: PasswordConfirmed) && validName(text: Username)) {
                    NetworkManager.shared.createNewUser(for: Email, username: Username, password: Password) { result in
                        switch result {
                        case .success(let resp):
                            switch POST(rawValue: resp.response) {
                            case .SUCCESS:
                                failedColor = Color.green
                                failed = "Click the link emailed to you to activate your account."
                            case .INVALID_REQUEST:
                                failedColor = Color.red
                                failed = "The email given is already registered in the system."
                            default:
                                failedColor = Color.yellow
                                failed = "A server error occurred, try again in 30 seconds."
                            }
                        case .failure(let err):
                            print("new user request failed with error: \(err)")
                            failedColor = Color.red
                            failed = "The account under that email already exists."
                        }
                    }
                    
                } else {
                    failedColor = Color.red
                    failed = "One of the given fields entered was invalid. Password must contain 8-15 characters and contain one number and one character"
                }
            }) {
                Text("Create new account")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.white)
                    .cornerRadius(15.0)
            } //: BUTTON
            
            Text(failed)
                .foregroundColor(failedColor)
        } //: VSTACK
        .padding()
    }
}

// MARK: - PREVIEW
struct NewAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NewAccountView()
    }
}
