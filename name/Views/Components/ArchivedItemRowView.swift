//
//  ArchivedItemRowView.swift
//  name
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  Row component for displaying archived action items in the archive list.
//  Shows venue thumbnail, name, status badge, archived date, and delete option.
//

import SwiftUI

struct ArchivedItemRowView: View {
    
    // MARK: - Properties
    
    let item: ArchivedActionItem
    let onDelete: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: Theme.Layout.spacing) {
            // Venue Thumbnail
            venueImage
            
            // Venue Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.venue?.name ?? "Unknown Venue")
                    .font(Theme.Fonts.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    ArchiveStatusBadge(status: item.status)
                    
                    Text(item.formattedArchivedDate)
                        .font(Theme.Fonts.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            // Delete Button
            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Colors.error)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete permanently")
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    // MARK: - Subviews
    
    private var venueImage: some View {
        Group {
            if let venue = item.venue {
                AsyncImage(url: URL(string: venue.image)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderImage
                    case .empty:
                        ProgressView()
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Layout.smallCornerRadius))
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: Theme.Layout.smallCornerRadius)
            .fill(Theme.Colors.secondaryBackground)
            .overlay {
                Image(systemName: "building.2")
                    .foregroundColor(Theme.Colors.textSecondary)
            }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        ArchivedItemRowView(
            item: ArchivedActionItem(
                id: "1",
                venue_id: "v1",
                venue: nil,
                status: "completed",
                archived_at: ISO8601DateFormatter().string(from: Date()),
                created_at: ISO8601DateFormatter().string(from: Date())
            ),
            onDelete: {}
        )
        
        ArchivedItemRowView(
            item: ArchivedActionItem(
                id: "2",
                venue_id: "v2",
                venue: nil,
                status: "dismissed",
                archived_at: ISO8601DateFormatter().string(from: Date()),
                created_at: ISO8601DateFormatter().string(from: Date())
            ),
            onDelete: {}
        )
        
        ArchivedItemRowView(
            item: ArchivedActionItem(
                id: "3",
                venue_id: "v3",
                venue: nil,
                status: "expired",
                archived_at: ISO8601DateFormatter().string(from: Date()),
                created_at: ISO8601DateFormatter().string(from: Date())
            ),
            onDelete: {}
        )
    }
    .padding()
    .background(Theme.Colors.background)
}
