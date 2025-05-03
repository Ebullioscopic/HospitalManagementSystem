//
//  login_background.swift
//  Hospitality
//
//  Created by admin17 on 03/05/25.
//

import Foundation
import SwiftUI

struct BackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var animateBackground = false
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(hex: "101420") : Color(hex: "E8F5FF"),
                    colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Enhanced animated bubble circles
            ForEach(0..<12) { i in
                EnhancedBubbleView(
                    size: CGFloat.random(in: 60...220),
                    position: CGPoint(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    ),
                    opacity: Double.random(in: 0.02...0.08),
                    animationDuration: Double.random(in: 6...15)
                )
            }
            
            // Light ray effect
            if !colorScheme.isDark {
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "4A90E2").opacity(0.2),
                        Color.clear
                    ]),
                    center: .topTrailing,
                    startRadius: 50,
                    endRadius: UIScreen.main.bounds.width
                )
                .scaleEffect(animateBackground ? 1.1 : 1.0)
                .opacity(animateBackground ? 0.7 : 0.5)
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                        animateBackground.toggle()
                    }
                }
            }
        }
    }
}
