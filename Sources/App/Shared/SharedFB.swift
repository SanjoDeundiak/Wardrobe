//
//  SharedFB.swift
//  Hello
//
//  Created by Oleksandr Deundiak on 5/27/17.
//
//

import Foundation
import Vapor
import Auth

struct FBAccount: Credentials {
    let uniqueID: String
    let accessToken: String
}

class FB {
    private var drop: Droplet
    private var clientId: String
    private var clientSecret: String
    
    init(drop: Droplet, clientId: String, clientSecret: String) {
        self.drop = drop
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    func authenticate(credentials: String) throws -> FBAccount {
        let str = "https://graph.facebook.com/debug_token?input_token=\(credentials)&access_token=\(self.clientId)%7C\(self.clientSecret)"
        let response = try self.drop.client.get(str, headers: ["Accept": "application/json"], query: [:], body: "")
        
        guard let json = response.json else {
            throw Abort.custom(status: .internalServerError, message: "No fb response")
        }
        
        guard let responseData = json["data"].extract() else {
            print(json.string ?? "No Json")
            throw Abort.custom(status: .internalServerError, message: "Invalid json fb response")
        }
        
        if let accountID = responseData["user_id"]?.string,
            responseData["app_id"]?.string == clientId && responseData["is_valid"]?.bool == true {
            
            return FBAccount(uniqueID: accountID, accessToken: credentials)
        }
        
        throw Abort.custom(status: .internalServerError, message: "Invalid json fb data")
    }
}

class SharedFB {
    private static var sharedInstance: SharedFB!
    
    static var fb: FB { return self.sharedInstance.fb }
    
    private let fb: FB
    private init(fb: FB) {
        self.fb = fb
    }
    
    class func initialize(fb: FB) {
        self.sharedInstance = SharedFB(fb: fb)
    }
}
