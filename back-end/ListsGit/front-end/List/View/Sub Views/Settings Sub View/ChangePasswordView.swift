//
//  ChangePasswordView.swift
//  List
//
//  Created by Michael Kilgore on 9/12/21.
//

import SwiftUI

struct ChangePasswordView: View {
    // MARK: - PROPERTY
    
    @EnvironmentObject var BackgroundColors: BackgroundColors
    @AppStorage("CustomColorActive") var customColor: Bool = false
    
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
            
            Text("To change your password, logout and click the forgot password button on the login view.")
                .padding()
        }
    }
}

// MARK: - PREVIEW
struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
            .environmentObject(BackgroundColors())
    }
}
