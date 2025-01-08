//
//  SplashScreen.swift
//  GreencheckF
//

import SwiftUI

struct SplashScreen: View {
    @State private var showMainView = false
    
    var body: some View {
        if showMainView {
            MainUserView()
        } else {
            Text("Welcome to GreencheckF")
                .font(.largeTitle)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showMainView = true
                    }
                }
        }
    }
}
