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
        guard let id = req.data["id"]?.string else {
            throw Abort.badRequest
        }
        
        if case let user?? = try? User.query().filter(User.Keys.id.rawValue, id).first() {
            return user
        }
        else {
            var user = User(facebookAuthInfo: FacebookAuthInfo(id: id, accessToken: "someToken"))
        
            do {
                try user.save()
            }
            catch {
                throw Abort.serverError
            }
            
            return user
        }
    }
}
