import Vapor
import Fluent
import VaporMongo
import TurnstileWeb
import TurnstileCrypto
import HTTP
import Auth
import Foundation

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
Look.database = db

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
    
    guard let itemTypeStr = request.json?["item_type"]?.string,
        let itemType = ItemType(rawValue: itemTypeStr),
        let colorStr = request.json?["color"]?.string,
        let color = Color(rawValue: colorStr) else {
            throw Abort.badRequest
    }
    
    var wardrobeItem = WardrobeItem(userId: user.id!, itemType: itemType, color: color)
    
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

// Looks
drop.post("users", User.self, "looks") { request, user in
    guard let token = request.headers["Authorization"]?.string else {
        throw Abort.custom(status: .forbidden, message: "")
    }
    
    let fbCredentials = AccessToken(string: token)
    
    try request.auth.login(fbCredentials)
    
    let authUser = try request.user()
    
    guard authUser.id! == user.id! else {
        throw Abort.custom(status: .forbidden, message: "")
    }
    
    guard let dateStr = request.json?["date"]?.string else {
        throw Abort.badRequest
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = DateFormat
    guard let date = dateFormatter.date(from: dateStr) else {
        throw Abort.badRequest
    }
    
    guard let upperIdStr = request.json?["upper_id"]?.string,
        let lowerIdStr = request.json?["lower_id"]?.string,
        let shoesIdStr = request.json?["shoes_id"]?.string else {
            throw Abort.badRequest
    }
    
    guard let upper = try WardrobeItem.find(upperIdStr),
        let lower = try WardrobeItem.find(lowerIdStr),
        let shoes = try WardrobeItem.find(shoesIdStr) else {
            throw Abort.badRequest
    }
    
    guard upper.userId == user.id!,
        lower.userId == user.id!,
        shoes.userId == user.id! else {
            throw Abort.badRequest
    }
    
    guard upper.itemType.category == .upper,
        lower.itemType.category == .lower,
        shoes.itemType.category == .shoes else {
        throw Abort.badRequest
    }
    
    var look = Look(userId: user.id!, date: date, upper: upper, lower: lower, shoes: shoes)
    
    try look.save()
    
    return try look.makeExtendedNode().converted(to: JSON.self)
}

drop.get("users", User.self, "looks") { request, user in
    guard let token = request.headers["Authorization"]?.string else {
        throw Abort.custom(status: .forbidden, message: "")
    }
    
    let fbCredentials = AccessToken(string: token)
    
    try request.auth.login(fbCredentials)
    
    let authUser = try request.user()
    
    guard authUser.id! == user.id! else {
        throw Abort.custom(status: .forbidden, message: "")
    }
    
    guard let dateStr = request.query?["date"]?.string else {
        throw Abort.badRequest
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = DateFormat
    guard let date = dateFormatter.date(from: dateStr) else {
        throw Abort.badRequest
    }
    
    if let look = try Look.look(forUser: user, date: date) {
        return try look.makeExtendedNode().converted(to: JSON.self)
    }
    else {
        return ""
    }
}

drop.put("users", User.self, "looks/:lookId") { request, user in
    guard let token = request.headers["Authorization"]?.string else {
        throw Abort.custom(status: .forbidden, message: "")
    }
    
    let fbCredentials = AccessToken(string: token)
    
    try request.auth.login(fbCredentials)
    
    let authUser = try request.user()
    
    guard authUser.id! == user.id! else {
        throw Abort.custom(status: .forbidden, message: "")
    }
    
    guard let lookId: String = try request.parameters.extract("lookId") else {
        throw Abort.badRequest
    }
    
    guard var look = try Look.find(lookId) else {
        throw Abort.notFound
    }
    
    guard let upperIdStr = request.json?["upper_id"]?.string,
        let lowerIdStr = request.json?["lower_id"]?.string,
        let shoesIdStr = request.json?["shoes_id"]?.string else {
            throw Abort.badRequest
    }
    
    guard let upper = try WardrobeItem.find(upperIdStr),
        let lower = try WardrobeItem.find(lowerIdStr),
        let shoes = try WardrobeItem.find(shoesIdStr) else {
            throw Abort.badRequest
    }
    
    guard upper.userId == user.id!,
        lower.userId == user.id!,
        shoes.userId == user.id! else {
            throw Abort.badRequest
    }
    
    guard upper.itemType.category == .upper,
        lower.itemType.category == .lower,
        shoes.itemType.category == .shoes else {
            throw Abort.badRequest
    }
    
    look.upper = upper
    look.lower = lower
    look.shoes = shoes
    
    try look.save()
    
    return try look.makeExtendedNode().converted(to: JSON.self)
}

drop.run()
