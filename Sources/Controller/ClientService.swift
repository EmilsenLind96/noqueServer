//
//  OrderService.swift
//  Controller
//
//  Created by Emil Lind on 08/04/2018.
//

//
//  OrderService.swift
//  HelloKituraPackageDescription
//
//  Created by Emil Lind on 05/02/2018.
//

import Foundation
import KituraWebSocket
import LoggerAPI
import Dispatch

protocol OrderServiceDelegate {
    func changeInOrderStatus(byVenue venueID: String, order: UpdatableOrder)
}

public class ClientService: WebSocketService{
    
    private init() {}
    
    static let instance = ClientService()
    
    
//    private let workerQueue = DispatchQueue(label: "worker")
//    
//    public func execute(_ block: (() -> Void)) {
//        workerQueue.sync {
//            block()
//        }
//    }
    
    
    var clientConnections = [String: WebSocketConnection]()
    
    public func connected(connection: WebSocketConnection) {
        for header in connection.request.headers {
            if header.key.lowercased() == "x-orderID".lowercased() {
                let orderID = header.value[0]
                clientConnections[orderID] = connection
                return
            }
        }
        connection.close(reason: WebSocketCloseReasonCode.extensionMissing, description: "No orderID in header, which is required")
    }
    
    public func disconnected(connection: WebSocketConnection, reason: WebSocketCloseReasonCode) {
        guard let clientConnection = clientConnections.first(where: {$0.value.id == connection.id}) else {
            Log.error("The client that tried to disconnect, were not found in the clientConnectionsArray")
            return
        }
        clientConnections.removeValue(forKey: clientConnection.key)
        Log.info("client with clientID \(connection.id) disconnected")
    }
    
    public func received(message: Data, from: WebSocketConnection) {
        Log.info("something happened")
    }
    public func received(message: String, from: WebSocketConnection) {
        clientConnections[message] = from
    }
    

    public func notifyClient(withDeviceID: String?, updatableOrder: UpdatableOrder) {
        guard let listeningClient = clientConnections[updatableOrder.id] else {
            guard let deviceID = withDeviceID else {
                Log.info("Can't do push to client, as he provided no deviceID, perhaps it should check if the user registers to the order at a later stage?"); return
            }
            let orderStatus: String
            // TODO:: DO push to client
            switch updatableOrder.status {
            case .Handled:
                orderStatus = "Færdig"
            case .Preparing:
                orderStatus = "Forbereder"
            case .AwaitingPickup:
                orderStatus = "Klar til afhentning"
            case .AwaitingDelivery:
                orderStatus = "Klar til levering"
            case .AwaitingPayment:
                orderStatus = "Mangler betaling"
            default:
                return
            }
            PushNotifications.sendMessage(withMessage: "Your order with id: \(updatableOrder.id) has changed status to \(orderStatus)", target: .init(deviceIds: [deviceID]), payload: ["id": updatableOrder.id, "status": updatableOrder.status.rawValue]) { (response) in
                Log.info("Status code: \(response.statusCode)")
                Log.info("Tried to send push message")
                guard let data = response.data else {return}
                Log.info(data.description)
            }
            Log.error("wtf")
            return
        }
        do {
            let data = try JSONEncoder().encode(updatableOrder)
            listeningClient.send(message: data)
        } catch {
            Log.error("\(error)")
        }
    }
        
    
}
