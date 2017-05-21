//
//  User.swift
//  Hello
//
//  Created by Oleksandr Deundiak on 5/20/17.
//
//

import Vapor
import Fluent
import Foundation
import TurnstileWeb
import Auth

final class User: Model {
    enum Keys: String {
        case id = "_id"
        case facebookId = "fb_id"
    }
    
    var id: Node?
    var fbId: String
    
    var exists: Bool = false
    
    init(credentials: FacebookAccount) {
        // FIXME
        self.id = UUID().uuidString.makeNode()
        self.fbId = credentials.uniqueID
    }
    
    init(node: Node, in context: Context) throws {
        self.id = try node.extract(Keys.id.rawValue)
        self.fbId = try node.extract(Keys.facebookId.rawValue)
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            Keys.id.rawValue: self.id,
            Keys.facebookId.rawValue: self.fbId
            ])
    }
}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        //
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}

extension User: Auth.User {
    var uniqueID: String { return self.fbId }
    
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        switch credentials {
        case let credentials as Identifier:
            if case let user?? = try? User.find(credentials.id) {
                return user
            }
            
            throw Abort.badRequest
        
        case let credentials as FacebookAccount:
            if let user = try User.query().filter(User.Keys.facebookId.rawValue, credentials.uniqueID).first() {
                return user
            } else {
                guard let user = try User.register(credentials: credentials) as? User else {
                    throw Abort.serverError
                }
                
                return user
            }
        default:
            throw Abort.badRequest
        }
    }
    
    static func register(credentials: Credentials) throws -> Auth.User {
        switch credentials {
        case let credentials as FacebookAccount:
            var user = User(credentials: credentials)
            
            do {
                try user.save()
            }
            catch {
                throw Abort.serverError
            }
            
            return user

        default:
            throw Abort.badRequest
        }
    }
}
