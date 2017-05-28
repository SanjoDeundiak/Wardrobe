//
//  UserController.swift
//  Hello
//
//  Created by Oleksandr Deundiak on 5/21/17.
//
//

import Foundation
import Vapor
import HTTP

final class UserController: ResourceRepresentable {
    func index(request: Request) throws -> ResponseRepresentable {
        return try User.all().makeNode().converted(to: JSON.self)
    }
    
    func show(request: Request, user: User) throws -> ResponseRepresentable {
        return user
    }
    
    func delete(request: Request, user: User) throws -> ResponseRepresentable {
        try user.delete()
        return JSON([:])
    }
    
    func makeResource() -> Resource<User> {
        return Resource(
            index: self.index,
            store: nil,
            show: self.show,
            replace: nil,
            modify: nil,
            destroy: self.delete,
            clear: nil
        )
    }
}
