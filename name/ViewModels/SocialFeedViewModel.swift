//
//  SocialFeedViewModel.swift
//  name
//
//  Created by Antigravity on 27/11/25.
//  Updated on 02/12/25 for Social Interest Activity Feed feature.
//
//  DESCRIPTION:
//  ViewModel for the social feed view, managing friend interest activities
//  and highlighted venues that have reached critical mass for group meetups.
//  
//  FEATURES:
//  - Friend interest activity feed with real-time updates
//  - Highlighted venues section for venues with 5+ interested friends
//  - Pull-to-refresh and pagination support
//  - Mock data generation for demonstration
//  - Analytics tracking for user interactions
//  
//  ARCHITECTURE:
//  - MVVM pattern with ObservableObject
//  - Integrates with AppState for global state synchronization
//  - Async/await for network calls
//  - Published properties for SwiftUI binding
//

import Foundation
import Combine

@MainActor
class SocialFeedViewModel: ObservableObject {
    
    // MARK: - Configuration
    
    /// Threshold for highlighting a venue (number of interested friends)
    static let highlightThreshold: Int = 5
    
    // MARK: - Published Properties
    
    @Published var activities: [Activity] = []
    @Published var interestActivities: [InterestActivity] = []
    @Published var highlightedVenues: [HighlightedVenue] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasMore: Bool = true
    
    // MARK: - Private Properties
    
