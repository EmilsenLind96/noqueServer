//
//  OrderController.swift
//  noque-serverPackageDescription
//
//  Created by Emil Lind on 08/04/2018.
//


import Foundation
import Kitura
import LoggerAPI
import KituraWebSocket
import KituraNet

public class OrderController {
    
   public init(router: Router) {
        router.all("api/v1/order/", handler: handleOrder)
        router.all("api/v1/order/new/*", middleware: BodyParser())
        router.all("api/v1/order/new/", handler: [handleNewOrder])
        router.all("api/v1/order/new/:venueID", handler: [handlePostNewOrder])
        router.all("api/v1/order/:venueID", handler: [handleGetOrder, handlePostOrder])
    
        WebSocket.register(service: ClientService.instance, onPath: "client")
        WebSocket.register(service: VenueService.instance, onPath: "venue")
    }
    
    private func handleOrder(request: RouterRequest, response: RouterResponse, next: @escaping () -> ()) {
        do {
            try response.status(.badRequest).send("No venueID in URL: Use: /api/v1/order/:venueID").end()
        } catch {
            Log.error("Internal communications error!")
            return
        }
    }

    private func handleNewOrder(request: RouterRequest, response: RouterResponse, next: @escaping () -> ()) {
        do {
            try response.status(.badRequest).send("No venueID in URL: Use: /api/v1/order/new/:venueID").end()
        } catch {
            Log.error("Internal communications error!")
            return
        }
    }

    
    // Before a client is allowed to do any form of payment, it will need to ensure that the venue is actually still taking orders. The payload should have payment information, and if the paymentmethod is .ApplePay or .CreditCard the server will do the transaction before sending back an orderNumber. If the paymentMethod is .MobilePay, the server will send back an ordernumber if possible.
    private func handlePostNewOrder(request: RouterRequest, response: RouterResponse, next: @escaping () -> ()) {
        do {
            if (request.method) != .post {
                next()
            } else {
                let venueID = request.parameters["venueID"]!
                do {
                    let paymentMethod = try getPaymentMethod(fromRequest: request)
                    switch paymentMethod {
                    case .ApplePay:
                        let body = try getJSONBody(fromRequest: request)
                        PaymentService.handleApplePayPayment(venueID: venueID, requestBody: body, completion: { (orderID, serverError) in
                            do {
                                guard serverError == nil else {
                                    try response.status(serverError!.statusCode).send(serverError!.localizedDescription).end()
                                    return
                                }

                                guard let orderID = orderID else {
                                    try response.status(.internalServerError).send("NEither an error or orderID were returned, fatal").end()
                                    return
                                }
                                try response.status(.OK).send(orderID).end()
                            } catch let error as ServerErrorStruct {
                                try? response.status(error.statusCode).send(error.localizedDescription).end()
                            } catch {
                                Log.error("Internal communications error")
                            }
                        })
                    case .MobilePay:
                        let orderID = try VenueService.instance.createUniqueOrderID(forVenue: venueID)
                        try response.status(.OK).send(orderID).end()
                    case .NotPayed:
                        let orderID = try VenueService.instance.createUniqueOrderID(forVenue: venueID)
                        try response.status(.OK).send(orderID).end()
                    default:
                        return
                    }
                } catch let error as ServerErrorStruct {
                    try? response.status(error.statusCode).send(error.localizedDescription).end()
                    return
                } catch {
                    Log.error("Internal communications error!")
                }
            }
        }
    }

    // This method is to be solely by the venue. It simply returns all orders which has been made to the venue with the ID in the payload.
    private func handleGetOrder(request: RouterRequest, response: RouterResponse, next: @escaping () -> ()) {
        if (request.method) != .get {
            next()
        } else {
            let venueID = request.parameters["venueID"]!
            do {
                let venueOrders = try getAllOrders(forVenue: venueID)
                try response.status(.OK).send(venueOrders).end()
            } catch let error as ServerErrorStruct {
                try? response.status(error.statusCode).send(error.localizedDescription).end()
                return
            } catch {
                Log.error("Internal communications error!")
                return
            }
        }
    }

    // This method is called by the clientSide, after an orderID has been provided.
    private func handlePostOrder(request: RouterRequest, response: RouterResponse, next: @escaping () -> ()) {
        if (request.method) != .post {
            next()
        } else {
            let venueID = request.parameters["venueID"]!
            do {
                let order = try createOrderObject(fromRequest: request)
                order.status = OrderStatus.Accepted
                postNewOrder(order: order, forVenue: venueID)
                try response.status(.OK).send(order).end()
            } catch let error as ServerErrorStruct {
                try? response.status(error.statusCode).send(error.localizedDescription).end()
            } catch {
                Log.error("Internal communications error!")
            }
        }
    }
}
//



extension OrderController {
    private func getAllOrders(forVenue venueID: String) throws -> [Order] {
        guard let venueOrders = OrderService.instance.orders[venueID], venueOrders.count != 0 else {
            throw ServerErrorStruct(statusCode: .noContent, localizedDescription: "There were no orders not completed for this venue")
        }
        return venueOrders
    }

    private func createOrderObject(fromRequest request: RouterRequest) throws -> Order {
        do {
            let order = try request.read(as: Order.self)
            return order
        } catch {
            throw ServerErrorStruct(statusCode: .partialContent, localizedDescription: "Could not create an Order object from the request body, check the model requirements.")
        }
    }

    private func postNewOrder(order: Order, forVenue venueID: String) {
        if OrderService.instance.orders[venueID] != nil {
            OrderService.instance.execute {
                OrderService.instance.orders[venueID]?.append(order)
                VenueService.instance.notifyVenue(venueID, withNew: order)
            }
        } else {
            OrderService.instance.execute {
                OrderService.instance.orders[venueID] = [order]
                VenueService.instance.notifyVenue(venueID, withNew: order)
            }
        }
    }

    private func getPaymentMethod(fromRequest request: RouterRequest) throws -> PaymentMethod {
        guard let rawValue = request.queryParameters["paymentMethod"] else {
            throw ServerErrorStruct(statusCode: .badRequest, localizedDescription: "There were no paymentMethod parameter found in the URL. Use: api/v1/order/new/:venueID?paymentMethod=INTEGER")
        }

        guard let int = Int(rawValue) else {
            throw ServerErrorStruct(statusCode: .badRequest, localizedDescription: "There were a paymentMethod parameter found in the URL, but it did not contain an integer, which is the the required value")
        }

        guard let paymentMethod = PaymentMethod(rawValue: int) else {
            throw ServerErrorStruct(statusCode: .badRequest, localizedDescription: "A PaymentMethod object could not be created from integer: \(rawValue), try with a value that fits the model")
        }
        return paymentMethod
    }

    private func getJSONBody(fromRequest request: RouterRequest) throws -> [String:Any] {
        guard let body = request.body?.asJSON else {
            throw ServerErrorStruct(statusCode: .badRequest, localizedDescription: "The body could not be parsed as JSON")
        }
        return body
    }

    
    
}

