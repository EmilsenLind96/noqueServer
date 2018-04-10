//
//  Product.swift
//  PerfectAPI
//
//  Created by Emil Lind on 03/02/2018.
//

import Foundation

struct SecondaryPrice: Codable {
    public private(set) var amountToQualify: Int
    public private(set) var price: Double
}

class Product: Codable {
    // The id for the product, assigned on creation by the backend - cannot be nil
    public private(set) var id: String
    // The product name - cannot be nil
    public private(set) var name: String
    // The product price
    public private(set) var price: Double
    // Secondary Price, eg. 2 for 99,-
    public private(set) var secondaryPrice: SecondaryPrice?
    // If the product is at an discounted price
    public private(set) var isDiscounted: Bool
    // Product description
    public private(set) var description: String?
    // The product imageURL, if there has been assigned any
    public private(set) var imageURL: String?
    // The category, which the product is belonging to. Should change to be more memory efficient though, as category is a struct, so every product has its own category copy!
    public private(set) var category: Category
    
    public private(set) var amountSelected: Int
    
    
    init(id: String, name: String, price: Double, secondaryPrice: Dictionary<String, Any>?, isDiscounted: Bool?, productDescription: String, category: Category, imageURL: String?, amountSelected: Int) {
        self.id = id
        self.name = name
        self.price = price
        self.isDiscounted = isDiscounted ?? false
        self.description = productDescription
        self.category = category
        self.imageURL = imageURL
        self.amountSelected = amountSelected
        guard let amountToQualify = secondaryPrice?["amountToQualify"] as? Int, let price = secondaryPrice?["price"] as? Double else {return}
        self.secondaryPrice = SecondaryPrice(amountToQualify: amountToQualify, price: price)
    }
}
