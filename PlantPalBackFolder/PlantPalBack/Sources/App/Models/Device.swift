//
//  Device.swift
//  PlantPalBack
//
//  Created by Михаил Прозорский on 09.05.2025.
//

import Vapor
import Fluent

final class Device: Model, Content {
    static let schema: String = "devices"
    
    @ID var id: UUID?
    
    @Field(key: "user_id") var userId: String
    @Field(key: "plant_id") var plantId: String
    @Field(key: "device_wqtt_id") var deviceWqttId: String
    
    init() { }
    
    init(id: UUID? = nil, userId: String, plantId: String) {
        self.id = id
        self.userId = userId
        self.plantId = plantId
    }
}
