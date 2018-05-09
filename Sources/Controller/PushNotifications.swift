//
//  PushNotifications.swift
//  Controller
//
//  Created by Emil Lind on 12/04/2018.
//

import Foundation
import LoggerAPI

public struct PushNotifications {
    
    private init() {}
    
    
    public static let appGuid = "c336264c-bb8f-4416-8395-c6c7314c5ca0"
    
    public static let url = "https://imfpush.eu-gb.bluemix.net:443/imfpush/v1/apps/c336264c-bb8f-4416-8395-c6c7314c5ca0"

    public static let appSecret = "63ec1d5e-869a-41b3-80b3-d2bdf31f8fc4"
    
    public struct PushNotificationResponse {
        public private(set) var statusCode: Int
        public private(set) var data: [String: Any]?
    }
    
   internal static func sendRequest(request: URLRequest, completion: @escaping (PushNotificationResponse) -> Void) {
        var request = request
        request.addValue(PushNotifications.appSecret, forHTTPHeaderField: "appSecret")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "accept")
    
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request) { (data, response, error) in
            
            guard error == nil else { Log.error(error!.localizedDescription); return}
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {completion(PushNotificationResponse(statusCode: response.statusCode, data: nil)); return}
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
                completion(PushNotificationResponse(statusCode: response.statusCode, data: json))
            } catch {
                completion(PushNotificationResponse(statusCode: response.statusCode, data: nil))
            }
        }
        task.resume()
    }
}
