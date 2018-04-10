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
            if header.key == "orderID" {
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
    }
    
    public func received(message: Data, from: WebSocketConnection) {
        Log.info("something happened")
    }
    public func received(message: String, from: WebSocketConnection) {
        Log.info("something happened")
    }
    

    public func notifyClient(updatableOrder: UpdatableOrder) {
        guard let listeningClient = clientConnections[updatableOrder.id] else {
            Log.info("Should do push to clients subscribed to this orderID"); return
        }
        do {
            let data = try JSONEncoder().encode(updatableOrder)
            listeningClient.send(message: data)
        } catch {
            Log.error("\(error)")
        }
    }
        
        
}