    private let apiService: APIServiceProtocol
    private let analytics: AnalyticsServiceProtocol
    private let appState: AppState
    private let userId: String
    private var currentPage: Int = 1
    private let pageLimit: Int = 20
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        apiService: APIServiceProtocol = APIService(),
        analytics: AnalyticsServiceProtocol,
        appState: AppState = .shared,
        userId: String = "user_1"
    ) {
        self.apiService = apiService
        self.analytics = analytics
        self.appState = appState
        self.userId = userId
        
        setupObservers()
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        // Observe AppState for social feed updates
        appState.$socialFeedActivities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activities in
                self?.interestActivities = activities
            }
            .store(in: &cancellables)
        
        appState.$highlightedVenues
            .receive(on: DispatchQueue.main)
            .sink { [weak self] venues in
                self?.highlightedVenues = venues
            }
            .store(in: &cancellables)
        
        // Observe user switching to reload data with mock activities for the new user
        appState.$currentUserId
            .dropFirst() // Skip initial value
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                // Clear current activities and reload with new mock data
                self.activities = []
                Task {
                    await self.loadActivities()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Load initial activities and generate mock data if backend returns empty
    func loadActivities() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        do {
            let response = try await apiService.fetchActivities(
                userId: userId,
                page: currentPage,
                limit: pageLimit
            )
            
            activities = response.activities
            hasMore = activities.count < response.total_count
            
            // If no activities from backend, load mock data for demonstration
            if activities.isEmpty && interestActivities.isEmpty {
                loadMockData()
            }
            
            // Track analytics
            analytics.track(
                event: "social_feed_loaded",
                properties: [
                    "activity_count": activities.count + interestActivities.count,
                    "highlighted_count": highlightedVenues.count,
                    "page": currentPage
                ]
            )
            
            // Mark social feed as viewed
            appState.markSocialFeedAsViewed()
            
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            
            // Load mock data on error for demonstration
            if interestActivities.isEmpty {
                loadMockData()
            }
        }
        
        isLoading = false
    }
    
    /// Refresh activities (pull-to-refresh)
    func refreshActivities() async {
        currentPage = 1
        await loadActivities()
    }
    
    /// Load more activities (pagination)
    func loadMoreActivities() async {
        guard !isLoading, hasMore else { return }
        
        isLoading = true
        currentPage += 1
        
        do {
            let response = try await apiService.fetchActivities(
                userId: userId,
                page: currentPage,
                limit: pageLimit
            )
            
            activities.append(contentsOf: response.activities)
            hasMore = activities.count < response.total_count
            
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            currentPage -= 1
        }
        
        isLoading = false
    }
    
    /// Track activity tap for analytics
    /// - Parameter activity: Activity that was tapped
    func trackActivityTap(_ activity: Activity) {
        analytics.track(
            event: AnalyticsService.Event.socialActivityTapped,
            properties: [
                AnalyticsService.PropertyKey.venueId: activity.venue.id,
                AnalyticsService.PropertyKey.venueName: activity.venue.name,
                AnalyticsService.PropertyKey.category: activity.venue.category,
                AnalyticsService.PropertyKey.action: activity.action
            ]
        )
    }
    
    /// Track interest activity tap for analytics
    /// - Parameter activity: InterestActivity that was tapped
    func trackInterestActivityTap(_ activity: InterestActivity) {
        analytics.track(
            event: AnalyticsService.Event.socialActivityTapped,
            properties: [
                AnalyticsService.PropertyKey.venueId: activity.venue.id,
                AnalyticsService.PropertyKey.venueName: activity.venue.name,
                AnalyticsService.PropertyKey.category: activity.venue.category,
                AnalyticsService.PropertyKey.action: activity.action.rawValue
            ]
        )
    }
    
    /// Track highlighted venue tap for analytics
    /// - Parameter venue: HighlightedVenue that was tapped
    func trackHighlightedVenueTap(_ venue: HighlightedVenue) {
        analytics.track(
            event: "highlighted_venue_tapped",
            properties: [
                "venue_id": venue.venueId,
                "venue_name": venue.venueName,
                "interested_count": venue.totalInterestedCount,
                "category": venue.venueCategory
            ]
        )
    }
    
    /// Track plan meetup action for analytics
    /// - Parameter venue: HighlightedVenue for which meetup was initiated
    func trackPlanMeetupTap(_ venue: HighlightedVenue) {
        analytics.track(
            event: "plan_meetup_initiated",
            properties: [
                "venue_id": venue.venueId,
                "venue_name": venue.venueName,
                "friend_count": venue.interestedFriends.count
            ]
        )
    }
    
    // MARK: - Mock Data Generation
    
    /// Loads mock data for demonstration when backend is unavailable
    private func loadMockData() {
        // Generate mock friend activities (excluding current user)
        let mockActivities = generateMockInterestActivities()
        interestActivities = mockActivities
        appState.socialFeedActivities = mockActivities
        
        // Generate mock highlighted venues
        let mockHighlighted = generateMockHighlightedVenues()
        highlightedVenues = mockHighlighted
        appState.highlightedVenues = mockHighlighted
    }
    
    /// Generates mock interest activities for demonstration
    /// Excludes the current user from the mock friends list
    private func generateMockInterestActivities() -> [InterestActivity] {
        let currentUserId = appState.currentUserId
        
        // All possible mock friends - filter out current user
        let allMockFriends = [
            ("user_1", "Alex Chen", "https://i.pravatar.cc/150?img=11"),
            ("user_2", "Jordan Kim", "https://i.pravatar.cc/150?img=12"),
            ("user_3", "Sam Rivera", "https://i.pravatar.cc/150?img=13"),
            ("user_4", "Taylor Lee", "https://i.pravatar.cc/150?img=14"),
            ("user_5", "Maya Patel", "https://i.pravatar.cc/150?img=4"),
            ("user_6", "Chris Wong", "https://i.pravatar.cc/150?img=5"),
            ("user_7", "Emma Davis", "https://i.pravatar.cc/150?img=6")
        ]
        
        // Filter out the current user so they don't see their own activity
        let mockFriends = allMockFriends.filter { $0.0 != currentUserId }
        
        let mockVenues = [
            ("venue_1", "Blue Bottle Coffee", "Coffee Shop", "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb"),
            ("venue_2", "The Rustic Table", "Restaurant", "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4"),
            ("venue_3", "Vinyl Lounge", "Bar", "https://images.unsplash.com/photo-1543007630-9710e4a00a20"),
            ("venue_4", "Golden Gate Park", "Park", "https://images.unsplash.com/photo-1501594907352-04cda38ebc29"),
            ("venue_5", "SFMOMA", "Museum", "https://images.unsplash.com/photo-1554907984-15263bfd63bd"),
            ("venue_6", "Tartine Bakery", "Bakery", "https://images.unsplash.com/photo-1509042239860-f550ce710b93")
        ]
        
        var activities: [InterestActivity] = []
        
        // Generate activities for the past 24 hours
        for (index, friend) in mockFriends.prefix(5).enumerated() {
            let venue = mockVenues[index % mockVenues.count]
            let hoursAgo = Double(index + 1) * 3
            
            let activity = InterestActivity(
                id: "activity_\(friend.0)_\(venue.0)",
                user: ActivityUser(id: friend.0, name: friend.1, avatar: friend.2),
                venue: ActivityVenue(id: venue.0, name: venue.1, category: venue.2, image: venue.3),
                action: .interested,
                timestamp: Date().addingTimeInterval(-hoursAgo * 3600),
                isActive: true
            )
            activities.append(activity)
        }
        
        return activities
    }
    
    /// Generates mock highlighted venues for demonstration
    /// Excludes the current user from the interested friends list
    private func generateMockHighlightedVenues() -> [HighlightedVenue] {
        let currentUserId = appState.currentUserId
        
        // All possible mock friends - filter out current user
        let allMockFriends = [
            FriendSummary(id: "user_1", name: "Alex Chen", avatarURL: "https://i.pravatar.cc/150?img=11", interestedTimestamp: Date().addingTimeInterval(-3600)),
            FriendSummary(id: "user_2", name: "Jordan Kim", avatarURL: "https://i.pravatar.cc/150?img=12", interestedTimestamp: Date().addingTimeInterval(-7200)),
            FriendSummary(id: "user_3", name: "Sam Rivera", avatarURL: "https://i.pravatar.cc/150?img=13", interestedTimestamp: Date().addingTimeInterval(-10800)),
            FriendSummary(id: "user_4", name: "Taylor Lee", avatarURL: "https://i.pravatar.cc/150?img=14", interestedTimestamp: Date().addingTimeInterval(-14400)),
            FriendSummary(id: "user_5", name: "Maya Patel", avatarURL: "https://i.pravatar.cc/150?img=4", interestedTimestamp: Date().addingTimeInterval(-18000)),
            FriendSummary(id: "user_6", name: "Chris Wong", avatarURL: "https://i.pravatar.cc/150?img=5", interestedTimestamp: Date().addingTimeInterval(-21600)),
            FriendSummary(id: "user_7", name: "Emma Davis", avatarURL: "https://i.pravatar.cc/150?img=6", interestedTimestamp: Date().addingTimeInterval(-25200))
        ]
        
        // Filter out the current user
        let mockFriends = allMockFriends.filter { $0.id != currentUserId }
        
        return [
            HighlightedVenue(
                id: "highlighted_1",
                venueId: "venue_1",
                venueName: "Blue Bottle Coffee",
                venueImageURL: "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb",
                venueCategory: "Coffee Shop",
                venueAddress: "315 Linden St, San Francisco",
                interestedFriends: Array(mockFriends.prefix(6)),
                totalInterestedCount: min(6, mockFriends.count),
                threshold: SocialFeedViewModel.highlightThreshold,
                lastActivityTimestamp: Date().addingTimeInterval(-1800)
            ),
            HighlightedVenue(
                id: "highlighted_2",
                venueId: "venue_2",
                venueName: "The Rustic Table",
                venueImageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4",
                venueCategory: "Restaurant",
                venueAddress: "456 Market St, San Francisco",
                interestedFriends: Array(mockFriends.prefix(5)),
                totalInterestedCount: min(5, mockFriends.count),
                threshold: SocialFeedViewModel.highlightThreshold,
                lastActivityTimestamp: Date().addingTimeInterval(-5400)
            )
        ]
    }
}
