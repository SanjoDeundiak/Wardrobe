//
//  FacebookAuthInfo.swift
//  Hello
//
//  Created by Oleksandr Deundiak on 5/20/17.
//
//

import Vapor
import Fluent
import Foundation

final class FacebookAuthInfo: NodeConvertible {
    enum Keys: String {
        case id = "id"
        case accessToken = "access_token"
    }
    
    var id: String
    var accessToken: String
    
    init(id: String, accessToken: String) {
        self.id = id
        self.accessToken = accessToken
    }
    
    init(node: Node, in context: Context) throws {
        self.id = try node.extract(Keys.id.rawValue)
        self.accessToken = try node.extract(Keys.accessToken.rawValue)
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            Keys.id.rawValue: self.id,
            Keys.accessToken.rawValue: self.accessToken
            ])
    }
}
