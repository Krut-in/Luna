//
//  MockAPIService.swift
//  nameTests
//
//  Created for MVI Foundation Sprint - CI-1
//
//  DESCRIPTION:
//  Mock implementation of APIServiceProtocol for unit testing.
//  Provides configurable responses and error scenarios without network calls.
//
//  FEATURES:
//  - Configurable success/error responses
//  - In-memory test data
//  - No actual network requests
//  - Thread-safe for concurrent tests
//

import Foundation
@testable import name

@MainActor
class MockAPIService: APIServiceProtocol {
    
    // MARK: - Configuration Properties
    
    var shouldFail = false
    var errorToThrow: Error = APIError.unknown
    var venuesResponse: [VenueListItem] = []
    var venueDetailResponse: VenueDetailResponse?
    var interestResponse: InterestResponse?
    var userProfileResponse: UserProfileResponse?
    var recommendationsResponse: [RecommendationItem] = []
    var userBookingsResponse: [BookingItem] = []
    var venueBookingResponse: VenueBookingResponse?
    var successResponse: SuccessResponse?
    
    // MARK: - Call Tracking
    
    var fetchVenuesCalled = false
    var fetchVenueDetailCalled = false
    var expressInterestCalled = false
    var fetchUserProfileCalled = false
    var fetchRecommendationsCalled = false
    var lastUserId: String?
    var lastVenueId: String?
    var lastFilters: VenueFilters?
    
    // MARK: - APIServiceProtocol Implementation
    
    func fetchVenues(userId: String?, filters: VenueFilters?) async throws -> [VenueListItem] {
        fetchVenuesCalled = true
        lastUserId = userId
        lastFilters = filters
        
        if shouldFail {
            throw errorToThrow
        }
        
        return venuesResponse
    }
    
    func fetchVenueDetail(venueId: String) async throws -> VenueDetailResponse {
        fetchVenueDetailCalled = true
        lastVenueId = venueId
        
        if shouldFail {
            throw errorToThrow
        }
        
        guard let response = venueDetailResponse else {
            throw APIError.noData
        }
        
        return response
    }
    
    func expressInterest(userId: String, venueId: String) async throws -> InterestResponse {
        expressInterestCalled = true
        lastUserId = userId
        lastVenueId = venueId
        
        if shouldFail {
            throw errorToThrow
        }
        
        guard let response = interestResponse else {
            throw APIError.noData
        }
        
        return response
    }
    
    func fetchUserProfile(userId: String) async throws -> UserProfileResponse {
        fetchUserProfileCalled = true
        lastUserId = userId
        
        if shouldFail {
            throw errorToThrow
        }
        
        guard let response = userProfileResponse else {
            throw APIError.noData
        }
        
        return response
    }
    
    func fetchRecommendations(userId: String) async throws -> [RecommendationItem] {
        fetchRecommendationsCalled = true
        lastUserId = userId
        
        if shouldFail {
            throw errorToThrow
        }
        
        return recommendationsResponse
    }
    
    func fetchUserBookings(userId: String) async throws -> [BookingItem] {
        lastUserId = userId
        
        if shouldFail {
            throw errorToThrow
        }
        
        return userBookingsResponse
    }
    
    func fetchVenueBooking(venueId: String) async throws -> VenueBookingResponse {
        lastVenueId = venueId
        
        if shouldFail {
            throw errorToThrow
        }
        
        guard let response = venueBookingResponse else {
            throw APIError.noData
        }
        
        return response
    }
    
    func completeActionItem(itemId: String, userId: String) async throws -> SuccessResponse {
        lastUserId = userId
        
        if shouldFail {
            throw errorToThrow
        }
        
        guard let response = successResponse else {
            throw APIError.noData
        }
        
        return response
    }
    
    func dismissActionItem(itemId: String, userId: String) async throws -> SuccessResponse {
        lastUserId = userId
        
        if shouldFail {
            throw errorToThrow
        }
        
        guard let response = successResponse else {
            throw APIError.noData
        }
        
        return response
    }
    
    // MARK: - Test Helper Methods
    
    func reset() {
        shouldFail = false
        errorToThrow = APIError.unknown
        venuesResponse = []
        venueDetailResponse = nil
        interestResponse = nil
        userProfileResponse = nil
        recommendationsResponse = []
        
        fetchVenuesCalled = false
        fetchVenueDetailCalled = false
        expressInterestCalled = false
        fetchUserProfileCalled = false
        fetchRecommendationsCalled = false
        lastUserId = nil
        lastVenueId = nil
        lastFilters = nil
    }
    
