# Car Inventory App (SwiftUI Frontend)

This is a native iOS mobile application built with **Swift** and **SwiftUI** that serves as a client for the Car Inventory Backend API. It allows users to view, add, and delete car inventory items.

## Features

- **Car Listing**: Displays all cars fetched from the backend API in a list.
- **Add Car**: Allows users to input new car details (make, model, year, price) and send them to the backend.
- **Delete Car**: Swipe-to-delete functionality for individual cars.
- **Delete All Cars**: Button to clear the entire inventory via the backend API.
- **Loading & Error States**: Provides visual feedback for API calls and displays any errors.

## Technologies Used

- **Swift**: Apple's powerful and intuitive programming language.
- **SwiftUI**: Apple's declarative UI framework for building apps across all Apple platforms.
- **Xcode**: Integrated Development Environment for Apple platforms.
- **URLSession**: For making network requests to the backend API.
- **Codable**: Swift's protocol for easy JSON serialization/deserialization.
