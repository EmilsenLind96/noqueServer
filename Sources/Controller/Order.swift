//
//  Order.swift
//  Controller
//
//  Created by Emil Lind on 08/04/2018.
//

import Foundation

public enum OrderStatus: Int, Codable {
    case Placed
    case Accepted
    case Preparing
    case AwaitingDelivery
    case AwaitingPickup
    case Handled
    case AwaitingPayment
}


struct DeliveryMethod: Codable {
    enum DeliveryType: Int, Codable {
        case pickupDelivery
        case tableDelivery
        case specialDelivery
    }
    public private(set) var deliveryType: DeliveryType
    public private(set) var deliveryDetails: String?
}


enum PaymentMethod: Int, Codable {
    case MobilePay
    case ApplePay
    case CreditCard
    case NotPayed
    case InternallyHandled
}

class Order: Codable {
    
    // This ID is generated server-side
    public private(set) var id: String
    // This is the total pay, that has been payed - or should be paid, depending on the PaymentMethod.
    public private(set) var totalPrice: Double
    // This is the tips given by the client on the order. Can be optional.
    public private(set) var tips: Double?
    // This is the payment method, which the client has chosen to utilize.
    public private(set) var paymentMethod: PaymentMethod
    // The deliveryMethod
    public private(set) var deliveryMethod: DeliveryMethod
    // The products that has been ordered
    public private(set) var orders: [Product]
    
    public var venueId: String?
    
    public private(set) var comments: String?
    // If the name of the customer is provided, it will be noted on the order both for the venue and client.
    public private(set) var customerName: String?
    // This option is mostly for venues where their staff are the ones taking the order, and their name will then be attached to every order they take
    public private(set) var takenBy: String?
    
    public private(set) var date: String
    
    // The order status, when sent by the client the status is .Placed, indicating that the order has not yet been processed by the backend. It is up to the backend to adjust the value according to the updates given by the local venue client
    public var status: OrderStatus
}

public struct UpdatableOrder: Codable {
    public private(set) var id: String
    public var status: OrderStatus
}

