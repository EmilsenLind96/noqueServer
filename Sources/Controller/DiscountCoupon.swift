//
//  DiscountCoupon.swift
//  noque
//
//  Created by Emil Lind on 13/04/2018.
//  Copyright © 2018 Emil Lind. All rights reserved.
//

import Foundation

class DiscountCoupon: Codable {
    public private(set) var id: String
    // If nil, it works for all venues
    public private(set) var venueID: String?
    public private(set) var discount: Double
    
    private init(id: String, venueID: String?, discount: Double) {
        self.id = id
        self.venueID = venueID
        self.discount = discount
    }
}
