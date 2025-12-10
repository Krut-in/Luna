//
//  ChatManagerTests.swift
//  nameTests
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  Unit tests for ChatManager functionality.
//

import XCTest
@testable import name

final class ChatManagerTests: XCTestCase {
    
    var chatManager: ChatManager!
    var mockAPIService: MockChatAPIService!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockAPIService = MockChatAPIService()
        chatManager = ChatManager(apiService: mockAPIService)
    }
    
    override func tearDown() {
        chatManager = nil
        mockAPIService = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    @MainActor
    func testLoadMessages_Success() async {
        // Given
        mockAPIService.mockMessages = [
            ChatMessage(
                id: "msg_1",
                chat_id: "chat_1",
                content: "Hello!",
                sender_id: "user_1",
                sender_name: "Alice",
                sender_avatar: "https://example.com/avatar1.jpg",
                timestamp: "2025-12-10T10:00:00Z"
            )
        ]
        
        // When
        await chatManager.loadMessages(chatId: "chat_1")
        
        // Then
        XCTAssertEqual(chatManager.getMessages(chatId: "chat_1").count, 1)
        XCTAssertEqual(chatManager.getMessages(chatId: "chat_1").first?.content, "Hello!")
        XCTAssertFalse(chatManager.isLoading)
        XCTAssertNil(chatManager.errorMessage)
    }
    
    @MainActor
    func testSendMessage_OptimisticUpdate() async {
        // Given
        let chatId = "chat_1"
        let content = "Test message"
        
        // When - Send message (will add optimistically)
        await chatManager.sendMessage(
            chatId: chatId,
            content: content,
            userId: "user_1",
            userName: "Test User",
            userAvatar: "https://example.com/avatar.jpg"
        )
        
        // Then - Message should be present (either temp or saved)
        let messages = chatManager.getMessages(chatId: chatId)
        XCTAssertEqual(messages.count, 1)
        XCTAssertEqual(messages.first?.content, content)
    }
    
    @MainActor
    func testPolling_StartsAndStops() async {
        // Given
        let chatId = "chat_1"
        
        // When - Start polling
        chatManager.startPolling(chatId: chatId)
        
        // Then
        XCTAssertTrue(chatManager.pollingChats.contains(chatId))
        
        // When - Stop polling
        chatManager.stopPolling(chatId: chatId)
        
        // Then
        XCTAssertFalse(chatManager.pollingChats.contains(chatId))
    }
    
    @MainActor
    func testStopAllPolling() async {
        // Given
        chatManager.startPolling(chatId: "chat_1")
        chatManager.startPolling(chatId: "chat_2")
        
        // When
        chatManager.stopAllPolling()
        
        // Then
        XCTAssertTrue(chatManager.pollingChats.isEmpty)
    }
    
    @MainActor
    func testFetchActiveChats_Success() async {
        // Given
        mockAPIService.mockChats = [
            Chat(
                id: "chat_1",
                venue_id: "venue_1",
                venue: ChatVenueInfo(
                    id: "venue_1",
                    name: "Test Venue",
                    category: "Coffee Shop",
                    image: "https://example.com/venue.jpg"
                ),
                last_message: "Last message",
                last_message_at: "2025-12-10T10:00:00Z",
                participant_count: 3,
                created_at: "2025-12-10T09:00:00Z"
            )
        ]
        
        // When
        await chatManager.fetchActiveChats(userId: "user_1")
        
        // Then
        XCTAssertEqual(chatManager.activeChats.count, 1)
        XCTAssertEqual(chatManager.activeChats.first?.venue?.name, "Test Venue")
    }
}

// MARK: - Mock API Service

class MockChatAPIService: APIServiceProtocol {
    var mockChats: [Chat] = []
    var mockMessages: [ChatMessage] = []
    var shouldThrowError = false
    
    func fetchUserChats(userId: String) async throws -> [Chat] {
        if shouldThrowError { throw APIError.unknown }
        return mockChats
    }
    
    func fetchChatMessages(chatId: String, since: String?) async throws -> ChatMessagesResponse {
        if shouldThrowError { throw APIError.unknown }
        return ChatMessagesResponse(messages: mockMessages, chat: nil, participants: nil)
    }
    
    func sendMessage(chatId: String, userId: String, content: String) async throws -> SendMessageResponse {
        if shouldThrowError { throw APIError.unknown }
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
    
    // MARK: - Existing Protocol Requirements (stubs)
    
    func fetchVenues(userId: String?, filters: VenueFilters?) async throws -> [VenueListItem] { [] }
    func fetchVenueDetail(venueId: String) async throws -> VenueDetailResponse {
        throw APIError.unknown
    }
    func expressInterest(userId: String, venueId: String) async throws -> InterestResponse {
        throw APIError.unknown
    }
    func fetchUserProfile(userId: String) async throws -> UserProfileResponse {
        throw APIError.unknown
    }
    func fetchRecommendations(userId: String) async throws -> [RecommendationItem] { [] }
    func fetchUserBookings(userId: String) async throws -> [BookingItem] { [] }
    func fetchVenueBooking(venueId: String) async throws -> VenueBookingResponse {
        throw APIError.unknown
    }
    func completeActionItem(itemId: String, userId: String) async throws -> SuccessResponse {
        throw APIError.unknown
    }
    func dismissActionItem(itemId: String, userId: String) async throws -> SuccessResponse {
        throw APIError.unknown
    }
    func fetchActivities(userId: String, page: Int, limit: Int) async throws -> ActivitiesResponse {
        throw APIError.unknown
    }
    func fetchSocialFeed(userId: String, page: Int, limit: Int, since: Date?) async throws -> SocialFeedResponse {
        throw APIError.unknown
    }
    func initiateActionItem(itemId: String, userId: String) async throws -> InitiateActionItemResponse {
        throw APIError.unknown
    }
    func confirmActionItem(itemId: String, userId: String) async throws -> ConfirmationActionResponse {
        throw APIError.unknown
    }
    func declineActionItem(itemId: String, userId: String) async throws -> ConfirmationActionResponse {
        throw APIError.unknown
    }
    func getActionItemStatus(itemId: String) async throws -> ActionItemStatusResponse {
        throw APIError.unknown
    }
    
    // MARK: - Archive Methods (stubs)
    
    func fetchArchivedActionItems(userId: String) async throws -> [ArchivedActionItem] { [] }
    func deleteActionItemPermanently(itemId: String) async throws -> SuccessResponse {
        throw APIError.unknown
    }
    func expireOldActionItems() async throws -> ExpireActionItemsResponse {
        ExpireActionItemsResponse(expired_ids: [], count: 0)
    }
}
