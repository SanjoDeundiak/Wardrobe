import Vapor

let drop = Droplet()

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

let fbAuthController = FacebookAuthController()
drop.post("/login/facebook/", handler: fbAuthController.login)

drop.resource("posts", PostController())

drop.run()
