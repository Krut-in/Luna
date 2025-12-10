//
//  ChatView.swift
//  name
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  Main chat view for group conversations about venue visits.
//  Displays venue header, messages, and input bar.
//
//  FEATURES:
//  - ChatHeaderView with venue and participants
//  - Scrollable message list (newest at bottom)
//  - Input bar with text field and send button
//  - 5-second polling for new messages
//  - Polling stops when view disappears
//

import SwiftUI

struct ChatView: View {
    
    // MARK: - Properties
    
    let chatId: String
    let venue: ChatVenueInfo
    
    @StateObject private var chatManager = ChatManager()
    @ObservedObject private var appState = AppState.shared
    @State private var newMessageText: String = ""
    @FocusState private var isInputFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ChatHeaderView(
                venue: venue,
                participants: chatManager.getParticipants(chatId: chatId)
            )
            
            // Messages
            messagesScrollView
            
            // Input bar
            inputBar
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await chatManager.loadMessages(chatId: chatId)
            chatManager.startPolling(chatId: chatId)
        }
        .onDisappear {
            chatManager.stopPolling(chatId: chatId)
        }
    }
    
    // MARK: - Subviews
    
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(chatManager.getMessages(chatId: chatId)) { message in
                        MessageBubbleView(
                            message: message,
                            isCurrentUser: message.sender_id == appState.currentUserId
                        )
                        .id(message.id)
                    }
                }
                .padding(.vertical, 8)
            }
            .onChange(of: chatManager.getMessages(chatId: chatId).count) { _, _ in
                // Scroll to newest message
                if let lastMessage = chatManager.getMessages(chatId: chatId).last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                // Scroll to bottom on appear
                if let lastMessage = chatManager.getMessages(chatId: chatId).last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
    
    private var inputBar: some View {
        HStack(spacing: 12) {
            // Text field
            TextField("Message...", text: $newMessageText)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Theme.Colors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .focused($isInputFocused)
            
            // Send button
            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(
                        newMessageText.trimmingCharacters(in: .whitespaces).isEmpty
                        ? Theme.Colors.textTertiary
                        : Theme.Colors.primary
                    )
            }
            .disabled(newMessageText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.Colors.cardBackground)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Theme.Colors.secondaryBackground),
            alignment: .top
        )
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        let content = newMessageText.trimmingCharacters(in: .whitespaces)
        guard !content.isEmpty else { return }
        
        let messageToSend = content
        newMessageText = ""
        
        Task {
            await chatManager.sendMessage(
                chatId: chatId,
                content: messageToSend,
                userId: appState.currentUserId,
                userName: appState.currentUserName.isEmpty ? "Me" : appState.currentUserName,
                userAvatar: appState.currentUserAvatar
            )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChatView(
            chatId: "chat_1",
            venue: ChatVenueInfo(
                id: "venue_1",
                name: "Blue Bottle Coffee",
                category: "Coffee Shop",
                image: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400"
            )
        )
    }
}
