//
//  ServerError.swift
//  Controller
//
//  Created by Emil Lind on 08/04/2018.
//

import Foundation
import KituraNet

public struct ServerErrorStruct: Swift.Error {
    let statusCode: HTTPStatusCode
    let localizedDescription: String
}
