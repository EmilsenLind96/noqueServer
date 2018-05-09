//
//  SendMessage.swift
//  Controller
//
//  Created by Emil Lind on 13/04/2018.
//

import Foundation

extension PushNotifications {
    struct Target {
        public private(set) var targetType: String
        public private(set) var targetInformation: [String]
        
        init(deviceIds: [String]) {
            targetType = "deviceIds"
            targetInformation = deviceIds
        }
        
        init(userIds: [String]) {
            targetType = "userIds"
            targetInformation = userIds
        }
        
        init(tagNames: [String]) {
            targetType = "tagNames"
            targetInformation = tagNames
        }
        
        enum Platform: String {
            case ios = "A"
            case android = "G"
        }
        
        init(platforms: [Platform]) {
            targetType = "platforms"
            targetInformation = platforms.map({return $0.rawValue})
        }
    }
    
    struct iosSettings {
        public private(set) var sound: String = "default"
        public private(set) var badge: String = "0"
    }
    
    struct androidSettings {
        public private(set) var sound: String = "default"
    }
    
    
    
    static func sendMessage(withMessage message: String, target: Target, payload: [String: Any], iosSettings: iosSettings = iosSettings(), androidSettings: androidSettings = androidSettings(), completion: @escaping (PushNotificationResponse) -> ()) {
        var request = URLRequest(url: URL(string: self.url + "/messages")!)
        request.httpMethod = "POST"
        let json = [
            "message": ["alert": message],
            "target": [target.targetType: target.targetInformation],
            "settings": [
                "apns": ["badge": iosSettings.badge, "sound": iosSettings.sound, "payload": payload],
                "gcm": ["sound": androidSettings.sound, "payload": payload]
            ]
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        sendRequest(request: request) { (response) in
            completion(response)
        }
    }
}
