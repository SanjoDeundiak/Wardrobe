//
//  Look.swift
//  Hello
//
//  Created by Oleksandr Deundiak on 6/13/17.
//
//

import Foundation
import Vapor
import Fluent

final class Look: Model {
    enum Keys: String {
        case id = "_id"
        case userId = "user_id"
        case date = "date"
        case upperId = "upper_id"
        case lowerId = "lower_id"
        case shoesId = "shoes_id"
        case upper = "upper"
        case lower = "lower"
        case shoes = "shoes"
    }
    
    var id: Node?
    var userId: Node
    var date: Date
    var upper: WardrobeItem
    var lower: WardrobeItem
    var shoes: WardrobeItem
    
    var exists: Bool = false
    
    init(userId: Node, date: Date, upper: WardrobeItem, lower: WardrobeItem, shoes: WardrobeItem) {
        // FIXME
        self.id = UUID().uuidString.makeNode()
        self.userId = userId
        self.date = date
        self.upper = upper
        self.lower = lower
        self.shoes = shoes
    }
    
    init(node: Node, in context: Context) throws {
        self.id = try node.extract(Keys.id.rawValue)
        self.userId = try node.extract(Keys.userId.rawValue)
        let dateStr: String = try node.extract(Keys.date.rawValue)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat
        guard let date = dateFormatter.date(from: dateStr) else {
            throw Abort.serverError
        }
        self.date = date
        
        let upperNode: Node = try node.extract(Keys.upperId.rawValue)
        let lowerNode: Node = try node.extract(Keys.lowerId.rawValue)
        let shoesNode: Node = try node.extract(Keys.shoesId.rawValue)
        
        guard let upper = try WardrobeItem.find(upperNode),
            let lower = try WardrobeItem.find(lowerNode),
            let shoes = try WardrobeItem.find(shoesNode) else {
                throw Abort.serverError
        }
        
        self.upper = upper
        self.lower = lower
        self.shoes = shoes
    }
    
    func makeNode(context: Context) throws -> Node {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat
        
        return try Node(node: [
            Keys.id.rawValue: self.id,
            Keys.userId.rawValue: self.userId,
            Keys.date.rawValue: dateFormatter.string(from: self.date),
            Keys.upperId.rawValue: self.upper.id!,
            Keys.lowerId.rawValue: self.lower.id!,
            Keys.shoesId.rawValue: self.shoes.id!,
            ])
    }
    
    func makeExtendedNode() throws -> Node {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat
        
        return try Node(node: [
            Keys.id.rawValue: self.id,
            Keys.userId.rawValue: self.userId,
            Keys.date.rawValue: dateFormatter.string(from: self.date),
            Keys.upper.rawValue: self.upper,
            Keys.lower.rawValue: self.lower,
            Keys.shoes.rawValue: self.shoes,
            ])
    }
    
    static func look(forUser user: User, date: Date) throws -> Look? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat
        
        return try user.children(Keys.userId.rawValue, Look.self).filter(Keys.date.rawValue, dateFormatter.string(from: date)).first()
    }
}

extension Look: Preparation {
    static func prepare(_ database: Database) throws {
        //
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}
