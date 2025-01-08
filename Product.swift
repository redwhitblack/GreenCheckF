//
//  Product.swift
//  GreencheckF
//

import Foundation

/// If you need a separate model for SwiftUI or other logic:
struct Product {
    var id: Int64?
    var barcode: String
    var name: String
    var details: String
    var createdAt: String
    var category: String
    var isFavorite: Bool
}
