//
//  ForgotPasswordView.swift
//  List
//
//  Created by Michael Kilgore on 10/4/21.
//

import SwiftUI

struct ForgotPasswordView: View {
    // MARK: - PROPERTY
    
    @State var Email: String = ""
    @State var resp: String = ""
    @State var respColor: Color = Color.green
    @State var buttonTag: String = "Send Email"
    
    // MARK: - BODY
    var body: some View {
        Text("Forgot Password")
        
        InputField(defaultText: "Email", text: $Email)
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
        
        Text(resp)
            .foregroundColor(respColor)
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
        
        Button(action: {
            if Email != "" {
                NetworkManager.shared.forgotPassword(for: Email) { result in
                    switch result {
                    case .success(let resp):
                        print(resp)
                        self.resp = "If there is an account under the given email, then an email was sent asking you for a new password."
                        self.respColor = Color.green
                    case .failure(let err):
                        print("new user request failed with error: \(err)")
                        self.resp = "An error occurred, press the button to resend the request."
                        self.respColor = Color.red
                    }
                    buttonTag = "Resend Email"
                }
            }
        }) {
            Text(buttonTag)
                .font(.headline)
                .foregroundColor(.black)
                .padding()
                .frame(width: 300, height: 50)
                .background(Color.white)
                .cornerRadius(15.0)
        } //: BUTTON
        
    } //: BODY
}

// MARK: - PREVIEW
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
