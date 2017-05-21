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
    
//    func create(request: Request) throws -> ResponseRepresentable {
//        guard let accessToken = request.json?["facebook_access_token"]?.string,
//            let fbId = request.json?["facebook_user_id"]?.string else {
//            throw Abort.badRequest
//        }
//        
//        var user: User
//        
//        // User exists
//        if case let foundUser?? = try? User.query().filter(User.Keys.facebookAuthInfo.rawValue + "." + FacebookAuthInfo.Keys.id.rawValue, fbId).first() {
//            user = foundUser
//        }
//        // New user
//        else {
//            user = User(facebookAuthInfo: FacebookAuthInfo(id: fbId, accessToken: accessToken))
//            do {
//                try user.save()
//            }
//            catch {
//                throw Abort.serverError
//            }
//        }
//        
//        return user
//    }
    
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
