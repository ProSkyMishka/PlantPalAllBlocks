//
//  PlantsController.swift
//
//
//  Created by Михаил Прозорский on 07.07.2024.
//

import Vapor

struct PlantsController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let plantsGroup = routes.grouped("plants")
        
        plantsGroup.get(use: getAllHandler)
        plantsGroup.get("ml", ":MLID", use: getHandler)
        let protected = plantsGroup.grouped(JWTMiddleware())
        protected.get(":id", use: getHandlerById)
        protected.put(":id", use: updateHandler)
        protected.post("create", use: createHandler)
    }
    
    
    @Sendable func createHandler(_ req: Request) async throws -> Plant {
        let plant = try req.content.decode(Plant.self)
        
        let newPlant = Plant(name: plant.name, description: plant.description, imageURL: plant.imageURL, temp: plant.temp, humidity: plant.humidity, waterInterval: plant.waterInterval, seconds: plant.seconds, MLID: plant.MLID, usered: plant.usered)
        
        try await newPlant.save(on: req.db)
        
        return newPlant
    }
    
    @Sendable func updateHandler(_ req: Request) async throws -> Plant {
        guard let plant = try await Plant.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let plantUpdate = try req.content.decode(Plant.self)
        
        plant.name = plantUpdate.name
        plant.description = plantUpdate.description
        plant.imageURL = plantUpdate.imageURL
        plant.temp = plantUpdate.temp
        plant.humidity = plantUpdate.humidity
        plant.waterInterval = plantUpdate.waterInterval
        plant.seconds = plantUpdate.seconds
        plant.MLID = plantUpdate.MLID
        plant.usered = true
        
        try await plant.save(on: req.db)
        
        return plant
    }
    
    @Sendable func getHandler(_ req: Request) async throws -> Plant {
        let mlid = req.parameters.get("MLID")
        guard let plant = try await Plant
            .query(on: req.db)
            .filter("MLID", .equal, mlid)
            .filter("usered", .equal, false)
            .first() else {
            throw Abort(.notFound)
        }
        return plant
    }
    
    @Sendable func getHandlerById(_ req: Request) async throws -> Plant {
        let inputId = req.parameters.get("id")
        guard let id = UUID(uuidString: inputId ?? "") else {
            throw Abort(.badRequest, reason: "Invalid UUID format.")
        }
        guard let plant = try await Plant
            .query(on: req.db)
            .filter("id", .equal, id)
            .first() else {
            throw Abort(.notFound)
        }
        return plant
    }
    
    @Sendable func getAllHandler(_ req: Request) async throws -> [Plant] {
        let plants = try await Plant.query(on: req.db).all()
        return plants
    }
}
