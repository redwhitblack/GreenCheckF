//
//  SignUpView.swift
//  GreencheckF
//

import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            Button("Sign Up") {
                // Logic here
            }
        }
        .padding()
    }
}
