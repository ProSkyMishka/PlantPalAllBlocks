//
//  User.swift
//  
//
//  Created by Михаил Прозорский on 05.07.2024.
//

import Fluent
import Vapor

final class User: Model, Content {
    init() { }
    
    static var schema: String = "users"
    
    @ID var id: UUID?
    @Field(key: "password") var password: String
    @Field(key: "login") var login: String
    @Field(key: "flowers") var flowers: [String]
    @Field(key: "email") var email: String
    
    init(id: UUID? = nil, password: String, login: String, flowers: [String], email: String) {
        self.id = id
        self.password = password
        self.login = login
        self.flowers = flowers
        self.email = email
    }
    
    final class Public: Content {
        var id: UUID?
        var login: String
        var flowers: [String]
        var email: String
        
        init(id: UUID? = nil, login: String, flowers: [String], email: String) {
            self.id = id
            self.login = login
            self.flowers = flowers
            self.email = email
        }
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey = \User.$login
    static var passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

extension User {
    func convertToPublic() -> User.Public {
        let pub = Public(id: self.id, login: self.login, flowers: self.flowers, email: self.email)
        return pub
    }
}

enum Roles: String {
    case user = "user"
    case admin = "admin"
}
