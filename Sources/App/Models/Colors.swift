//
//  Colors.swift
//  Hello
//
//  Created by Oleksandr Deundiak on 6/15/17.
//
//

import Foundation

enum ColorName: String {
    case red = "red"
    case green = "green"
    case blue = "blue"
    case yellow = "yellow"
    case black = "black"
    case white = "white"
}

enum Color {
    case colorName(ColorName)
    case hex(String)
    
    init?(rawValue: String) {
        if let colorName = ColorName(rawValue: rawValue) {
            self = .colorName(colorName)
        }
        else {
            self = .hex(rawValue)
        }
    }
    
    var rawValue: String {
        switch self {
        case .colorName(let color): return color.rawValue
        case .hex(let value): return value
        }
    }
}
