//
//  ThemeManager.swift
//  name
//
//  Created by Krutin Rathod on 25/11/25.
//
//  DESCRIPTION:
//  Centralized theme management for dark mode support.
//  Manages app-wide theme state with persistence across app launches.
//  
//  KEY FEATURES:
//  - Published isDarkMode property for SwiftUI observation
//  - @AppStorage for automatic UserDefaults persistence
//  - Environment injection via .environmentObject()
//  - Simple toggle method for theme switching
//  
//  USAGE:
//  // In App:
//  @StateObject private var themeManager = ThemeManager()
//  WindowGroup {
//      ContentView()
//          .environmentObject(themeManager)
//          .preferredColorScheme(themeManager.colorScheme)
//  }
//  
//  // In Views:
//  @EnvironmentObject var themeManager: ThemeManager
//  Button("Toggle Theme") {
//      themeManager.toggleTheme()
//  }
//

import SwiftUI
import Combine

/// Observable object managing app-wide theme state
class ThemeManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current dark mode state (persisted via AppStorage)
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        didSet {
            objectWillChange.send()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Current color scheme for SwiftUI
    var colorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }
    
    // MARK: - Public Methods
    
    /// Toggles between light and dark mode
    func toggleTheme() {
        withAnimation(Theme.Animation.default) {
            isDarkMode.toggle()
        }
        
        // Haptic feedback for better UX
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    /// Sets the theme explicitly
    /// - Parameter isDark: Whether to enable dark mode
    func setTheme(isDark: Bool) {
        withAnimation(Theme.Animation.default) {
            isDarkMode = isDark
        }
    }
}
