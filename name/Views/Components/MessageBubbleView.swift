//
//  MessageBubbleView.swift
//  name
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  Message bubble component for chat messages.
//  Displays differently for current user vs other users.
//
//  DESIGN SPECIFICATIONS:
//  - Blue background for current user (right aligned)
//  - Gray background for others (left aligned)
//  - Sender name shown for non-current user messages
//  - Timestamp below message
//  - 16pt corner radius
//

import SwiftUI

struct MessageBubbleView: View {
    
    // MARK: - Properties
    
    let message: ChatMessage
    let isCurrentUser: Bool
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                // Sender name (for other users only)
                if !isCurrentUser {
                    Text(message.sender_name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Message content
                Text(message.content)
                    .padding(12)
                    .background(isCurrentUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Timestamp
                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 8) {
        // Other user message
        MessageBubbleView(
            message: ChatMessage(
                id: "1",
                chat_id: "chat_1",
                content: "Hey! What time are we meeting?",
                sender_id: "user_2",
                sender_name: "Alice",
                sender_avatar: "https://i.pravatar.cc/100?img=1",
                timestamp: ISO8601DateFormatter().string(from: Date())
            ),
            isCurrentUser: false
        )
        
        // Current user message
        MessageBubbleView(
            message: ChatMessage(
                id: "2",
                chat_id: "chat_1",
                content: "Let's meet at 3pm! Does that work for everyone?",
                sender_id: "user_1",
                sender_name: "Me",
                sender_avatar: "https://i.pravatar.cc/100?img=2",
                timestamp: ISO8601DateFormatter().string(from: Date())
            ),
            isCurrentUser: true
        )
        
        // Another user message
        MessageBubbleView(
            message: ChatMessage(
                id: "3",
                chat_id: "chat_1",
                content: "Sounds good to me! 👍",
                sender_id: "user_3",
                sender_name: "Bob",
                sender_avatar: "https://i.pravatar.cc/100?img=3",
                timestamp: ISO8601DateFormatter().string(from: Date())
            ),
            isCurrentUser: false
        )
    }
    .padding(.vertical)
    .background(Theme.Colors.background)
}
