//
//  login_bubble.swift
//  Hospitality
//
//  Created by admin17 on 03/05/25.
//

import Foundation
import SwiftUI

struct EnhancedBubbleView: View {
    let size: CGFloat
    let position: CGPoint
    let opacity: Double
    let animationDuration: Double
    @State private var animatePosition = false
    @State private var scale: CGFloat = 1.0
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Circle()
            .fill(colorScheme == .dark ?
                  LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(opacity * 1.5), Color.purple.opacity(opacity)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  ) :
                  LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(opacity), Color(hex: "4A90E2").opacity(opacity * 1.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  )
            )
            .frame(width: size * scale, height: size * scale)
            .position(
                x: position.x + (animatePosition ? CGFloat.random(in: 20...40) : CGFloat.random(in: -40...(-20))),
                y: position.y + (animatePosition ? CGFloat.random(in: -40...(-20)) : CGFloat.random(in: 20...40))
            )
            .blur(radius: 3)
            .onAppear {
                // Movement animation
                withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                    self.animatePosition.toggle()
                }
                
                // Pulsing animation
                withAnimation(Animation.easeInOut(duration: animationDuration * 0.7).repeatForever(autoreverses: true)) {
                    self.scale = CGFloat.random(in: 0.85...1.15)
                }
            }
    }
}

struct BubbleView: View {
    let size: CGFloat
    let position: CGPoint
    let opacity: Double
    @State private var animatePosition = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Circle()
            .fill(colorScheme == .dark ? Color.blue.opacity(opacity) : Color.blue.opacity(opacity))
            .frame(width: size, height: size)
            .position(
                x: position.x + (animatePosition ? 20 : -20),
                y: position.y + (animatePosition ? -20 : 20)
            )
            .blur(radius: 3)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                    self.animatePosition.toggle()
                }
            }
    }
}
