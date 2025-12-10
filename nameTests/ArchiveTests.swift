//
//  ArchiveTests.swift
//  nameTests
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  Tests for archive operations including API decoding, state management,
//  and expiration logic.
//

import XCTest
@testable import name

final class ArchiveTests: XCTestCase {
    
    var apiService: APIService!
    var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        
        // Configure URLProtocol for mocking
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
        
        apiService = APIService(baseURL: "https://api.test.com", session: mockSession)
    }
    
    override func tearDown() {
        apiService = nil
        mockSession = nil
        MockURLProtocol.reset()
        super.tearDown()
    }
    
    // MARK: - Archive API Tests
    
    func testFetchArchivedItems_SuccessfulDecoding() async throws {
        // Given
        let json = """
        {
            "items": [
                {
                    "id": "archive_1",
                    "venue_id": "venue_1",
                    "venue": null,
                    "status": "completed",
                    "archived_at": "2024-12-01T10:00:00Z",
                    "created_at": "2024-11-01T10:00:00Z"
                },
                {
                    "id": "archive_2",
                    "venue_id": "venue_2",
                    "venue": null,
                    "status": "dismissed",
                    "archived_at": "2024-12-02T10:00:00Z",
                    "created_at": "2024-11-02T10:00:00Z"
                }
            ]
        }
        """
        MockURLProtocol.mockResponse = (json.data(using: .utf8)!, 200)
        
        // When
        let items = try await apiService.fetchArchivedActionItems(userId: "user_1")
        
        // Then
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].id, "archive_1")
        XCTAssertEqual(items[0].status, "completed")
        XCTAssertEqual(items[1].id, "archive_2")
        XCTAssertEqual(items[1].status, "dismissed")
    }
    
    func testDeleteActionItem_SuccessfulResponse() async throws {
        // Given
        let json = """
        {
            "success": true,
            "message": "Item permanently deleted"
        }
        """
        MockURLProtocol.mockResponse = (json.data(using: .utf8)!, 200)
        
        // When
        let response = try await apiService.deleteActionItemPermanently(itemId: "item_1")
        
        // Then
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.message, "Item permanently deleted")
    }
    
    func testExpireOldActionItems_SuccessfulResponse() async throws {
        // Given
        let json = """
        {
            "expired_ids": ["item_1", "item_2", "item_3"],
            "count": 3
        }
        """
        MockURLProtocol.mockResponse = (json.data(using: .utf8)!, 200)
        
        // When
        let response = try await apiService.expireOldActionItems()
        
        // Then
        XCTAssertEqual(response.count, 3)
        XCTAssertEqual(response.expired_ids.count, 3)
        XCTAssertTrue(response.expired_ids.contains("item_1"))
        XCTAssertTrue(response.expired_ids.contains("item_2"))
        XCTAssertTrue(response.expired_ids.contains("item_3"))
    }
    
    // MARK: - Expiration Logic Tests
    
    @MainActor
    func testDaysUntilExpiration_ValidDate() {
        // Given - item created 30 days ago (60 days until expiration)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let createdAt = formatter.string(from: thirtyDaysAgo)
        
        // When
        let daysRemaining = ActionItemExpirationManager.daysUntilExpiration(createdAt: createdAt)
        
        // Then
        XCTAssertNotNil(daysRemaining)
        XCTAssertEqual(daysRemaining!, 60, accuracy: 1) // Allow 1 day variance for time zones
    }
    
    @MainActor
    func testIsNearExpiration_WithinSevenDays() {
        // Given - item created 85 days ago (5 days until expiration)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let eightyFiveDaysAgo = Calendar.current.date(byAdding: .day, value: -85, to: Date())!
        let createdAt = formatter.string(from: eightyFiveDaysAgo)
        
        // When
        let isNear = ActionItemExpirationManager.isNearExpiration(createdAt: createdAt)
        
        // Then
        XCTAssertTrue(isNear)
    }
    
    @MainActor
    func testIsNearExpiration_NotNearExpiration() {
        // Given - item created 30 days ago (60 days until expiration)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let createdAt = formatter.string(from: thirtyDaysAgo)
        
        // When
        let isNear = ActionItemExpirationManager.isNearExpiration(createdAt: createdAt)
        
        // Then
        XCTAssertFalse(isNear)
    }
    
    // MARK: - Model Tests
    
    func testArchivedActionItem_FormattedDate() {
        // Given
        let item = ArchivedActionItem(
            id: "test",
            venue_id: "venue_1",
            venue: nil,
            status: "completed",
            archived_at: "2024-12-10T15:30:00.000Z",
            created_at: "2024-11-10T10:00:00.000Z"
        )
        
        // When
        let formattedDate = item.formattedArchivedDate
        
        // Then
        XCTAssertFalse(formattedDate.isEmpty)
        // The formatted date should contain "Dec" or similar month indicator
        XCTAssertTrue(formattedDate.contains("Dec") || formattedDate.contains("10"))
    }
}
