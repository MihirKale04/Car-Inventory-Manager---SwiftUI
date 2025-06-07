//
//  ContentView.swift
//  Car Inventory Manager
//
//  Created by Mihir Kale on 6/6/25.
//
import SwiftUI

struct ContentView: View {
    @StateObject var carAPI = CarAPI() // Observe changes from the CarAPI class
    @State private var showingAddCarSheet = false
    @State private var showingDeleteAllConfirmation = false // For the alert

    var body: some View {
        NavigationView {
            List {
                if carAPI.isLoading {
                    ProgressView("Loading Cars...")
                } else if let errorMessage = carAPI.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if carAPI.cars.isEmpty {
                    ContentUnavailableView("No Cars Yet", systemImage: "car.fill", description: Text("Add your first car to the inventory."))
                } else {
                    ForEach(carAPI.cars) { car in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(car.make) \(car.model)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(String(car.year))")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            Text("Price: $\(car.price)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4) // Add some vertical padding for each row
                        .swipeActions {
                            Button(role: .destructive) {
                                if let id = car.id {
                                    carAPI.deleteCar(id: id)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Car Inventory")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive) {
                        showingDeleteAllConfirmation = true
                    } label: {
                        Label("Delete All", systemImage: "trash.fill")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCarSheet = true
                    } label: {
                        Label("Add Car", systemImage: "plus.circle.fill")
                    }
                }
            }
            .onAppear {
                carAPI.fetchCars() // Fetch cars when the view appears
            }
            .sheet(isPresented: $showingAddCarSheet) {
                AddCarView(carAPI: carAPI, isPresented: $showingAddCarSheet)
            }
            .alert("Delete All Cars?", isPresented: $showingDeleteAllConfirmation) {
                Button("Delete All", role: .destructive) {
                    carAPI.deleteAllCars()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete all cars from the inventory? This action cannot be undone.")
            }
        }
    }
}


struct AddCarView: View {
    @Environment(\.dismiss) var dismiss // For iOS 15+ to close sheet
    @ObservedObject var carAPI: CarAPI // Observe for changes (e.g., loading state)
    @Binding var isPresented: Bool // Older way to dismiss sheet

    @State private var make: String = ""
    @State private var model: String = ""
    @State private var year: String = ""
    @State private var price: String = ""
    @State private var inputErrorMessage: String? // For input validation errors

    var body: some View {
        NavigationView {
            Form {
                Section("Car Details") {
                    TextField("Make", text: $make)
                    TextField("Model", text: $model)
                    TextField("Year", text: $year)
                        .keyboardType(.numberPad)
                    TextField("Price", text: $price)
                        .keyboardType(.numberPad)
                }

                if let errorMessage = inputErrorMessage { // Display local input errors
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                if let apiErrorMessage = carAPI.errorMessage { // Display API errors
                    Text(apiErrorMessage)
                        .foregroundColor(.red)
                }

                Button("Add Car") {
                    inputErrorMessage = nil // Clear previous local errors

                    // Basic client-side validation
                    guard !make.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        inputErrorMessage = "Make cannot be empty."
                        return
                    }
                    guard !model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        inputErrorMessage = "Model cannot be empty."
                        return
                    }
                    guard let carYear = Int(year), carYear >= 1900 && carYear <= Calendar.current.component(.year, from: Date()) + 1 else { // Basic year range
                        inputErrorMessage = "Year must be a valid number (e.g., 2023)."
                        return
                    }
                    guard let carPrice = Int(price), carPrice > 0 else {
                        inputErrorMessage = "Price must be a positive number."
                        return
                    }

                    // Create a Car object (id is nil because it's assigned by the backend)
                    let newCar = Car(id: nil, make: make.trimmingCharacters(in: .whitespacesAndNewlines), model: model.trimmingCharacters(in: .whitespacesAndNewlines), year: carYear, price: carPrice)
                    carAPI.addCar(car: newCar)
                    isPresented = false // Dismiss the sheet on successful attempt
                }
                .disabled(carAPI.isLoading) // Disable button during API call
            }
            .navigationTitle("Add New Car")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
