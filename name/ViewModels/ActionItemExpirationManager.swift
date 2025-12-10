//
//  ActionItemExpirationManager.swift
//  name
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  Manages automatic expiration of stale action items.
//  Checks for items older than 90 days and moves them to archive.
//  Called on app launch and can be triggered periodically.
//

import Foundation

/// Manages auto-expiration of action items older than 90 days
@MainActor
class ActionItemExpirationManager {
    
    // MARK: - Static Methods
    
    /// Checks for expired action items and archives them
    /// Should be called on app launch and periodically
    static func checkExpiredItems() async {
        let apiService = APIService()
        
        do {
            let response = try await apiService.expireOldActionItems()
            
            // Update local state - remove expired items from active list
            if !response.expired_ids.isEmpty {
                AppState.shared.activeActionItems.removeAll { item in
                    response.expired_ids.contains(item.id)
                }
                
                // Update action item count
                AppState.shared.actionItemCount = AppState.shared.activeActionItems.count
                
                print("✅ Expired \(response.count) stale action items")
            }
        } catch {
            // Silent fail - expiration is a background operation
            print("❌ Failed to check expired items: \(error.localizedDescription)")
        }
    }
    
    /// Checks if an action item is approaching expiration
    /// - Parameter createdAt: ISO8601 date string of when item was created
    /// - Returns: Number of days until expiration (90 day threshold)
    static func daysUntilExpiration(createdAt: String) -> Int? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let createdDate = formatter.date(from: createdAt) else {
            return nil
        }
        
        let expirationDate = Calendar.current.date(byAdding: .day, value: 90, to: createdDate)!
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day
        
        return daysRemaining
    }
    
    /// Checks if an item is close to expiring (within 7 days)
    /// - Parameter createdAt: ISO8601 date string of when item was created
    /// - Returns: True if item expires within 7 days
    static func isNearExpiration(createdAt: String) -> Bool {
        guard let daysRemaining = daysUntilExpiration(createdAt: createdAt) else {
            return false
        }
        return daysRemaining <= 7 && daysRemaining > 0
    }
}
