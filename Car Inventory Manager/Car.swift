//
//  Car.swift
//  Car Inventory Manager
//
//  Created by Mihir Kale on 6/6/25.
//

import Foundation


// Identifiable is crucial for SwiftUI Lists to display data efficiently.
// Decodable and Encodable are for parsing JSON data from your Kotlin backend.
struct Car: Identifiable, Codable {
    // id needs to be mutable because it's assigned by the database on creation
    var id: Int? // Optional because it might not be present when sending a new car to the API
    var make: String
    var model: String
    var year: Int
    var price: Int
    
    
    // Define CodingKeys to map JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case id = "car_id"
        case make = "make"
        case model = "model_name"
        case year = "year"
        case price = "price"
    }
}
