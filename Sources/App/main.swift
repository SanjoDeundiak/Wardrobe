import Vapor
import Fluent
import VaporMongo
import TurnstileWeb
import TurnstileCrypto
import HTTP
import Auth

let drop = Droplet()

// setup mongo
try drop.addProvider(VaporMongo.Provider.self)
guard let mongoProvider = drop.providers.last as? VaporMongo.Provider else {
    throw Abort.custom(status: Status.internalServerError, message: "Mongo error")
}

// setup db for Fluent
let db = Database(mongoProvider.driver)
User.database = db

// setup fb
drop.middleware.append(AuthMiddleware<User>())

guard let clientID = drop.config["app", "facebookClientID"]?.string,
    let clientSecret = drop.config["app", "facebookClientSecret"]?.string else {
    throw Abort.custom(status: Status.notFound, message: "Fb credentials not found error")
}

let fb = Facebook(clientID: clientID, clientSecret: clientSecret)

drop.get("login", "facebook") { request in
    let state = URandom().secureToken
    let response = Response(redirect: fb.getLoginLink(redirectURL: request.baseURL + "/login/facebook/consumer", state: state).absoluteString)
    response.cookies["OAuthState"] = state
    return response
}

drop.get("login", "facebook", "consumer") { request in
    guard let state = request.cookies["OAuthState"] else {
        return Response(redirect: "/login")
    }
    guard case let account?? = try? fb.authenticate(authorizationCodeCallbackURL: request.uri.description, state: state) as? FacebookAccount else {
        throw Abort.badRequest
    }
    
    do {
        try request.auth.login(account)
    }
    catch {
//        request.auth.
        throw Abort.serverError
    }
    return Response(redirect: "/")
}

// Starting page
drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

// Users controller
drop.resource("users", UserController())

//drop.resource("posts", PostController())

drop.run()
