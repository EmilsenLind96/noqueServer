//
//  Product.swift
//  PerfectAPI
//
//  Created by Emil Lind on 03/02/2018.
//

import Foundation

class PurchasedProduct: Codable {
    // The id for the product, assigned on creation by the backend - cannot be nil
    public private(set) var id: String
    // The product name - cannot be nil
    public private(set) var name: String
    // The product price
    public private(set) var amountSelected: Int
    
    public private(set) var totalPrice: Double
    // Product description
    public private(set) var description: String?
    // The category, which the product is belonging to. Should change to be more memory efficient though, as category is a struct, so every product has its own category copy!
    public private(set) var category: Category
    
    private init(id: String, name: String, amountSelected: Int, totalPrice: Double, description: String?, category: Category) {
        self.id = id
        self.name = name
        self.amountSelected = amountSelected
        self.totalPrice = totalPrice
        self.description = description
        self.category = category
    }
}
