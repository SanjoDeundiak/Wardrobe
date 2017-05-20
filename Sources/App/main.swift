import Vapor
import Fluent

let drop = Droplet()

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

let db = Database(MemoryDriver())

User.database = db

let fbAuthController = FacebookAuthController()
drop.post("/login/facebook/", handler: fbAuthController.login)

drop.resource("posts", PostController())

drop.run()
