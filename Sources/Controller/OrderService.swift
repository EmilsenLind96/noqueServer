//
//  OrderService.swift
//  Controller
//
//  Created by Emil Lind on 08/04/2018.
//

import Foundation
import LoggerAPI
import Dispatch

public class OrderService {
    
    private init() {}
    
    private let workerQueue = DispatchQueue(label: "worker")
    
    public func execute(_ block: (() -> Void)) {
        workerQueue.sync {
            block()
        }
    }
    
    static let instance = OrderService()
    
    var orders = [String: [Order]]()
    
    
        func changeInOrderStatus(byVenue venueID: String, order: UpdatableOrder) {
            guard let orders = orders[venueID] else {Log.error("Could not find any orders for the venue, that requested an update to an order"); return}
            guard let updatableOrder = orders.first(where: {$0.id == order.id}) else {Log.error("Could not find the order that needed to be updated"); return}
            updatableOrder.status = order.status
            
            ClientService.instance.notifyClient(updatableOrder: order)
}
}
        
        

