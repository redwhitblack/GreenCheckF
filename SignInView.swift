//
//  SignInView.swift
//  GreencheckF
//

import SwiftUI

struct SignInView: View {
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            Button("Sign In") {
                // Logic here
            }
        }
        .padding()
    }
}
