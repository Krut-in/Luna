//
//  ActiveChatsListView.swift
//  name
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  List of active chats for displaying in Action Tab or as a section.
//  Shows venue image, name, last message preview, and participant count.
//

import SwiftUI

struct ActiveChatsListView: View {
    
    // MARK: - Properties
    
    let chats: [Chat]
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section header
            Text("Active Chats")
                .font(.headline)
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal)
            
            // Chat list
            ForEach(chats) { chat in
                NavigationLink(value: "chat_\(chat.id)") {
                    chatRow(for: chat)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Subviews
    
    private func chatRow(for chat: Chat) -> some View {
        HStack(spacing: 12) {
            // Venue image
            AsyncImage(url: URL(string: chat.venue?.image ?? "")) { phase in
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
            
            // Chat info
            VStack(alignment: .leading, spacing: 4) {
                Text(chat.venue?.name ?? "Chat")
                    .font(.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                if let lastMessage = chat.last_message {
                    Text(lastMessage)
                        .font(.subheadline)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Participant count badge
            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                Text("\(chat.participant_count)")
                    .font(.caption)
            }
            .foregroundColor(Theme.Colors.textTertiary)
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Theme.Colors.textTertiary)
        }
        .padding()
        .background(Theme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius))
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ScrollView {
            ActiveChatsListView(chats: [
                Chat(
                    id: "chat_1",
                    venue_id: "venue_1",
                    venue: ChatVenueInfo(
                        id: "venue_1",
                        name: "Blue Bottle Coffee",
                        category: "Coffee Shop",
                        image: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400"
                    ),
                    last_message: "Let's meet at 3pm!",
                    last_message_at: "2025-12-10T15:00:00Z",
                    participant_count: 4,
                    created_at: "2025-12-10T10:00:00Z"
                ),
                Chat(
                    id: "chat_2",
                    venue_id: "venue_2",
                    venue: ChatVenueInfo(
                        id: "venue_2",
                        name: "The Mill",
                        category: "Restaurant",
                        image: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400"
                    ),
                    last_message: "Anyone free this weekend?",
                    last_message_at: "2025-12-10T14:00:00Z",
                    participant_count: 3,
                    created_at: "2025-12-10T09:00:00Z"
                )
            ])
            .padding(.vertical)
        }
        .background(Theme.Colors.background)
    }
}
