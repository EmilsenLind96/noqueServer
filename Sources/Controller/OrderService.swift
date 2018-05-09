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
            guard let index = orders[venueID]?.index(where: {$0.id == order.id}) else {Log.error("Could not find any orders for the venue, that requested an update to an order"); return}
            let updatableOrder = orders[venueID]![index]
            
            ClientService.instance.notifyClient(withDeviceID: updatableOrder.deviceID, updatableOrder: order)
            
            switch order.status {
            case .Handled:
                execute {
                    orders[venueID]?.remove(at: index)
                }
            default:
                updatableOrder.status = order.status
            }
}
}
        
        

