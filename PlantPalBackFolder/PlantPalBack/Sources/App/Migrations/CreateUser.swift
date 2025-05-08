//
//  CreateUser.swift
//
//
//  Created by Михаил Прозорский on 05.07.2024.
//

import Vapor
import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        let schema = database.schema("users")
            .id()
            .field("password", .string, .required)
            .field("login", .string, .required)
            .field("flowers", .array(of: .string))
            .field("email", .string, .required)
            .unique(on: "login")
        
        try await schema.create()
    }
    
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("users").delete()
    }
}
