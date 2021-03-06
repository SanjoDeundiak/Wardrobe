//
//  WardrobeItem.swift
//  Hello
//
//  Created by Oleksandr Deundiak on 6/13/17.
//
//

import Foundation
import Vapor
import Fluent

final class WardrobeItem: Model {
    enum Keys: String {
        case id = "_id"
        case userId = "user_id"
        case category = "category"
        case itemType = "item_type"
        case color = "color"
    }
    
    var id: Node?
    var userId: Node
    var itemType: ItemType
    var color: Color
    
    var exists: Bool = false
    
    init(userId: Node, itemType: ItemType, color: Color) {
        // FIXME
        self.id = UUID().uuidString.makeNode()
        self.userId = userId
        self.itemType = itemType
        self.color = color
    }
    
    init(node: Node, in context: Context) throws {
        self.id = try node.extract(Keys.id.rawValue)
        self.userId = try node.extract(Keys.userId.rawValue)
        let itemTypeStr: String = try node.extract(Keys.itemType.rawValue)
        guard let itemType = ItemType(rawValue: itemTypeStr) else {
            throw Abort.serverError
        }
        
        self.itemType = itemType
        guard let colorStr: String = try node.extract(Keys.color.rawValue),
            let color = Color(rawValue: colorStr) else {
            throw Abort.serverError
        }
        
        self.color = color
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            Keys.id.rawValue: self.id,
            Keys.userId.rawValue: self.userId,
            Keys.itemType.rawValue: self.itemType.rawValue,
            Keys.category.rawValue: self.itemType.category.rawValue,
            Keys.color.rawValue: self.color.rawValue
            ])
    }
    
    static func items(forUser user: User, category: String?) throws -> [WardrobeItem] {
        let children = user.children(Keys.userId.rawValue, WardrobeItem.self)
        
        if let category = category {
            return try children.filter(Keys.category.rawValue, category).all()
        }
        else {
            return try children.all()
        }
    }
}

extension WardrobeItem: Preparation {
    static func prepare(_ database: Database) throws {
        //
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}
