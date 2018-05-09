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

public class ServiceController {
    
   public init(router: Router) {
        router.all("api/v1/push/*", middleware: BodyParser())
        router.all("api/v1/push/", handler: handlePush)
    }
    
    private func handlePush(request: RouterRequest, response: RouterResponse, next: @escaping () -> ()) {
        do {
            let json = try getJSONBody(fromRequest: request)
            guard let message = json["message"] as? String else {throw ServerErrorStruct(statusCode: .badRequest, localizedDescription: "The body could not be parsed as JSON, and did not inclue a message")}
            PushNotifications.sendMessage(withMessage: message, target: .init(platforms: [PushNotifications.Target.Platform.ios]), payload: json) { (pushResponse) in
                do {
                    try response.send(json: pushResponse.data!).end()
                } catch {
                    Log.error("Internal Communications error")
                }
            }
        } catch let error as ServerErrorStruct {
            try? response.status(error.statusCode).send(error.localizedDescription).end()
            return
        } catch {
            Log.error("Internal communications error!")
        }
    }
   
    private func getJSONBody(fromRequest request: RouterRequest) throws -> [String:Any] {
        guard let body = request.body?.asJSON else {
            throw ServerErrorStruct(statusCode: .badRequest, localizedDescription: "The body could not be parsed as JSON")
        }
        return body
    }
}
//

