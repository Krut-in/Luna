//
//  EmptyStateView.swift
//  name
//
//  Created by Krutin Rathod on 22/11/25.
//
//  DESCRIPTION:
//  Reusable empty state component for consistent UX across the app.
//  Displays icon, title, message, and optional action button.
//  
//  KEY FEATURES:
//  - Configurable icon, title, and message
//  - Optional action button with callback
//  - Consistent styling across all empty states
//  - Smooth animations for appearance
//  
//  USAGE:
//  EmptyStateView(
//      icon: "heart.slash",
//      title: "No Saved Places",
//      message: "Explore venues and tap the heart to save them",
//      actionTitle: "Explore Venues",
//      action: { /* Navigate to discover tab */ }
//  )
//

import SwiftUI

struct EmptyStateView: View {
    
    // MARK: - Properties
    
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.6))
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .transition(.opacity)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        EmptyStateView(
            icon: "heart.slash",
            title: "No Saved Places",
            message: "Explore venues and tap the heart to save them",
            actionTitle: "Explore Venues",
            action: { print("Explore tapped") }
        )
        
        EmptyStateView(
            icon: "map",
            title: "No Coffee Shops Found",
            message: "Try another filter to discover more venues"
        )
    }
}
