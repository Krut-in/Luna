//
//  AvatarStackView.swift
//  name
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  A horizontal overlapping avatar stack for displaying user avatars.
//  Used in action item cards to show which friends are interested.
//
//  FEATURES:
//  - Overlapping circular avatars with negative spacing
//  - Configurable maximum visible count
//  - "+N" indicator for overflow
//  - Placeholder for failed image loads
//
//  USAGE:
//  AvatarStackView(avatarURLs: ["url1", "url2", ...], maxVisible: 5)
//

import SwiftUI

struct AvatarStackView: View {
    
    // MARK: - Properties
    
    let avatarURLs: [String]
    var maxVisible: Int = 5
    var avatarSize: CGFloat = 28
    var overlapOffset: CGFloat = -10
    
    /// Number of additional avatars beyond maxVisible
    private var additionalCount: Int {
        max(0, avatarURLs.count - maxVisible)
    }
    
    /// URLs to display (up to maxVisible)
    private var visibleURLs: [String] {
        Array(avatarURLs.prefix(maxVisible))
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: overlapOffset) {
            ForEach(Array(visibleURLs.enumerated()), id: \.offset) { index, url in
                avatarView(for: url, index: index)
            }
            
            // "+N" indicator for overflow
            if additionalCount > 0 {
                overflowIndicator
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Single avatar view
    private func avatarView(for url: String, index: Int) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure(_):
                placeholderView(index: index)
            case .empty:
                ProgressView()
            @unknown default:
                placeholderView(index: index)
            }
        }
        .frame(width: avatarSize, height: avatarSize)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Theme.Colors.cardBackground, lineWidth: 2)
        )
        .zIndex(Double(maxVisible - index)) // Later avatars appear on top
    }
    
    /// Placeholder for missing avatar
    private func placeholderView(index: Int) -> some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Theme.Colors.primary.opacity(0.3), Theme.Colors.secondary.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: avatarSize * 0.4))
                    .foregroundColor(Theme.Colors.primary)
            }
    }
    
    /// "+N" overflow indicator
    private var overflowIndicator: some View {
        Circle()
            .fill(Theme.Colors.primary.opacity(0.15))
            .frame(width: avatarSize, height: avatarSize)
            .overlay(
                Text("+\(additionalCount)")
                    .font(.system(size: avatarSize * 0.35, weight: .bold))
                    .foregroundColor(Theme.Colors.primary)
            )
            .overlay(
                Circle()
                    .stroke(Theme.Colors.cardBackground, lineWidth: 2)
            )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        // Few avatars
        VStack(alignment: .leading, spacing: 8) {
            Text("3 avatars")
                .font(.caption)
                .foregroundColor(.secondary)
            AvatarStackView(
                avatarURLs: [
                    "https://i.pravatar.cc/100?img=1",
                    "https://i.pravatar.cc/100?img=2",
                    "https://i.pravatar.cc/100?img=3"
                ]
            )
        }
        
        // Max visible
        VStack(alignment: .leading, spacing: 8) {
            Text("5 avatars (max)")
                .font(.caption)
                .foregroundColor(.secondary)
            AvatarStackView(
                avatarURLs: [
                    "https://i.pravatar.cc/100?img=1",
                    "https://i.pravatar.cc/100?img=2",
                    "https://i.pravatar.cc/100?img=3",
                    "https://i.pravatar.cc/100?img=4",
                    "https://i.pravatar.cc/100?img=5"
                ]
            )
        }
        
        // Overflow
        VStack(alignment: .leading, spacing: 8) {
            Text("8 avatars (overflow)")
                .font(.caption)
                .foregroundColor(.secondary)
            AvatarStackView(
                avatarURLs: [
                    "https://i.pravatar.cc/100?img=1",
                    "https://i.pravatar.cc/100?img=2",
                    "https://i.pravatar.cc/100?img=3",
                    "https://i.pravatar.cc/100?img=4",
                    "https://i.pravatar.cc/100?img=5",
                    "https://i.pravatar.cc/100?img=6",
                    "https://i.pravatar.cc/100?img=7",
                    "https://i.pravatar.cc/100?img=8"
                ]
            )
        }
    }
    .padding()
    .background(Theme.Colors.background)
}
