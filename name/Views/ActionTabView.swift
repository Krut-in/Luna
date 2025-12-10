//
//  ActionTabView.swift
//  name
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  Main view for the Action Items tab, displaying pending action items
//  where 5+ friends are interested in the same venue.
//
//  FEATURES:
//  - List of action item cards with venue info
//  - Friend avatar stacks showing who's interested
//  - "Go Ahead" and "Dismiss" actions per item
//  - Empty state when no action items
//  - Pull-to-refresh support
//  - Navigation to venue details on card tap
//
//  DESIGN:
//  - Large navigation title "Action Items"
//  - Cards with venue image, name, distance, avatars
//  - Primary blue "Go Ahead" button
//  - Secondary gray "Dismiss" button
//  - No action_code display (LUNA-xxx hidden)
//

import SwiftUI

struct ActionTabView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = ProfileViewModel(appState: .shared)
    @ObservedObject private var appState = AppState.shared
    @State private var navigationPath = NavigationPath()
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if viewModel.isLoading && viewModel.actionItems.isEmpty {
                    loadingView
                } else if viewModel.actionItems.isEmpty {
                    emptyStateView
                } else {
                    actionItemsList
                }
            }
            .navigationTitle("Action Items")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: String.self) { venueId in
                VenueDetailView(venueId: venueId)
            }
            .refreshable {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                await viewModel.loadProfile()
            }
            .task {
                await viewModel.loadProfile()
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Loading skeleton view
    private var loadingView: some View {
        VStack {
            ForEach(0..<3, id: \.self) { _ in
                SkeletonLoadingView()
                    .frame(height: 160)
                    .padding(.horizontal)
            }
        }
        .padding(.top)
    }
    
    /// Empty state when no action items
    private var emptyStateView: some View {
        VStack(spacing: Theme.Layout.largeSpacing) {
            Spacer()
            
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.textTertiary)
            
            VStack(spacing: Theme.Layout.smallSpacing) {
                Text("No action items yet")
                    .font(Theme.Fonts.title3)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("When 5 friends are interested in the same venue, you'll see it here")
                    .font(Theme.Fonts.callout)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // CTA to go to Discover
            Button {
                appState.selectedTab = 0
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    Text("Discover Venues")
                }
                .font(Theme.Fonts.headline)
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(Theme.Colors.primary)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius))
            }
            .padding(.top, Theme.Layout.spacing)
            
            Spacer()
        }
    }
    
    /// Main action items list
    private var actionItemsList: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Layout.spacing) {
                ForEach(viewModel.actionItems) { item in
                    ActionItemCardView(
                        actionItem: item,
                        onGoAhead: {
                            Task {
                                await viewModel.completeActionItem(item.id)
                            }
                        },
                        onDismiss: {
                            Task {
                                await viewModel.dismissActionItem(item.id)
                            }
                        },
                        onTapCard: {
                            navigationPath.append(item.venue_id)
                        }
                    )
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Preview

#Preview {
    ActionTabView()
}
