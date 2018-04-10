//
//  Category.swift
//  PerfectAPI
//
//  Created by Emil Lind on 03/02/2018.
//

import Foundation

enum CategoryType: Int, Codable {
    case Food
    case Drinks
    case Other
}

struct Category: Codable {
    public private(set) var categoryName: String
    public private(set) var categoryID: String
    public private(set) var iconName: String?
    public private(set) var categoryType: CategoryType
}

