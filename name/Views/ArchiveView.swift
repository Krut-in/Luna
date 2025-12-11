//
//  ArchiveView.swift
//  name
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  Main view displaying archived action items (completed, dismissed, or expired).
//  Allows users to view past action items and permanently delete them.
//
//  FEATURES:
//  - List of archived items with status badges
//  - Permanent delete with confirmation dialog
//  - Pull-to-refresh support
//  - Loading, empty, and error states
//

import SwiftUI

struct ArchiveView: View {
    
    // MARK: - Properties
    
    @State private var archivedItems: [ArchivedActionItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var itemToDelete: String?
    @State private var showDeleteConfirmation = false
    
    @ObservedObject private var appState = AppState.shared
    
    private let apiService = APIService()
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if isLoading && archivedItems.isEmpty {
                loadingView
            } else if let error = errorMessage, archivedItems.isEmpty {
                errorView(error)
            } else if archivedItems.isEmpty {
                emptyStateView
            } else {
                archiveList
            }
        }
        .navigationTitle("Archive")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadArchivedItems()
        }
        .refreshable {
            await loadArchivedItems()
        }
        .alert("Delete Permanently?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                itemToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let id = itemToDelete {
                    Task { await deleteItem(id) }
                }
                itemToDelete = nil
            }
        } message: {
            Text("This action cannot be undone. The item will be permanently removed.")
        }
        .onAppear {
            // Hide tab bar when archive view appears
            appState.isTabBarHidden = true
        }
        .onDisappear {
            // Show tab bar when archive view disappears
            appState.isTabBarHidden = false
        }
    }
    
    // MARK: - Subviews
    
    /// Loading skeleton view
    private var loadingView: some View {
        VStack {
            ForEach(0..<5, id: \.self) { _ in
                HStack(spacing: Theme.Layout.spacing) {
                    RoundedRectangle(cornerRadius: Theme.Layout.smallCornerRadius)
                        .fill(Theme.Colors.secondaryBackground)
                        .frame(width: 56, height: 56)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.Colors.secondaryBackground)
                            .frame(width: 150, height: 16)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.Colors.secondaryBackground)
                            .frame(width: 100, height: 12)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
        .shimmer()
    }
    
    /// Empty state view
    private var emptyStateView: some View {
        VStack(spacing: Theme.Layout.largeSpacing) {
            Spacer()
            
            Image(systemName: "archivebox")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.textTertiary)
            
            VStack(spacing: Theme.Layout.smallSpacing) {
                Text("No archived items")
                    .font(Theme.Fonts.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Completed, dismissed, and expired action items will appear here")
                    .font(Theme.Fonts.callout)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
    
    /// Error view with retry button
    private func errorView(_ error: String) -> some View {
        VStack(spacing: Theme.Layout.largeSpacing) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.error)
            
            VStack(spacing: Theme.Layout.smallSpacing) {
                Text("Something went wrong")
                    .font(Theme.Fonts.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(error)
                    .font(Theme.Fonts.callout)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button {
                Task { await loadArchivedItems() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(Theme.Fonts.headline)
                .foregroundColor(.white)
                .frame(width: 160, height: 44)
                .background(Theme.Colors.primary)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius))
            }
            
            Spacer()
        }
    }
    
    /// Main archive list
    private var archiveList: some View {
        List {
            ForEach(archivedItems) { item in
                ArchivedItemRowView(
                    item: item,
                    onDelete: {
                        itemToDelete = item.id
                        showDeleteConfirmation = true
                    }
                )
                .listRowBackground(Theme.Colors.background)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .background(Theme.Colors.background)
    }
    
    // MARK: - Private Methods
    
    /// Loads archived action items from API
    private func loadArchivedItems() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let items = try await apiService.fetchArchivedActionItems(userId: appState.currentUserId)
            archivedItems = items
        } catch {
            if let apiError = error as? APIError {
                errorMessage = apiError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    /// Permanently deletes an archived item
    private func deleteItem(_ itemId: String) async {
        // Optimistic removal
        let removedIndex = archivedItems.firstIndex(where: { $0.id == itemId })
        var removedItem: ArchivedActionItem?
        
        if let index = removedIndex {
            removedItem = archivedItems.remove(at: index)
        }
        
        do {
            _ = try await apiService.deleteActionItemPermanently(itemId: itemId)
            print("✅ Item permanently deleted: \(itemId)")
        } catch {
            // Rollback on error
            if let item = removedItem, let index = removedIndex {
                archivedItems.insert(item, at: index)
            }
            errorMessage = "Failed to delete item: \(error.localizedDescription)"
        }
    }
}

// MARK: - Shimmer Effect Extension

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            Theme.Colors.textTertiary.opacity(0.3),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + phase * geometry.size.width * 2)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ArchiveView()
    }
}
