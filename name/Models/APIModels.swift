//
//  APIModels.swift
//  name
//
//  Created by Krutin Rathod on 21/11/25.
//
//  DESCRIPTION:
//  Data transfer objects (DTOs) for API communication with the Luna backend.
//  Defines request and response models for all API endpoints.
//  
//  MODEL ORGANIZATION:
//  - Response Wrappers: Top-level API response structures
//  - Request Models: Payload structures for POST requests
//  - Nested Models: Referenced from other model files (User, Venue)
//  
//  API ENDPOINT MAPPING:
//  - VenuesResponse: GET /venues
//  - VenueDetailResponse: GET /venues/{id}
//  - UserProfileResponse: GET /users/{id}
//  - RecommendationsResponse: GET /recommendations
//  - InterestRequest: POST /interests (request)
//  - InterestResponse: POST /interests (response)
//  
//  CODABLE CONFORMANCE:
//  - All models conform to Codable for JSON serialization
//  - Snake_case property names match backend convention
//  - Optional fields handle missing backend data gracefully
//  
//  SPECIAL HANDLING:
//  - RecommendationItem conforms to Identifiable for ForEach loops
//  - Hashable conformance enables Set operations
//  - Computed id property derived from nested venue.id
//  
//  VALIDATION:
//  - Models validate automatically via Codable
//  - Decoding errors propagate to APIError.decodingError
//  - Type safety enforced at compile time
//

import Foundation

// MARK: - API Response Wrappers

/// Response from GET /venues endpoint
struct VenuesResponse: Codable {
    let venues: [VenueListItem]
}

/// Response from GET /venues/{venue_id} endpoint
struct VenueDetailResponse: Codable {
    let venue: Venue
    let interested_users: [User]
}

/// Response from GET /users/{user_id} endpoint
struct UserProfileResponse: Codable {
    let user: User
    let interested_venues: [Venue]
}

/// Response from GET /recommendations endpoint
struct RecommendationsResponse: Codable {
    let recommendations: [RecommendationItem]
}

/// Individual recommendation item with score and reason
struct RecommendationItem: Codable, Identifiable, Hashable {
    let venue: Venue
    let score: Double
    let reason: String
    let already_interested: Bool
    let friends_interested: Int
    let total_interested: Int
    
    // Computed property for Identifiable conformance
    var id: String {
        venue.id
    }
}

/// Response from POST /interests endpoint
struct InterestResponse: Codable {
    let success: Bool
    let agent_triggered: Bool?
    let message: String?
    let reservation_code: String?
    let booking_cancelled: Bool?
    
    enum CodingKeys: String, CodingKey {
        case success
        case agent_triggered
        case message
        case reservation_code
        case booking_cancelled
    }
}

// MARK: - Booking Models

/// Response from GET /bookings/{user_id} endpoint
struct UserBookingsResponse: Codable {
    let bookings: [BookingItem]
}

/// Response from GET /venues/{venue_id}/booking endpoint
struct VenueBookingResponse: Codable {
    let has_booking: Bool
    let booking: BookingDetail?
}

/// Individual booking item for user bookings list
struct BookingItem: Codable, Identifiable {
    let id: String
    let venue: BookingVenue
    let reservation_code: String
    let created_at: String
    let party_size: Int
}

/// Venue details in booking response (subset of full Venue)
struct BookingVenue: Codable {
    let id: String
    let name: String
    let category: String
    let image: String
    let address: String
}

/// Booking details for venue booking check
struct BookingDetail: Codable {
    let id: String
    let reservation_code: String
    let created_at: String
    let party_size: Int
}

// MARK: - Request Models

/// Request body for POST /interests endpoint
struct InterestRequest: Codable {
    let user_id: String
    let venue_id: String
}
