//
//  CarAPI.swift
//  Car Inventory Manager
//
//  Created by Mihir Kale on 6/6/25.
//

import Foundation

// ObservableObject: Allows SwiftUI views to react to changes in this class's published properties.
class CarAPI: ObservableObject {
    // @Published: Automatically publishes changes to these properties, triggering UI updates.
    @Published var cars: [Car] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // 🚨 IMPORTANT: REPLACE with your Mac's actual local IP address (e.g., "192.168.1.100")
    // and the port your Node.js backend is running on (default 3000).
    // DO NOT use "localhost" or "127.0.0.1" for simulator/device.
    private let baseURL = URL(string: "http://192.168.68.89:3000/cars")! // <-- UPDATE THIS IP & PORT

    // MARK: - Fetch All Cars (GET /cars)
    func fetchCars() {
        isLoading = true
        errorMessage = nil // Clear previous errors

        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            // All UI updates must happen on the main thread
            DispatchQueue.main.async {
                self.isLoading = false // Loading is done

                // 1. Handle network errors
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    print("Network error: \(error.localizedDescription)")
                    return
                }

                // 2. Handle HTTP status codes
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid HTTP response."
                    print("Invalid HTTP response.")
                    return
                }

                guard httpResponse.statusCode == 200 else {
                    let errorBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                    self.errorMessage = "Server error (\(httpResponse.statusCode)): \(errorBody)"
                    print("Server error status code: \(httpResponse.statusCode), body: \(errorBody)")
                    return
                }

                // 3. Handle data and decode JSON
                guard let data = data else {
                    self.errorMessage = "No data received from server."
                    print("No data received from server.")
                    return
                }

                do {
                    // Decode the JSON data into an array of Car objects
                    self.cars = try JSONDecoder().decode([Car].self, from: data)
                } catch {
                    self.errorMessage = "Failed to decode cars: \(error.localizedDescription)"
                    print("Decoding error: \(error)") // Log the actual decoding error
                    print("Raw data: \(String(data: data, encoding: .utf8) ?? "N/A")") // Log raw data for debugging
                }
            }
        }.resume() // Don't forget to resume the task!
    }

    // MARK: - Add a New Car (POST /cars)
    func addCar(car: Car) {
        isLoading = true
        errorMessage = nil

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Tell server we're sending JSON

        do {
            // Encode the Car object into JSON data
            request.httpBody = try JSONEncoder().encode(car)
        } catch {
            self.errorMessage = "Failed to encode car data: \(error.localizedDescription)"
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Network error adding car: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid HTTP response adding car."
                    return
                }

                // Node.js backend sends 201 Created for success
                guard httpResponse.statusCode == 201 else {
                    let errorBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                    self.errorMessage = "Server error adding car (\(httpResponse.statusCode)): \(errorBody)"
                    print("\(car.make) \(car.model) \(car.price) \(car.year)")
                    print("Server error status code: \(httpResponse.statusCode), body: \(errorBody)")
                    
                    return
                }

                // If successful (201), refetch all cars to update the list
                self.fetchCars()
            }
        }.resume()
    }

    // MARK: - Delete a Car (DELETE /cars/:id)
    func deleteCar(id: Int) {
        isLoading = true
        errorMessage = nil

        // Append the car ID to the base URL
        let deleteURL = baseURL.appendingPathComponent("\(id)")
        var request = URLRequest(url: deleteURL)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Network error deleting car: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid HTTP response deleting car."
                    return
                }

                // Node.js backend sends 204 No Content for successful deletion
                guard httpResponse.statusCode == 204 else {
                    let errorBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                    self.errorMessage = "Server error deleting car (\(httpResponse.statusCode)): \(errorBody)"
                    print("Server error status code: \(httpResponse.statusCode), body: \(errorBody)")
                    return
                }

                // If successful (204), remove the car from the local array instantly
                // This is more efficient than refetching the entire list
                self.cars.removeAll { $0.id == id }
            }
        }.resume()
    }

    // MARK: - Delete All Cars (DELETE /cars/all)
    func deleteAllCars() {
        isLoading = true
        errorMessage = nil

        let deleteAllURL = baseURL.appendingPathComponent("all")
        var request = URLRequest(url: deleteAllURL)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Network error deleting all cars: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid HTTP response deleting all cars."
                    return
                }

                guard httpResponse.statusCode == 204 else {
                    let errorBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
                    self.errorMessage = "Server error deleting all cars (\(httpResponse.statusCode)): \(errorBody)"
                    print("Server error status code: \(httpResponse.statusCode), body: \(errorBody)")
                    return
                }

                // If successful, clear the local array
                self.cars.removeAll()
            }
        }.resume()
    }
}
