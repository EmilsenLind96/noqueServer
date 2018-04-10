//
//  PaymentService.swift
//  noque-serverPackageDescription
//
//  Created by Emil Lind on 08/04/2018.
//


import Foundation
import LoggerAPI
import HeliumLogger

public class PaymentService {
    private init() {}
    
    static func handleApplePayPayment(venueID: String, requestBody: [String: Any], completion: @escaping (String?, ServerErrorStruct?) ->  Void) {
        guard let amount = requestBody["amount"] as? Int, let currency = requestBody["currency"] as? String, let source = requestBody["source"] as? String else {
            completion(nil, ServerErrorStruct(statusCode: .badRequest, localizedDescription: "Request body is not valid"))
            return
        }
        
        do {
            let orderID = try VenueService.instance.createUniqueOrderID(forVenue: venueID)
            StripeCharge(amount: amount, currency: currency, source: source, venueID: venueID).attemptCharge { (charge, serverError) in
                guard serverError == nil else {
                    completion(nil, serverError!)
                    return
                }
            }
            completion(orderID, nil)
        } catch let error as ServerErrorStruct {
            completion(nil, error)
        }  catch {
            completion(nil, ServerErrorStruct.init(statusCode: .internalServerError, localizedDescription: error.localizedDescription))
        }
    }
    
    
}


