//
//  Venue.swift
//  Application
//
//  Created by Emil Lind on 14/02/2018.
//

import Foundation

struct ConnectedClient {
    public private(set) var connectionID: String
}


class Venue {
    public private(set) var id: String
    public private(set) var nextOrderID: Int
    public private(set) var connectedClients: [ConnectedClient]
    public private(set) var isRecievingOrders: Bool
    
    init(id: String, connectionID: String) {
        self.id = id
        nextOrderID = 0
        connectedClients = [ConnectedClient(connectionID: connectionID)]
        isRecievingOrders = true
    }
    
    public func getNewOrderId() -> String {
        let nextOrderIDString = String(nextOrderID)
        nextOrderID = nextOrderID + 1
        return nextOrderIDString
    }
    
    public func addClient(_ client: ConnectedClient) {
        connectedClients.append(client)
        isRecievingOrders = true
    }
    
    public func hasClient(withID id: String) -> Bool {
       return connectedClients.contains(where: {$0.connectionID == id})
    }
    
    public func removeClient(withID id: String) {
        let index = connectedClients.index(where: {$0.connectionID == id})
        connectedClients.remove(at: index!)
        if connectedClients.count == 0 {
            isRecievingOrders = false
        }
    }
}
