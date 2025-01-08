//
//  TestApiView.swift
//  GreencheckF
//

import SwiftUI

struct TestApiView: View {
    let api = CheckerApi()
    
    @State private var inputValue = ""
    @State private var result = false
    
    var body: some View {
        VStack {
            TextField("Enter something", text: $inputValue)
                .padding()
            Button("Check") {
                result = api.checkValue(inputValue)
            }
            Text("Result: \(result ? "true" : "false")")
        }
        .padding()
    }
}
