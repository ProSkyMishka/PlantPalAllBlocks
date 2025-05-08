//
//  AuthController.swift
//
//
//  Created by Михаил Прозорский on 21.11.2024.
//

import Vapor
import Fluent
import JWT

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("register", use: register)
        auth.post("login", use: login)

        let protected = auth.grouped(JWTMiddleware())
        protected.get("me", use: getCurrentUser)
        protected.put("update", use: update)
    }

    @Sendable
    func register(req: Request) async throws -> TokenResponse {
        let input = try req.content.decode(RegisterRequest.self)
        
        guard try await User.query(on: req.db)
                .filter(\.$login == input.login)
                .first() == nil else {
            throw Abort(.badRequest, reason: "Username is already taken")
        }

        let hashedPassword = try Bcrypt.hash(input.password)
        let newUser = User(password: hashedPassword, login: input.login, flowers: [], email: input.email)
        try await newUser.save(on: req.db)
        
        let payload = UserPayload(userID: try newUser.requireID())
        let token = try req.jwt.sign(payload)
        return TokenResponse(token: token)
    }

    @Sendable
    func login(req: Request) async throws -> TokenResponse {
        let input = try req.content.decode(LoginRequest.self)
        
        guard let user = try await User
            .query(on: req.db)
            .filter(\.$login == input.login)
            .first()
        else { throw Abort(.notFound) }

        guard try Bcrypt.verify(input.password, created: user.password) else {
            throw Abort(.unauthorized, reason: "Invalid username or password")
        }

        let payload = UserPayload(userID: try user.requireID())
        let token = try req.jwt.sign(payload)
        return TokenResponse(token: token)
    }

    @Sendable
    func getCurrentUser(req: Request) async throws -> User.Public {
        let payload = try req.auth.require(UserPayload.self)
        guard let user = try await User.find(payload.userID, on: req.db) else {
            throw Abort(.notFound)
        }
        return user.convertToPublic()
    }
    
    @Sendable
    func update(req: Request) async throws -> User.Public {
        let payload = try req.auth.require(UserPayload.self)
        guard let user = try await User.find(payload.userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        let input = try req.content.decode(UpdateUserRequest.self)
        
        if input.login != user.login {
            guard try await User.query(on: req.db)
                    .filter(\.$login == input.login)
                    .first() == nil else {
                throw Abort(.badRequest, reason: "Username is already taken")
            }
        }
        
        user.email = input.email
        user.login = input.login
        user.flowers = input.flowers
        print(user.flowers)
        
        try await user.save(on: req.db)
        
        return user.convertToPublic()
    }
}

struct UpdateUserRequest: Content {
    let login: String
    let email: String
    let flowers: [String]
}

struct RegisterRequest: Content {
    let login: String
    let email: String
    let password: String
}

struct LoginRequest: Content {
    let login: String
    let password: String
}

struct TokenResponse: Content {
    let token: String
}

struct UserPayload: JWTPayload, Authenticatable {
    var userID: UUID
    var exp: ExpirationClaim

    init(userID: UUID) {
        self.userID = userID
        self.exp = .init(value: Date().addingTimeInterval(60 * 60 * 24))
    }

    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}

struct JWTMiddleware: AsyncMiddleware {
    func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let token = req.headers.bearerAuthorization?.token
        guard let token = token else {
            throw Abort(.unauthorized, reason: "Missing or invalid token")
        }

        req.auth.login(try req.jwt.verify(token, as: UserPayload.self))
        return try await next.respond(to: req)
    }
}
