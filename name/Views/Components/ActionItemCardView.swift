//
//  ActionItemCardView.swift
//  name
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  Card component for displaying action items in the Action Tab.
//  Shows venue info, friend avatars, and action buttons.
//
//  DESIGN SPECIFICATIONS:
//  - Venue image thumbnail: 75x75pt, rounded corners
//  - Venue name: Bold, 18pt
//  - Distance indicator: Calculated from user location
//  - Friend avatar stack: Max 5 visible, "+N" overflow
//  - "Go Ahead" button: Primary blue, 44pt touch target
//  - "Dismiss" button: Secondary gray, 44pt touch target
//  - Card tappable for venue navigation
//  - NO action_code display (LUNA-xxx hidden)
//

import SwiftUI

struct ActionItemCardView: View {
    
    // MARK: - Properties
    
    let actionItem: ActionItem
    let onGoAhead: () -> Void
    let onDismiss: () -> Void
    let onTapCard: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onTapCard) {
            VStack(alignment: .leading, spacing: Theme.Layout.spacing) {
                // Top row: Image + Info
                HStack(alignment: .top, spacing: Theme.Layout.spacing) {
                    // Venue Image Thumbnail
                    venueImageView
                    
                    // Venue Info
                    VStack(alignment: .leading, spacing: 6) {
                        // Venue Name
                        if let venue = actionItem.venue {
                            Text(venue.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Theme.Colors.textPrimary)
                                .lineLimit(2)
                            
                            // Category
                            Text(venue.category)
                                .font(Theme.Fonts.subheadline)
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            // Distance indicator
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 12))
                                Text(distanceText)
                            }
                            .font(Theme.Fonts.caption)
                            .foregroundColor(Theme.Colors.textTertiary)
                        } else {
                            Text("Venue")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Theme.Colors.textPrimary)
                        }
                    }
                    
                    Spacer()
                }
                
                // Friend Avatar Stack
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(Theme.Fonts.caption)
                        Text("\(actionItem.interested_user_ids.count) friends interested")
                            .font(Theme.Fonts.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(Theme.Colors.accent)
                    
                    AvatarStackView(avatarURLs: mockAvatarURLs)
                }
                
                // Action Buttons
                HStack(spacing: Theme.Layout.spacing) {
                    // Go Ahead Button (Primary)
                    Button(action: onGoAhead) {
                        Text("Go Ahead")
                            .font(Theme.Fonts.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Theme.Colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.smallCornerRadius))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Dismiss Button (Secondary)
                    Button(action: onDismiss) {
                        Text("Dismiss")
                            .font(Theme.Fonts.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Theme.Colors.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.smallCornerRadius))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(Theme.Layout.padding)
            .background(Theme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius))
            .elevationMedium()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Subviews
    
    private var venueImageView: some View {
        Group {
            if let venue = actionItem.venue {
                AsyncImage(url: URL(string: venue.image)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
        .frame(width: 75, height: 75)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.smallCornerRadius))
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: Theme.Layout.smallCornerRadius)
            .fill(Theme.Colors.secondaryBackground)
            .overlay {
                Image(systemName: "photo")
                    .foregroundColor(Theme.Colors.textSecondary)
            }
    }
    
    // MARK: - Computed Properties
    
    /// Distance text (placeholder - would use location services in production)
    private var distanceText: String {
        // In a real app, this would calculate distance from user's current location
        // For now, we'll show a placeholder
        return "Nearby"
    }
    
    /// Mock avatar URLs based on interested user count
    private var mockAvatarURLs: [String] {
        // Generate placeholder avatar URLs for demonstration
        // In production, these would come from the backend with user data
        return actionItem.interested_user_ids.prefix(5).enumerated().map { index, _ in
            "https://i.pravatar.cc/100?img=\(index + 1)"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        ActionItemCardView(
            actionItem: ActionItem(
                id: "action_1",
                venue_id: "venue_1",
                interested_user_ids: ["user_1", "user_2", "user_3", "user_4", "user_5", "user_6"],
                action_type: "book_venue",
                action_code: "LUNA-venue_1-1234",
                description: "5 friends interested - coordinate plans!",
                threshold_met: true,
                status: "pending",
                created_at: "2025-12-10T10:00:00Z",
                venue: nil
            ),
            onGoAhead: {},
            onDismiss: {},
            onTapCard: {}
        )
        .padding()
    }
    .background(Theme.Colors.background)
}
