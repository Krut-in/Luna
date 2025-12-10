//
//  ChatManager.swift
//  name
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  Observable manager for chat state with message polling.
//  Handles fetching messages, sending messages with optimistic UI,
//  and 5-second polling for new messages.
//
//  FEATURES:
//  - 5-second polling interval for new messages
//  - Optimistic UI updates for sent messages
//  - Auto-stop polling when view disappears
//  - Thread-safe state updates via @MainActor
//

import Foundation
import Combine

@MainActor
class ChatManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Messages by chat ID
    @Published var messages: [String: [ChatMessage]] = [:]
    
    /// Active chats for the current user
    @Published var activeChats: [Chat] = []
    
    /// Participants by chat ID
    @Published var participants: [String: [ChatParticipant]] = [:]
    
    /// Currently polling chat IDs
    @Published var pollingChats: Set<String> = []
    
    /// Loading state for message fetching
    @Published var isLoading = false
    
    /// Error message if any operation fails
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let apiService: APIServiceProtocol
    private var pollingTasks: [String: Task<Void, Never>] = [:]
    private let pollingInterval: TimeInterval = 5.0
    private var lastMessageTimestamp: [String: String] = [:]
    
    // MARK: - Initialization
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    // MARK: - Public Methods
    
    /// Fetches all active chats for a user
    /// - Parameter userId: The user's ID
    func fetchActiveChats(userId: String) async {
        do {
            activeChats = try await apiService.fetchUserChats(userId: userId)
            errorMessage = nil
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to fetch chats: \(error.localizedDescription)"
        }
    }
    
    /// Loads initial messages for a chat
    /// - Parameter chatId: The chat ID to load messages for
    func loadMessages(chatId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await apiService.fetchChatMessages(chatId: chatId, since: nil)
            messages[chatId] = response.messages
            
            if let chatParticipants = response.participants {
                participants[chatId] = chatParticipants
            }
            
            // Track last message timestamp for incremental updates
            if let lastMessage = response.messages.last {
                lastMessageTimestamp[chatId] = lastMessage.timestamp
            }
            
            errorMessage = nil
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Failed to load messages: \(error.localizedDescription)"
        }
    }
    
    /// Sends a message to a chat with optimistic UI update
    /// - Parameters:
    ///   - chatId: The chat ID
    ///   - content: Message content
    ///   - userId: Sender's user ID
    ///   - userName: Sender's display name
    ///   - userAvatar: Sender's avatar URL
    func sendMessage(
        chatId: String,
        content: String,
        userId: String,
        userName: String,
        userAvatar: String
    ) async {
        guard !content.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // Create optimistic temp message
        let tempId = "temp_\(UUID().uuidString)"
        let tempMessage = ChatMessage(
            id: tempId,
            chat_id: chatId,
            content: content,
            sender_id: userId,
            sender_name: userName,
            sender_avatar: userAvatar,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
        
        // Optimistic UI update
        if messages[chatId] == nil {
            messages[chatId] = []
        }
        messages[chatId]?.append(tempMessage)
        
        do {
            let response = try await apiService.sendMessage(
                chatId: chatId,
                userId: userId,
                content: content
            )
            
            // Replace temp message with saved message
            if let savedMessage = response.message {
                if let index = messages[chatId]?.firstIndex(where: { $0.id == tempId }) {
                    messages[chatId]?[index] = savedMessage
                }
                lastMessageTimestamp[chatId] = savedMessage.timestamp
            }
            
            errorMessage = nil
        } catch {
            // Revert optimistic update on failure
            messages[chatId]?.removeAll { $0.id == tempId }
            
            if let apiError = error as? APIError {
                errorMessage = apiError.errorDescription
            } else {
                errorMessage = "Failed to send message: \(error.localizedDescription)"
            }
        }
    }
    
    /// Starts polling for new messages in a chat
    /// - Parameter chatId: The chat ID to poll
    func startPolling(chatId: String) {
        // Don't start if already polling
        guard !pollingChats.contains(chatId) else { return }
        
        pollingChats.insert(chatId)
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            
            while !Task.isCancelled && self.pollingChats.contains(chatId) {
                await self.fetchNewMessages(chatId: chatId)
                
                // Wait before next poll
                try? await Task.sleep(nanoseconds: UInt64(self.pollingInterval * 1_000_000_000))
            }
        }
        
        pollingTasks[chatId] = task
    }
    
    /// Stops polling for a specific chat
    /// - Parameter chatId: The chat ID to stop polling
    func stopPolling(chatId: String) {
        pollingTasks[chatId]?.cancel()
        pollingTasks.removeValue(forKey: chatId)
        pollingChats.remove(chatId)
    }
    
    /// Stops all active polling
    func stopAllPolling() {
        for (chatId, task) in pollingTasks {
            task.cancel()
            pollingChats.remove(chatId)
        }
        pollingTasks.removeAll()
    }
    
    /// Gets messages for a specific chat
    /// - Parameter chatId: The chat ID
    /// - Returns: Array of messages, empty if none
    func getMessages(chatId: String) -> [ChatMessage] {
        return messages[chatId] ?? []
    }
    
    /// Gets participants for a specific chat
    /// - Parameter chatId: The chat ID
    /// - Returns: Array of participants, empty if none
    func getParticipants(chatId: String) -> [ChatParticipant] {
        return participants[chatId] ?? []
    }
    
    // MARK: - Private Methods
    
    /// Fetches new messages since last timestamp
    private func fetchNewMessages(chatId: String) async {
        let since = lastMessageTimestamp[chatId]
        
        do {
            let response = try await apiService.fetchChatMessages(chatId: chatId, since: since)
            
            // Append only new messages (filter out duplicates)
            let existingIds = Set(messages[chatId]?.map { $0.id } ?? [])
            let newMessages = response.messages.filter { !existingIds.contains($0.id) }
            
            if !newMessages.isEmpty {
                messages[chatId]?.append(contentsOf: newMessages)
                
                // Update last timestamp
                if let lastMessage = newMessages.last {
                    lastMessageTimestamp[chatId] = lastMessage.timestamp
                }
            }
            
            // Update participants if provided
            if let chatParticipants = response.participants {
                participants[chatId] = chatParticipants
            }
            
        } catch {
            // Silently fail on polling errors - will retry next interval
            print("Polling error for chat \(chatId): \(error.localizedDescription)")
        }
    }
}
