//
//  ArchiveStatusBadge.swift
//  name
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  Status badge component for archived action items.
//  Displays visual indicators for completed, dismissed, or expired states.
//

import SwiftUI

struct ArchiveStatusBadge: View {
    
    // MARK: - Properties
    
    let status: String  // "completed", "dismissed", "expired"
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.system(size: 10, weight: .semibold))
            
            Text(statusText)
                .font(Theme.Fonts.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .clipShape(Capsule())
    }
    
    // MARK: - Computed Properties
    
    private var iconName: String {
        switch status.lowercased() {
        case "completed":
            return "checkmark.circle.fill"
        case "dismissed":
            return "xmark.circle.fill"
        case "expired":
            return "clock.badge.exclamationmark.fill"
        default:
            return "archivebox.fill"
        }
    }
    
    private var statusText: String {
        switch status.lowercased() {
        case "completed":
            return "Completed"
        case "dismissed":
            return "Dismissed"
        case "expired":
            return "Expired"
        default:
            return status.capitalized
        }
    }
    
    private var backgroundColor: Color {
        switch status.lowercased() {
        case "completed":
            return Theme.Colors.success
        case "dismissed":
            return Theme.Colors.textTertiary
        case "expired":
            return .orange
        default:
            return Theme.Colors.textSecondary
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        ArchiveStatusBadge(status: "completed")
        ArchiveStatusBadge(status: "dismissed")
        ArchiveStatusBadge(status: "expired")
    }
    .padding()
    .background(Theme.Colors.background)
}
