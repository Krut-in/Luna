//
//  InterestSuccessToast.swift
//  name
//
//  Created for Luna Demo Enhancement
//
//  DESCRIPTION:
//  Toast notification component for celebrating successful venue interest toggle.
//  Shows a delightful bottom notification with party popper confetti animation and haptic feedback.
//  
//  DESIGN SPECIFICATIONS:
//  - Position: Bottom of screen, centered horizontally (50pt above safe area)
//  - Animation: Slide up entry with spring, fade out exit
//  - Confetti: Party popper effect with physics simulation (gravity, rotation, burst)
//  - Haptic: Medium impact on appearance
//  - Auto-dismiss: 2.5 seconds with smooth animation
//  
//  PHYSICS SIMULATION:
//  - Initial burst velocity (upward + horizontal spread)
//  - Gravity acceleration constant
//  - Per-particle rotation during fall
//  - Multiple shapes (circles, squares, triangles)
//  
//  USAGE:
//  InterestSuccessToast(isShowing: $viewModel.showInterestToast)
//      .zIndex(100) // Place above content
//

import SwiftUI

// MARK: - Enhanced Confetti Particle with Physics

struct PhysicsConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var velocityX: CGFloat
    var velocityY: CGFloat
    let color: Color
    let size: CGFloat
    var rotation: Double
    let rotationSpeed: Double
    let shape: ParticleShape
    
    enum ParticleShape {
        case circle, square, triangle
    }
}

// MARK: - Interest Success Toast

struct InterestSuccessToast: View {
    @Binding var isShowing: Bool
    
    @State private var confettiParticles: [PhysicsConfettiParticle] = []
    @State private var popperOffset: CGFloat = 0
    @State private var popperOpacity: Double = 0
    @State private var dismissTask: Task<Void, Never>?
    @State private var animationTimer: Timer?
    
    // Physics constants
    private let gravity: CGFloat = 400 // pts/s²
    private let frameRate: Double = 1.0 / 60.0 // 60 fps
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                if isShowing {
                    ZStack {
                        // Confetti particles with physics
                        ForEach(confettiParticles) { particle in
                            particleView(for: particle)
                                .offset(x: particle.x, y: particle.y)
                                .rotationEffect(.degrees(particle.rotation))
                                .opacity(particle.y < -100 ? 0 : 1) // Fade out when too far
                        }
                        
                        // Party popper emoji
                        Text("🎉")
                            .font(.system(size: 60))
                            .offset(y: popperOffset)
                            .opacity(popperOpacity)
                        
                        // Toast content
                        toastContent
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isShowing)
                }
            }
        }
        .onChange(of: isShowing) { _, newValue in
            if newValue {
                triggerEffects()
                startAutoDismissTimer()
            } else {
                stopPhysicsAnimation()
            }
        }
    }
    
    @ViewBuilder
    private func particleView(for particle: PhysicsConfettiParticle) -> some View {
        Group {
            switch particle.shape {
            case .circle:
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
            case .square:
                Rectangle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
            case .triangle:
                Triangle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
            }
        }
    }
    
    @ViewBuilder
    private var toastContent: some View {
        HStack(spacing: 12) {
            // Star icon (yellow/gold)
            Image(systemName: "star.fill")
                .font(.system(size: 24))
                .foregroundColor(.yellow)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text("You're in!")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Time to make plans!")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Dismiss button
            Button(action: {
                dismissToast()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.green.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 50) // Above safe area
    }
    
    private func triggerEffects() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Generate confetti particles with initial velocities
        generatePhysicsConfetti()
        
        // Animate party popper
        animatePartyPopper()
        
        // Start physics simulation
        startPhysicsAnimation()
    }
    
    private func generatePhysicsConfetti() {
        confettiParticles = []
        let toastYPosition: CGFloat = -120 // Approximate toast position (negative because from bottom)
        
        // Create 20 particles with varied properties
        for _ in 0..<20 {
            let particle = PhysicsConfettiParticle(
                x: CGFloat.random(in: -20...20), // Start near center
                y: toastYPosition - 30, // Start below toast
                velocityX: CGFloat.random(in: -100...100), // Horizontal spread
                velocityY: CGFloat.random(in: (-250)...(-150)), // Upward velocity (negative is up)
                color: [Color.green, Color.yellow, Color.blue, Color.orange, Color.red].randomElement()!,
                size: CGFloat.random(in: 6...12),
                rotation: Double.random(in: 0...360),
                rotationSpeed: Double.random(in: 180...360), // degrees per second
                shape: [PhysicsConfettiParticle.ParticleShape.circle, .square, .triangle].randomElement()!
            )
            confettiParticles.append(particle)
        }
    }
    
    private func animatePartyPopper() {
        // Party popper shoots up and fades
        withAnimation(.easeOut(duration: 0.3)) {
            popperOpacity = 1.0
            popperOffset = -100
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.3)) {
                popperOpacity = 0
                popperOffset = -150
            }
        }
        
        // Reset popper after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            popperOffset = 0
        }
    }
    
    private func startPhysicsAnimation() {
        // Use timer for smooth physics updates at 60fps
        animationTimer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { _ in
            updatePhysics()
        }
    }
    
    private func stopPhysicsAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updatePhysics() {
        for i in 0..<confettiParticles.count {
            // Update velocities (gravity affects vertical velocity)
            confettiParticles[i].velocityY += gravity * CGFloat(frameRate)
            
            // Update positions
            confettiParticles[i].x += confettiParticles[i].velocityX * CGFloat(frameRate)
            confettiParticles[i].y += confettiParticles[i].velocityY * CGFloat(frameRate)
            
            // Update rotation
            confettiParticles[i].rotation += confettiParticles[i].rotationSpeed * frameRate
        }
    }
    
    private func startAutoDismissTimer() {
        // Cancel any existing dismiss task
        dismissTask?.cancel()
        
        // Create new dismiss task with 2.5 second delay
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 seconds
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                dismissToast()
            }
        }
    }
    
    private func dismissToast() {
        // Cancel the auto-dismiss task
        dismissTask?.cancel()
        dismissTask = nil
        
        // Stop physics animation
        stopPhysicsAnimation()
        
        withAnimation(.easeOut(duration: 0.3)) {
            isShowing = false
        }
        
        // Clear confetti after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            confettiParticles = []
            popperOpacity = 0
            popperOffset = 0
        }
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var isShowing = true
    
    return ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        
        InterestSuccessToast(isShowing: $isShowing)
    }
}
