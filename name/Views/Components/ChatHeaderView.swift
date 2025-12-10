//
//  ChatHeaderView.swift
//  name
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  Header component for chat view showing venue info and participants.
//
//  DESIGN SPECIFICATIONS:
//  - Venue thumbnail: 50x50pt with rounded corners
//  - Venue name: Headline font
//  - Participant avatar stack
//  - Participant count text in secondary color
//

import SwiftUI

struct ChatHeaderView: View {
    
    // MARK: - Properties
    
    let venue: ChatVenueInfo
    let participants: [ChatParticipant]
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 8) {
            // Venue thumbnail
            AsyncImage(url: URL(string: venue.image)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    RoundedRectangle(cornerRadius: Theme.Layout.smallCornerRadius)
                        .fill(Theme.Colors.secondaryBackground)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.smallCornerRadius))
            
            // Venue name
            Text(venue.name)
                .font(.headline)
                .foregroundColor(Theme.Colors.textPrimary)
            
            // Participant avatars
            if !participants.isEmpty {
                participantAvatarStack
            }
            
            // Participant count
            Text("\(participants.count) participants")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Subviews
    
    private var participantAvatarStack: some View {
        HStack(spacing: -8) {
            ForEach(Array(participants.prefix(5).enumerated()), id: \.element.id) { index, participant in
                AsyncImage(url: URL(string: participant.avatar)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Circle()
                            .fill(Theme.Colors.secondaryBackground)
                    }
                }
                .frame(width: 28, height: 28)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.systemGray6), lineWidth: 2))
                .zIndex(Double(5 - index))
            }
            
            // Overflow indicator
            if participants.count > 5 {
                Text("+\(participants.count - 5)")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .frame(width: 28, height: 28)
                    .background(Theme.Colors.secondaryBackground)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.systemGray6), lineWidth: 2))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        ChatHeaderView(
            venue: ChatVenueInfo(
                id: "venue_1",
                name: "Blue Bottle Coffee",
                category: "Coffee Shop",
                image: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400"
            ),
            participants: [
                ChatParticipant(id: "1", user_id: "user_1", name: "Alice", avatar: "https://i.pravatar.cc/100?img=1", joined_at: ""),
                ChatParticipant(id: "2", user_id: "user_2", name: "Bob", avatar: "https://i.pravatar.cc/100?img=2", joined_at: ""),
                ChatParticipant(id: "3", user_id: "user_3", name: "Charlie", avatar: "https://i.pravatar.cc/100?img=3", joined_at: "")
            ]
        )
        Spacer()
    }
}
