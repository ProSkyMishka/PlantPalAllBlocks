//
//  CreateDevice.swift
//  PlantPalBack
//
//  Created by Михаил Прозорский on 09.05.2025.
//

import Vapor
import Fluent

struct CreateDevice: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        let schema = database.schema("devices")
            .id()
            .field("user_id", .string, .required)
            .field("plant_id", .string, .required)
            .field("device_wqtt_id", .string, .required)
        
        try await schema.create()
    }
    
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema("devices").delete()
    }
}
