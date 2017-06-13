import Vapor
import Fluent
import VaporMongo
import TurnstileWeb
import TurnstileCrypto
import HTTP
import Auth

let drop = Droplet()

HTTP.defaultServerTimeout = 60 * 60

// setup mongo
try drop.addProvider(VaporMongo.Provider.self)
guard let mongoProvider = drop.providers.last as? VaporMongo.Provider else {
    throw Abort.custom(status: Status.internalServerError, message: "Mongo error")
}

// setup db for Fluent
let db = Database(mongoProvider.driver)
User.database = db
WardrobeItem.database = db

// add authentication
drop.middleware.append(AuthMiddleware<User>())

// setup fb
guard let clientID = drop.config["app", "facebookClientID"]?.string,
    let clientSecret = drop.config["app", "facebookClientSecret"]?.string else {
    throw Abort.custom(status: Status.notFound, message: "Fb credentials not found error")
}

SharedFB.initialize(fb: Facebook(clientID: clientID, clientSecret: clientSecret))

let fb = SharedFB.fb

// authentication
drop.post("authenticate", "facebook") { request in
    guard let fbToken = request.json?["access_token"]?.string else {
        throw Abort.badRequest
    }
    
    let fbCredentials = AccessToken(string: fbToken)
    
    try request.auth.login(fbCredentials)
    
    return try request.user()
}

// Starting page
drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

// Users controller
drop.resource("users", UserController())

// Wardrobe items
drop.post("users", User.self, "wardrobe") { request, user in
    guard let token = request.headers["Authorization"]?.string else {
        throw Abort.custom(status: .forbidden, message: "")
    }
    
    let fbCredentials = AccessToken(string: token)
    
    try request.auth.login(fbCredentials)
    
    let authUser = try request.user()
    
    guard authUser.id! == user.id! else {
        throw Abort.custom(status: .forbidden, message: "")
    }
    
    guard let category = request.json?["category"]?.string,
        let color = request.json?["color"]?.string else {
            throw Abort.badRequest
    }
    
    var wardrobeItem = WardrobeItem(userId: user.id!, category: category, color: color)
    
    try wardrobeItem.save()
    
    return wardrobeItem
}

drop.get("users", User.self, "wardrobe") { request, user in
    guard let token = request.headers["Authorization"]?.string else {
        throw Abort.custom(status: .forbidden, message: "")
    }
    
    let fbCredentials = AccessToken(string: token)
    
    try request.auth.login(fbCredentials)
    
    let authUser = try request.user()
    
    guard authUser.id! == user.id! else {
        throw Abort.custom(status: .forbidden, message: "")
    }
    
    let category = request.query?["category"]?.string
    
    return try WardrobeItem.items(forUser: user, category: category).makeNode().converted(to: JSON.self)
}

drop.run()
