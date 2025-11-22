//
//  CategoryFilterView.swift
//  name
//
//  Created by Krutin Rathod on 22/11/25.
//
//  DESCRIPTION:
//  Horizontal scrollable category filter bar for venue filtering.
//  Displays filter chips with active state highlighting and count badges.
//  
//  KEY FEATURES:
//  - Horizontal ScrollView for filter chips
//  - Active filter highlighted with accent color
//  - Count badges showing venue count per category
//  - Smooth animations on filter selection
//  - "All" option to clear filter
//  
//  STATE MANAGEMENT:
//  - selectedCategory: Currently selected category (nil = "All")
//  - onCategorySelected: Callback when filter changes
//  
//  USAGE:
//  CategoryFilterView(
//      categories: ["All", "Coffee Shop", "Restaurant", "Bar"],
//      categoryCounts: ["Coffee Shop": 3, "Restaurant": 5, "Bar": 2],
//      selectedCategory: $selectedCategory
//  )
//

import SwiftUI

struct CategoryFilterView: View {
    
    // MARK: - Properties
    
    let categories: [String]
    let categoryCounts: [String: Int]
    @Binding var selectedCategory: String?
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // "All" filter chip
                FilterChip(
                    title: "All",
                    count: nil,
                    isSelected: selectedCategory == nil,
                    action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = nil
                        }
                    }
                )
                
                // Category filter chips
                ForEach(categories, id: \.self) { category in
                    FilterChip(
                        title: category,
                        count: categoryCounts[category],
                        isSelected: selectedCategory == category,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Filter Chip Component

struct FilterChip: View {
    
    let title: String
    let count: Int?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let count = count {
                    Text("(\(count))")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.15))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        CategoryFilterView(
            categories: ["Coffee Shop", "Restaurant", "Bar", "Cultural"],
            categoryCounts: ["Coffee Shop": 3, "Restaurant": 5, "Bar": 2, "Cultural": 1],
            selectedCategory: .constant(nil)
        )
        
        CategoryFilterView(
            categories: ["Coffee Shop", "Restaurant", "Bar", "Cultural"],
            categoryCounts: ["Coffee Shop": 3, "Restaurant": 5, "Bar": 2, "Cultural": 1],
            selectedCategory: .constant("Coffee Shop")
        )
    }
    .padding()
}
