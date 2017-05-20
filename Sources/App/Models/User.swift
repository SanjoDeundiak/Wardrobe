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

final class User: Model {
    private enum Keys: String {
        case id = "id"
        case facebookAuthInfo = "fb_auth"
    }
    
    var id: Node?
    var facebookAuthInfo: FacebookAuthInfo
    
    init(facebookAuthInfo: FacebookAuthInfo) {
        self.id = UUID().uuidString.makeNode()
        self.facebookAuthInfo = facebookAuthInfo
    }
    
    init(node: Node, in context: Context) throws {
        self.id = try node.extract(Keys.id.rawValue)
        self.facebookAuthInfo = try node.extract(Keys.facebookAuthInfo.rawValue)
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            Keys.id.rawValue: self.id,
            Keys.facebookAuthInfo.rawValue: self.facebookAuthInfo
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
