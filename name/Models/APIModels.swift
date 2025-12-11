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
    let action_items: [ActionItem]
}

/// Response from GET /recommendations endpoint
struct RecommendationsResponse: Codable {
    let recommendations: [RecommendationItem]
}

/// Score breakdown for recommendation transparency
struct ScoreBreakdown: Codable, Hashable {
    let popularity: Double      // 0-100, contribution from venue popularity
    let categoryMatch: Double   // 0-100, contribution from user category preferences
    let friendSignal: Double    // 0-100, contribution from friends' interest
    let proximity: Double       // 0-100, contribution from distance to user
    
    enum CodingKeys: String, CodingKey {
        case popularity
        case categoryMatch = "category_match"
        case friendSignal = "friend_signal"
        case proximity
    }
}

/// Individual recommendation item with score and reason
struct RecommendationItem: Codable, Identifiable, Hashable {
    let venue: Venue
    let score: Double
    let reason: String
    let already_interested: Bool
    let friends_interested: Int
    let total_interested: Int
    let score_breakdown: ScoreBreakdown?
    
    // Computed property for Identifiable conformance
    var id: String {
        venue.id
    }
}

/// Response from POST /interests endpoint
struct InterestResponse: Codable {
    let success: Bool
    let message: String?
    let action_item: ActionItemResponse?
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case action_item
    }
}

/// Action item response nested in InterestResponse
struct ActionItemResponse: Codable {
    let action_item_created: Bool
    let action_item_id: String?
    let description: String?
    let action_code: String?
    let interested_user_ids: [String]?
}

// MARK: - Action Item Models

/// Full action item model from GET /users/{user_id} endpoint
struct ActionItem: Codable, Identifiable {
    let id: String
    let venue_id: String
    let interested_user_ids: [String]
    let action_type: String // "book_venue" or "visit_venue"
    let action_code: String
    let description: String
    let threshold_met: Bool
    let status: String // "pending", "completed", "dismissed"
    let created_at: String
    let venue: Venue? // Optional venue object for convenience
    
    enum CodingKeys: String, CodingKey {
        case id
        case venue_id
        case interested_user_ids
        case action_type
        case action_code
        case description
        case threshold_met
        case status
        case created_at
        case venue
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

/// Request body for POST /action-items/{item_id}/complete endpoint
struct CompleteActionItemRequest: Codable {
    let user_id: String
}

/// Generic success response
struct SuccessResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - Confirmation Flow Models

/// Status for individual user confirmation in Go Ahead flow
struct ConfirmationStatus: Codable, Identifiable {
    let user_id: String
    let name: String
    let avatar: String
    let status: Status
    let responded_at: String?
    let is_initiator: Bool?
    
    var id: String { user_id }
    
    enum Status: String, Codable {
        case pending
        case confirmed
        case declined
    }
}

/// Initiator info in confirmation responses
struct InitiatorInfo: Codable {
    let user_id: String
    let name: String
    let avatar: String
    let status: String
}

/// Response from POST /action-items/{id}/initiate
struct InitiateActionItemResponse: Codable {
    let action_item_id: String
    let initiator: InitiatorInfo
    let confirmations: [ConfirmationStatus]
}

/// Response from POST /action-items/{id}/confirm or /decline
struct ConfirmationActionResponse: Codable {
    let success: Bool
    let message: String
    let status: String
    let confirmed_count: Int?
    let chat_created: Bool?
    let chat_id: String?
}

/// Venue info in action item status response
struct ActionItemVenueInfo: Codable {
    let id: String
    let name: String
    let category: String
    let image: String
}

/// Response from GET /action-items/{id}/status
struct ActionItemStatusResponse: Codable {
    let action_item_id: String
    let venue: ActionItemVenueInfo?
    let status: String
    let initiator: ConfirmationStatus?
    let confirmations: [ConfirmationStatus]
    let chat_created: Bool
    let chat_id: String?
}

/// Request body for initiate action item endpoint
struct InitiateActionItemRequest: Codable {
    let user_id: String
}

/// Request body for confirm/decline action item endpoint
struct ConfirmDeclineRequest: Codable {
    let user_id: String
}

// MARK: - Chat Models

/// Represents a group chat for coordinating venue visits
struct Chat: Codable, Identifiable {
    let id: String
    let venue_id: String
    let venue: ChatVenueInfo?
    let last_message: String?
    let last_message_at: String?
    let participant_count: Int
    let created_at: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case venue_id
        case venue
        case last_message
        case last_message_at
        case participant_count
        case created_at
    }
}

/// Venue info embedded in Chat response
struct ChatVenueInfo: Codable {
    let id: String
    let name: String
    let category: String
    let image: String
}

/// Represents a message in a group chat
struct ChatMessage: Codable, Identifiable {
    let id: String
    let chat_id: String
    let content: String
    let sender_id: String
    let sender_name: String
    let sender_avatar: String
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case chat_id
        case content
        case sender_id
        case sender_name
        case sender_avatar
        case timestamp
    }
    
    /// Formatted timestamp for display
    var formattedTime: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return ""
    }
}

/// Represents a participant in a chat
struct ChatParticipant: Codable, Identifiable {
    let id: String
    let user_id: String
    let name: String
    let avatar: String
    let joined_at: String
}

// MARK: - Chat API Request/Response Models

/// Response from GET /users/{id}/chats endpoint
struct UserChatsResponse: Codable {
    let chats: [Chat]
}

/// Response from GET /chats/{id}/messages endpoint
struct ChatMessagesResponse: Codable {
    let messages: [ChatMessage]
    let chat: Chat?
    let participants: [ChatParticipant]?
}

/// Request body for POST /chats/{id}/messages endpoint
struct SendMessageRequest: Codable {
    let user_id: String
    let content: String
}

/// Response from POST /chats/{id}/messages endpoint
struct SendMessageResponse: Codable {
    let success: Bool
    let message: ChatMessage?
}

// MARK: - Archive Models

/// Archived action item model
struct ArchivedActionItem: Codable, Identifiable {
    let id: String
    let venue_id: String
    let venue: Venue?
    let status: String  // "completed", "dismissed", "expired"
    let archived_at: String
    let created_at: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case venue_id
        case venue
        case status
        case archived_at
        case created_at
    }
    
    /// Formatted archived date for display
    var formattedArchivedDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: archived_at) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return archived_at
    }
}

/// Response from GET /users/{userId}/action-items/archived endpoint
struct ArchivedActionItemsResponse: Codable {
    let archived_items: [ArchivedActionItem]
    let count: Int
    
    /// Map to items for convenience
    var items: [ArchivedActionItem] { archived_items }
}

/// Response from GET /action-items/expire endpoint
struct ExpireActionItemsResponse: Codable {
    let success: Bool
    let expired_count: Int
    let checked_at: String
}
