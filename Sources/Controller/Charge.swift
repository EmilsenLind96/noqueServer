//
//  Charge.swift
//  HelloKituraPackageDescription
//
//  Created by Emil Lind on 12/02/2018.
//

import Foundation
import LoggerAPI



public enum StripeError: String, Error {
    case parseError = "ParseError"
    case amountToLow = "AmountToLow"
    case invalidSourceID = "InvalidSourceID"
    case dataConversionError = "DataConversionError"
    case internalServerError = "InternalServerError"
    case stripeAPIError = "StripeAPIError"
}

public class StripeCharge {
    public var id: String?
    public var amount: Int
    public var paid: Bool
    public var description: String?
    public var currency: String
    public var source: String
    public var venueID: String
    
    public required init(amount: Int, currency: String, source: String, venueID: String) {
        self.amount = amount
        self.currency = currency
        self.source = source
        self.paid = false
        self.venueID = venueID
    }
    
    private func updateValues(json: [String: Any]) throws {
        guard let isPaid = json["paid"] as? Bool else {
            throw ServerErrorStruct.init(statusCode: .internalServerError, localizedDescription: "Failed to update values")
        }
        self.paid = isPaid
    }
    

    
    public func attemptCharge(completion: @escaping (StripeCharge?, ServerErrorStruct?) -> Void) {
        guard let data = "amount=\(self.amount)&currency=\(self.currency)&source=\(self.source)".data(using: String.Encoding.ascii, allowLossyConversion: false) else {
            completion(nil, ServerErrorStruct(statusCode: .internalServerError, localizedDescription: "Failed to create charge data"))
            return
        }
        Stripe.makeStripeRequest(.charge, data: data) { (serverError, json) in
            guard serverError == nil else {
                completion(nil, serverError!)
                return
            }
            
            do {
                try self.updateValues(json: json!)
                completion(self, nil)
            } catch let error as ServerErrorStruct{
                completion(nil, error)
            } catch {
                completion(nil, ServerErrorStruct.init(statusCode: .internalServerError, localizedDescription: "Failed to update values"))
            }
            
            
        }
    }
}
