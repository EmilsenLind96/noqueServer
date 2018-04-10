//
//  Stripe.swift
//  HelloKituraPackageDescription
//
//  Created by Emil Lind on 12/02/2018.
//
import Foundation
import KituraNet
import Kitura
import LoggerAPI

public enum StripeHTTPErrorCode: String, Swift.Error {
    
    /// Everything worked as expected
    case OK = "OK",
    
    /// The request was unacceptable, often due to missing a required parameter
    badRequest = "Bad Request",
    
    /// No valid API key provided.
    unauthorized = "Unauthorized",
    
    /// The parameters were valid but the request failed
    requestFailed = "Request Failed",
    
    /// The requested resource doesn't exist
    notFound = "Not Found",
    
    /// The request conflicts with another request (perhaps due to using the same idempotent key)
    conflict = "Conflict",
    
    /// Too many requests hit the API too quickly. We recommend an exponential backoff of your requests
    tooManyRequests = "Too Many Requests",
    
    /// Something went wrong on Stripe's end.
    serverError = "Server Error"
    
    
    public static func fromCode(_ code: Int) -> StripeHTTPErrorCode {
        switch code {
        case 200:
            return .OK
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 402:
            return .requestFailed
        case 404:
            return .notFound
        case 409:
            return .conflict
        case 429:
            return .tooManyRequests
        default:
            return .serverError
        }
    }
}

enum StripeRequestType {
    case charge
}

struct Stripe {
    // API Key
    public static var apiKey: String = "sk_test_AcjJ7WKV1nGeJZhN06BfU2sI"
    
    // API Server
    public static let baseServerURL: String = "https://api.stripe.com/v1"
}

extension Stripe {
    static func makeStripeRequest(_ type: StripeRequestType, data: Data, completion: @escaping (ServerErrorStruct?, [String: Any]?) -> Void) {
        switch type {
        case .charge:
            guard let url = URL.init(string: baseServerURL + "/charges") else {
                completion(ServerErrorStruct(statusCode: .internalServerError, localizedDescription: "Charge URL could not be created"), nil)
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpBody = data
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                guard error == nil else {
                    completion(ServerErrorStruct.init(statusCode: .internalServerError, localizedDescription: error!.localizedDescription), nil)
                    return
                }
                let response = response as! HTTPURLResponse
                let stripeResponse = StripeHTTPErrorCode.fromCode(response.statusCode)
                if stripeResponse != StripeHTTPErrorCode.OK {
                    completion(ServerErrorStruct(statusCode: .notAcceptable, localizedDescription: "Stripe API response: \(stripeResponse.rawValue)"), nil)
                } else {
                    guard let data = data else {
                        completion(ServerErrorStruct.init(statusCode: .internalServerError, localizedDescription: "Could not unwrap data, even through StripeResponse is OK"), nil)
                        return
                    }
                    
                    do {
                        let JSON = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
                        completion(nil, JSON)
                    } catch {
                        completion(ServerErrorStruct.init(statusCode: .internalServerError, localizedDescription: error.localizedDescription), nil)
                    }
                }
            }).resume()
        }
    }
}
