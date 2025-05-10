//
//  DevicesController.swift
//  PlantPalBack
//
//  Created by Михаил Прозорский on 09.05.2025.
//

import Vapor

struct DevicesController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let plantsGroup = routes.grouped("devices")
        
        let protected = plantsGroup.grouped(JWTMiddleware())
        protected.get(use: getAllHandlerForUser)
        protected.get(":id", use: getHandler)
        protected.put(":id", use: updateHandler)
        protected.post("create", use: createHandler)
    }
    
    
    @Sendable func createHandler(_ req: Request) async throws -> Device {
        let device = try req.content.decode(Device.self)
        
        let newDevice = Device(userId: device.userId, plantId: device.plantId)
        
        try await newDevice.save(on: req.db)
        
        return newDevice
    }
    
    @Sendable func updateHandler(_ req: Request) async throws -> Device {
        guard let device = try await Device.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let deviceUpdate = try req.content.decode(Device.self)
        
        device.userId = deviceUpdate.userId
        device.plantId = deviceUpdate.plantId
        device.deviceWqttId = deviceUpdate.deviceWqttId
        
        try await device.save(on: req.db)
        
        return device
    }
    
    @Sendable func getHandler(_ req: Request) async throws -> Device {
        let inputId = req.parameters.get("id")
        
        guard let id = UUID(uuidString: inputId ?? "") else {
            throw Abort(.badRequest, reason: "Invalid UUID format.")
        }
        
        guard let device = try await Device
            .query(on: req.db)
            .filter("id", .equal, id)
            .first() else {
            throw Abort(.notFound)
        }
        
        return device
    }
    
    @Sendable func getAllHandlerForUser(_ req: Request) async throws -> [Device] {
        let payload = try req.auth.require(UserPayload.self)
        let devices = try await Device.query(on: req.db).all()
        return devices.filter({
            $0.userId == String(payload.userID)
        })
    }
}
