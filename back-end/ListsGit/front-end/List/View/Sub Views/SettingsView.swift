//
//  SettingsView.swift
//  List
//
//  Created by Michael Kilgore on 9/9/21.
//

import SwiftUI
import SwiftKeychainWrapper

struct SettingsView: View {
    // MARK: - PROPERTY
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool?

    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var user: User
        
    @Binding var offset: CGFloat
    
    @State var logoutAlert: Bool = false
    @State var deleteAccountAlert: Bool = false
        
    //COLOR
    @AppStorage("CustomColorActive") var customColor: Bool = false
    private let defaults = UserDefaults.standard
    
    @State var red: Double = 0.0
    @State var green: Double = 0.0
    @State var blue: Double = 0.0
    @EnvironmentObject var BackgroundColors: BackgroundColors
    
    // MARK: - FUNCTION
    func actionSheet() {
        let msg: String = user.userInfo.email
        let activityVC = UIActivityViewController(activityItems: [msg], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
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
                
                ScrollView(.vertical, showsIndicators: false) {
                    NavigationLink(destination: ChangeNameView()) {
                        SettingsListItemView(text: "Username", value: user.userInfo.username)
                            .cornerRadius(20)
                    }
                    .padding(.top, 20)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                    
                    //password
                    NavigationLink(destination: ChangePasswordView()) {
                        SettingsListItemView(text: "Password", value: "********")
                            .cornerRadius(20)
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                    //email
                    Button(action: actionSheet) {
                        ZStack {
                            colorScheme == .dark ? Color.black : Color.white
                            HStack {
                                Text("email")
                                Spacer()
                                Text("\(user.userInfo.email)")
                                Image(systemName: "square.and.arrow.up")
                            }
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .padding()
                        } //: ZSTACK
                        .cornerRadius(20)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                    
                    GroupBox {
                        VStack {
                            Toggle(isOn: $customColor) {
                                if customColor {
                                    Text("Activated".uppercased())
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.green)
                                } else {
                                    Text("Activate".uppercased())
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.secondary)
                                }
                            }
                            .padding()
                            .background(
                              Color(UIColor.tertiarySystemBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            )
                            
                            Text("Adjust the nobs for a custom background color.")
                                .padding()
                            
                            Capsule()
                                .fill(Color(red: Double(red), green: Double(green), blue: Double(blue)))
                                .frame(width: 200, height: 100, alignment: .center)

                            
                            VStack {
                                HStack {
                                    Text("RED     ")
                                    Slider(value: $red)
                                      .padding(.horizontal)
                                }
                                HStack {
                                    Text("GREEN")
                                    Slider(value: $green)
                                      .padding(.horizontal)
                                }
                                HStack {
                                    Text("BLUE   ")
                                    Slider(value: $blue)
                                      .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                            
                            Button(action: {
                                defaults.set(red, forKey: "red")
                                defaults.set(green, forKey: "green")
                                defaults.set(blue, forKey: "blue")
                                
                                BackgroundColors.red = red
                                BackgroundColors.green = green
                                BackgroundColors.blue = blue
                            }) {
                                Text("Save Changes".uppercased())
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding()
                                    .background(
                                        Capsule()
                                            .fill(Color.green)
                                    )
                            }
                        } //: VSTACK
                    } //GROUP BOX
                    .padding()
                    
                    
                    Text("Lists")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                    
                    ForEach(Array(user.lists.enumerated()), id: \.0) { index, element in
                        ZStack {
                            colorScheme == .dark ? Color.black : Color.white
                            SettingsShoppingListsItemView(listIndex: index)
                                .padding()
                        }
                        .cornerRadius(20)
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                    
                    Button(action: {
                        logoutAlert = true
                    }) {
                        Text("Logout")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 300, height: 50)
                            .background(Color.green)
                            .cornerRadius(15.0)
                    } //: BUTTON
                    .padding(.vertical, 20)
                    .alert(isPresented: $logoutAlert) {
                        Alert(
                            title: Text("Are you sure you want to logout?"),
                            message: Text(""),
                            primaryButton: .destructive(Text("Logout")) {
                                //Have yes no logout confirmation then empty keychain data, change connection email to "", and empty service data.
                                //func logOut(email: String) {
                                //service.logOut(email: service.userData.email)
                                
                                KeychainWrapper.standard.removeObject(forKey: "email")
                                KeychainWrapper.standard.removeObject(forKey: "password")
                                
                                //clearDeviceToken
                                NetworkManager.shared.clearDeviceToken(for: user.userInfo.email, password: user.userInfo.password) { result in
                                    switch result {
                                    case .success(let resp):
                                        print("device token wiped from server with response: \(resp).")
                                    case .failure(let err):
                                        print("failed with error: \(err)")
                                    }
                                }
                                self.isLoggedIn = false

                            },
                            secondaryButton: .cancel()
                        )
                    } //: ALERT
                    
                    Button(action: {
                        deleteAccountAlert = true
                    }) {
                        Text("Delete Account")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 300, height: 50)
                            .background(Color.red)
                            .cornerRadius(15.0)
                    } //: BUTTON
                    .alert(isPresented: $deleteAccountAlert) {
                        Alert(
                            title: Text("Are you sure you want to delete your account?"),
                            message: Text("This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete")) {
                                //Send some sort of alert to delete the account where user has to enter "DELETE" to delete the user then empty the service data and send user to login page.
                                //deleteAccount(email: service.userData.email) TODO
                                //user.userInfo.email = ""
                                //user.userInfo.username = ""
                                //user.userInfo.password = ""
                                //user.userInfo.deviceToken = ""
                                //user.userInfo.invites = []
                                //user.lists = []
                                
                                isLoggedIn = false
                            },
                            secondaryButton: .cancel()
                        )
                    } //: ALERT
                } //: SCROLL
                .navigationBarTitle("Settings", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Text("")
                            Button(action: {
                                //update environmentlist here\
                                withAnimation {
                                    offset = UIScreen.screenWidth
                                }
                            }) {
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.black)
                            }
                            .foregroundColor(.black)
                        }
                    }
                } //: TOOLBAR
            } //: ZSTACK
            .onAppear(perform: {
                
                let savedRed = defaults.double(forKey: "red")
                let savedGreen = defaults.double(forKey: "green")
                let savedBlue = defaults.double(forKey: "blue")
                
                red = Double(savedRed)
                green = Double(savedGreen)
                blue = Double(savedBlue)
                
            })
        } //: NAVIGATIONVIEW
        .hiddenNavigationBarStyle()
    }
}

// MARK: - PREVIEW
struct SettingsView_Previews: PreviewProvider {
    @State static var offset: CGFloat = UIScreen.screenWidth
    
    static var previews: some View {
        SettingsView(offset: $offset)
            .environmentObject(User(sampleUser: ""))
            .environmentObject(BackgroundColors())
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}
