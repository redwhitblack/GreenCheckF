//
//  AddItemView.swift
//  GreencheckF
//

import SwiftUI

struct AddItemView: View {
    @State private var newItem = ""
    
    var body: some View {
        VStack {
            TextField("Enter new item", text: $newItem)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Add") {
                print("Adding: \(newItem)")
            }
            .padding()
        }
    }
}
