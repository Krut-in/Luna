//
//  nameApp.swift
//  name
//
//  Created by Krutin Rathod on 21/11/25.
//
//  DESCRIPTION:
//  Main application entry point for the Luna venue discovery iOS app.
//  This file defines the SwiftUI App structure and initializes the root view.
//  
//  ARCHITECTURE:
//  - Uses SwiftUI's @main attribute to mark the app entry point
//  - ContentView serves as the root view containing tab navigation
//  - AppState is initialized as a singleton for global state management
//  - ThemeManager provides dark mode support with persistence
//

import SwiftUI

@main
struct nameApp: App {
    
    // MARK: - Properties
    
    /// Theme manager for dark mode support
    @StateObject private var themeManager = ThemeManager()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