    // MARK: - Factory Methods for Test Data
    
    static func createMockVenue(
        id: String = "venue_1",
        name: String = "Test Venue",
        category: String = "Coffee Shop",
        interestedCount: Int = 5,
        distance: Double? = 2.5
    ) -> VenueListItem {
        return VenueListItem(
            id: id,
            name: name,
            category: category,
            image: "https://example.com/image.jpg",
            interested_count: interestedCount,
            distance_km: distance
        )
    }
    
    static func createMockVenues() -> [VenueListItem] {
        return [
            createMockVenue(id: "venue_1", name: "Coffee Hub", category: "Coffee Shop", interestedCount: 10, distance: 1.2),
            createMockVenue(id: "venue_2", name: "Pizza Palace", category: "Restaurant", interestedCount: 25, distance: 3.5),
            createMockVenue(id: "venue_3", name: "Night Club", category: "Bar", interestedCount: 15, distance: 5.0),
            createMockVenue(id: "venue_4", name: "Art Gallery", category: "Activity", interestedCount: 8, distance: 0.8)
        ]
    }
    
    // MARK: - Social Feed Methods
    
    func fetchActivities(userId: String, page: Int, limit: Int) async throws -> ActivitiesResponse {
        if shouldFail { throw errorToThrow }
        throw APIError.noData
    }
    
    func fetchSocialFeed(userId: String, page: Int, limit: Int, since: Date?) async throws -> SocialFeedResponse {
        if shouldFail { throw errorToThrow }
        throw APIError.noData
    }
    
    // MARK: - Go Ahead Confirmation Flow Methods
    
    func initiateActionItem(itemId: String, userId: String) async throws -> InitiateActionItemResponse {
        if shouldFail { throw errorToThrow }
        throw APIError.noData
    }
    
    func confirmActionItem(itemId: String, userId: String) async throws -> ConfirmationActionResponse {
        if shouldFail { throw errorToThrow }
        throw APIError.noData
    }
    
    func declineActionItem(itemId: String, userId: String) async throws -> ConfirmationActionResponse {
        if shouldFail { throw errorToThrow }
        throw APIError.noData
    }
    
    func getActionItemStatus(itemId: String) async throws -> ActionItemStatusResponse {
        if shouldFail { throw errorToThrow }
        throw APIError.noData
    }
    
    // MARK: - Chat Methods
    
    var mockChats: [Chat] = []
    var mockMessages: [ChatMessage] = []
    
    func fetchUserChats(userId: String) async throws -> [Chat] {
        if shouldFail { throw errorToThrow }
        return mockChats
    }
    
    func fetchChatMessages(chatId: String, since: String?) async throws -> ChatMessagesResponse {
        if shouldFail { throw errorToThrow }
        return ChatMessagesResponse(messages: mockMessages, chat: nil, participants: nil)
    }
    
    func sendMessage(chatId: String, userId: String, content: String) async throws -> SendMessageResponse {
        if shouldFail { throw errorToThrow }
        let message = ChatMessage(
            id: UUID().uuidString,
            chat_id: chatId,
            content: content,
            sender_id: userId,
            sender_name: "Test User",
            sender_avatar: "https://example.com/avatar.jpg",
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
        return SendMessageResponse(success: true, message: message)
    }
    
    // MARK: - Archive Methods
    
    var mockArchivedItems: [ArchivedActionItem] = []
    var mockExpireResponse: ExpireActionItemsResponse?
    
    func fetchArchivedActionItems(userId: String) async throws -> [ArchivedActionItem] {
        if shouldFail { throw errorToThrow }
        return mockArchivedItems
    }
    
    func deleteActionItemPermanently(itemId: String) async throws -> SuccessResponse {
        if shouldFail { throw errorToThrow }
        return successResponse ?? SuccessResponse(success: true, message: "Item deleted")
    }
    
    func expireOldActionItems() async throws -> ExpireActionItemsResponse {
        if shouldFail { throw errorToThrow }
        return mockExpireResponse ?? ExpireActionItemsResponse(expired_ids: [], count: 0)
    }
}
