import SwiftUI
import UIKit // For haptic feedback

struct Onboarding: View {
    @State private var currentScreen = 0
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.8
    @State private var offset: CGFloat = 0.0
    @State private var navigateToLogin = false
    @State private var cardRotation: Double = 0
    @State private var iconPulse: CGFloat = 1.0
    @Environment(\.colorScheme) var colorScheme
    
    // Animation state variables
    @State private var cardOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1.0
    @State private var isAnimating = false
    @State private var cardScale: CGFloat = 1.0
    
    @State private var indicatorWidth: CGFloat = 8
    @State private var indicatorOffset: CGFloat = 0
    
    let screens = [
        OnboardingScreen(
            title: "Patient Management",
            icon: "Patient", // Image from Assets.xcassets
            description: "Streamlined healthcare access",
            features: [
                "Schedule Appointments",
                "Access Medical Records",
                "View Test Results"
            ]
        ),
        OnboardingScreen(
            title: "Doctor Management",
            icon: "Doctor",
            description: "Efficient patient care system",
            features: [
                "Manage Schedules",
                "Update Records",
                "Review Results"
            ]
        ),
        OnboardingScreen(
            title: "Hospital",
            icon: "Hospital", // Replace with your actual asset name
            description: "Complete facility oversight",
            features: [
                "Oversee Operations",
                "Manage Staff",
                "Track Resources"
            ]
        )
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            colorScheme == .dark ? Color(hex: "101420") : Color(hex: "E8F5FF"),
                            colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    ForEach(0..<12) { _ in
                        Circle()
                            .fill(colorScheme == .dark ? Color.blue.opacity(0.05) : Color.blue.opacity(0.03))
                            .frame(width: CGFloat.random(in: 50...200))
                            .position(
                                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                            )
                            .blur(radius: 3)
                    }
                }
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.circle.fill")
                                .foregroundColor(colorScheme == .dark ? .blue : Color(hex: "4A90E2"))
                                .font(.system(size: 24))
                            
                            Text("Hospitality")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        Button(action: {
                            triggerHaptic()
                            withAnimation(.easeInOut(duration: 0.6)) {
                                navigateToLogin = true
                                opacity = 0
                                scale = 0.8
                                offset = 50
                            }
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A90E2"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.blue.opacity(0.1))
                                )
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // Card Container
                    ZStack {
                        // Content Card
                        VStack(spacing: 25) {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ? Color.blue.opacity(0.1) : Color.blue.opacity(0.05))
                                    .frame(width: 180, height: 180)
                                    .scaleEffect(iconPulse)
                                
                                Circle()
                                    .fill(colorScheme == .dark ? Color.blue.opacity(0.15) : Color.blue.opacity(0.08))
                                    .frame(width: 160, height: 160)
                                    .scaleEffect(iconPulse * 0.95)
                                
                                Image(screens[currentScreen].icon) // ✅ Using asset image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .shadow(color: .blue.opacity(0.5), radius: 12)
                                    .rotationEffect(.degrees(cardRotation))
                            }
                            .scaleEffect(scale)
                            
                            VStack(spacing: 8) {
                                Text(screens[currentScreen].title)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Text(screens[currentScreen].description)
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(screens[currentScreen].features, id: \.self) { feature in
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(colorScheme == .dark ? Color.blue.opacity(0.2) : Color.blue.opacity(0.1))
                                                .frame(width: 32, height: 32)
                                            
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(colorScheme == .dark ? .blue : Color(hex: "4A90E2"))
                                        }
                                        
                                        Text(feature)
                                            .font(.system(size: 17, weight: .medium, design: .rounded))
                                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 30)
                                    .transition(.opacity)
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding(.vertical, 30)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(colorScheme == .dark ? Color(hex: "1A202C").opacity(0.7) : Color.white.opacity(0.8))
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                                .blur(radius: 0.5)
                        )
                        .padding(.horizontal, 20)
                        .rotation3DEffect(.degrees(cardRotation / 6), axis: (x: 0, y: 1, z: 0))
                        // Apply moving card animation
                        .offset(x: cardOffset)
                        .scaleEffect(cardScale)
                        .opacity(cardOpacity)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        ForEach(0..<screens.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentScreen ? Color(hex: "4A90E2") : Color.gray.opacity(0.3))
                                .frame(width: index == currentScreen ? indicatorWidth * 2 : indicatorWidth, height: indicatorWidth)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentScreen)
                        }
                    }
                    .padding(.top, 10)
                    
                    Button(action: {
                        triggerHaptic()
                        animateCardTransition()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "4A90E2"), Color(hex: "5E5CE6")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 58)
                                .shadow(color: Color(hex: "4A90E2").opacity(0.4), radius: 12, x: 0, y: 6)
                            
                            HStack {
                                Text(currentScreen == screens.count - 1 ? "Get Started" : "Next")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                    }
                    .disabled(isAnimating)
                }
                .opacity(opacity)
                .offset(x: 0, y: offset)
                .navigationDestination(isPresented: $navigateToLogin) {
                    Login()
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8)) { opacity = 1 }
                    withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) { scale = 1.1 }
                    withAnimation(Animation.easeOut(duration: 0.5).delay(0.4)) { scale = 1.0 }
                    withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        iconPulse = 1.05
                    }
                }
            }
        }
    }
    
    // Card transition animation - now going LEFT instead of right
    private func animateCardTransition() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // First phase - slide out to the LEFT and fade
        withAnimation(.easeInOut(duration: 0.3)) {
            cardOffset = -UIScreen.main.bounds.width
            cardOpacity = 0
            cardScale = 0.8
            cardRotation = -15  // Rotate counterclockwise for left movement
        }
        
        // After slide out completes, change content and prepare for slide in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if currentScreen < screens.count - 1 {
                currentScreen += 1
            } else {
                navigateToLogin = true
                isAnimating = false
                return
            }
            
            // Position card off-screen on the RIGHT
            cardOffset = UIScreen.main.bounds.width
            cardRotation = 15  // Rotate clockwise for right position
            
            // Second phase - slide in from RIGHT side
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)) {
                cardOffset = 0
                cardOpacity = 1
                cardScale = 1
                cardRotation = 0
            }
            
            // Animation complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = false
            }
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct OnboardingScreen {
    let title: String
    let icon: String
    let description: String
    let features: [String]
}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Onboarding().preferredColorScheme(.light)
            Onboarding().preferredColorScheme(.dark)
        }
    }
}


