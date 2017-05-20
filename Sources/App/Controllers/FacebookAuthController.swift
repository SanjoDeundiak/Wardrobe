//
//  FacebookAuthController.swift
//  Hello
//
//  Created by Oleksandr Deundiak on 5/20/17.
//
//

import Foundation
import Vapor
import HTTP

final class FacebookAuthController {
    func login(_ req: Request) throws -> ResponseRepresentable {
//        guard let name = req.data["name"] else {
//            throw Abort.badRequest
//        }
        return "Hello"
    }
}
