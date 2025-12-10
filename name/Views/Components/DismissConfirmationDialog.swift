//
//  DismissConfirmationDialog.swift
//  name
//
//  Created by Antigravity AI on 10/12/25.
//
//  DESCRIPTION:
//  ViewModifier that presents a confirmation dialog before dismissing an action item.
//  Shows an alert with Cancel and "Yes, Dismiss" options.
//

import SwiftUI

struct DismissConfirmationDialog: ViewModifier {
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content.alert("Dismiss this plan?", isPresented: $isPresented) {
            Button("Cancel", role: .cancel) { }
            Button("Yes, Dismiss", role: .destructive) {
                onConfirm()
            }
        } message: {
            Text("This action item will be moved to your archive.")
        }
    }
}

// MARK: - View Extension

extension View {
    /// Adds a dismiss confirmation dialog to the view
    /// - Parameters:
    ///   - isPresented: Binding to control dialog visibility
    ///   - onConfirm: Action to perform when user confirms dismissal
    func dismissConfirmationDialog(
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(DismissConfirmationDialog(isPresented: isPresented, onConfirm: onConfirm))
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var showDialog = false
        @State private var dismissed = false
        
        var body: some View {
            VStack(spacing: 20) {
                Text(dismissed ? "Item dismissed!" : "Item active")
                    .font(.headline)
                
                Button("Dismiss") {
                    showDialog = true
                }
                .buttonStyle(.bordered)
            }
            .dismissConfirmationDialog(isPresented: $showDialog) {
                dismissed = true
            }
        }
    }
    
    return PreviewWrapper()
}
