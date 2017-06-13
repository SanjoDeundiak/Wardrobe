//
//  Category.swift
//  Hello
//
//  Created by Oleksandr Deundiak on 6/13/17.
//
//

import Foundation

enum UpperSubcategory: String {
    case shirt = "shirt"
}

enum LowerSubcategory: String {
    case jeans = "jeans"
    case skirt = "skirt"
}

enum ShoesSubcategory: String {
    case snickers = "snickers"
    case shoes = "shoes"
    case boots = "boots"
}

enum Category: String {
    case upper = "upper"
    case lower = "lower"
    case shoes = "shoes"
}

enum ItemType {
    case upper(UpperSubcategory)
    case lower(LowerSubcategory)
    case shoes(ShoesSubcategory)
    
    init?(rawValue: String) {
        if let up = UpperSubcategory(rawValue: rawValue) {
            self = .upper(up)
        }
        else if let low = LowerSubcategory(rawValue: rawValue) {
            self = .lower(low)
        }
        else if let shoes = ShoesSubcategory(rawValue: rawValue) {
            self = .shoes(shoes)
        }
        else {
            return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .upper(let up): return up.rawValue
        case .lower(let low): return low.rawValue
        case .shoes(let shoes): return shoes.rawValue
        }
    }
    
    var category: Category {
        switch self {
        case .upper(_): return .upper
        case .lower(_): return .lower
        case .shoes(_): return .shoes
        }
    }
}
