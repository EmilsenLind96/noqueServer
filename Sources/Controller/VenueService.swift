//
//  VenueService.swift
//  noque-serverPackageDescription
//
//  Created by Emil Lind on 08/04/2018.
//

//
//  VenueService.swift
//  Application
//
//  Created by Emil Lind on 14/02/2018.
//


import Foundation
import KituraWebSocket
import LoggerAPI

class VenueService: WebSocketService {
    private init() {}
   
    static let instance = VenueService()
    
    public var venueDetails: [Venue] = [Venue]()
    private var venueConnections = [String: WebSocketConnection]()
    
    public func connected(connection: WebSocketConnection) {
        for header in connection.request.headers {
            if header.key.lowercased() == "x-venueID".lowercased() {
                Log.info("\(header.value[0]) connected")
                let venueID = header.value[0]
                if let venueDetail = venueDetails.first(where: {$0.id == venueID}) {
                    venueDetail.addClient(ConnectedClient(connectionID: connection.id))
                } else {
                    let venue = Venue(id: venueID, connectionID: connection.id)
                    venueDetails.append(venue)
                }
                venueConnections[connection.id] = connection
                return
            }
        }
        connection.close(reason: WebSocketCloseReasonCode.extensionMissing, description: "No venueID in header, which is required")
    }
    
    public func disconnected(connection: WebSocketConnection, reason: WebSocketCloseReasonCode) {
        venueConnections[connection.id] = nil
        guard let venue = venueDetails.first(where: {$0.hasClient(withID: connection.id)}) else {return}
        venue.removeClient(withID: connection.id)
        if venue.connectedClients.count == 0 {
            let index = venueDetails.index(where: {$0.id == venue.id})
            venueDetails.remove(at: index!)
        }
    }
    
    public func received(message: Data, from: WebSocketConnection) {
        for header in from.request.headers {
            if header.key.lowercased() == "x-venueID".lowercased() {
                let venueID = header.value[0]
                do {
                    let updateableOrder = try JSONDecoder().decode(UpdatableOrder.self, from: message)
                    OrderService.instance.changeInOrderStatus(byVenue: venueID, order: updateableOrder)
                } catch {
                    Log.error("Could not decode message send by venue")
                }
                return
            }
        }
        
    }
    
    func received(message: String, from: WebSocketConnection) {
        
    }
}

extension VenueService {
    public func createUniqueOrderID(forVenue venueID: String) throws -> String {
        guard let venueIndex = venueDetails.index(where: {$0.id == venueID}) else {
            throw ServerErrorStruct(statusCode: .serviceUnavailable, localizedDescription: "Det lader til at stedet er holdt op med at tage imod bestillinger lige nu :(")
        }
        let venue = venueDetails[venueIndex]
        if venue.isRecievingOrders {
            return venue.getNewOrderId()
        } else {
            throw ServerErrorStruct(statusCode: .serviceUnavailable, localizedDescription: "Det lader til at stedet er holdt op med at tage imod bestillinger lige nu :(")
        }
    }
    
    public func notifyVenue(_ venueID: String, withNew order: Order) {
        guard let venueIndex = venueDetails.index(where: {$0.id == venueID}) else {
            Log.error("Fatal error, must never happen")
            return
        }
        let venue = venueDetails[venueIndex]
        
        do {
            let data = try JSONEncoder().encode(order)
            for client in venue.connectedClients {
                venueConnections[client.connectionID]?.send(message: data)
            }
        } catch {
            for client in venue.connectedClients {
                venueConnections[client.connectionID]?.send(message: "There is a new order for you, but we could not send it. You should download all orders again!")
            }
        }
    }
    
    
}
