import SwiftUI
import UIKit // For haptic feedback



struct OnboardingPatient: View {
    @State private var currentScreen = 0
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.8
    @State private var offset: CGFloat = 0.0
    @State private var navigateToHome = false
    @State private var cardRotation: Double = 0
    @State private var iconPulse: CGFloat = 1.0
    @Environment(\.colorScheme) var colorScheme
    
    // Animation state variables
    @State private var cardOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1.0
    @State private var isAnimating = false
    @State private var cardScale: CGFloat = 1.0
    
    let screens = [
        OnboardingScreen1(
            title: "Book Appments",
            icon: "Calendar",
            description: "Schedule visits with ease",
            features: [
                "Choose your doctor",
                "Pick convenient times",
                "Get reminders"
            ]
        ),
        OnboardingScreen1(
            title: "Medical Records",
            icon: "Records",
            description: "Access your health history",
            features: [
                "View past visits",
                "Download reports",
                "Share with doctors"
            ]
        ),
        OnboardingScreen1(
            title: "Test Results",
            icon: "Results",
            description: "Stay informed about your health",
            features: [
                "View lab results",
                "Track trends",
                "Get notifications"
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
                    
                    ForEach(0..<8) { _ in
                        Circle()
                            .fill(colorScheme == .dark ? Color.blue.opacity(0.05) : Color.blue.opacity(0.03))
                            .frame(width: CGFloat.random(in: 50...150))
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
                            
                            Text("Patient Care")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        Button(action: {
                            triggerHaptic()
                            withAnimation(.easeInOut(duration: 0.6)) {
                                navigateToHome = true
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
                        VStack(spacing: 25) {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ? Color.blue.opacity(0.1) : Color.blue.opacity(0.05))
                                    .frame(width: 160, height: 160)
                                    .scaleEffect(iconPulse)
                                
                                Image(screens[currentScreen].icon)
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
                        .offset(x: cardOffset)
                        .scaleEffect(cardScale)
                        .opacity(cardOpacity)
                    }
                    
                    Spacer()
                    
                    // Progress Indicators
                    HStack(spacing: 8) {
                        ForEach(0..<screens.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentScreen ? Color(hex: "4A90E2") : Color.gray.opacity(0.3))
                                .frame(width: index == currentScreen ? 16 : 8, height: 8)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentScreen)
                        }
                    }
                    .padding(.top, 10)
                    
                    // Next/Get Started Button
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
                .navigationDestination(isPresented: $navigateToHome) {
                    HomePatient()
                        .navigationBarBackButtonHidden(true)

                    
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
    
    // Card transition animation (slides left, then in from rightTeX
    private func animateCardTransition() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Slide out to the left
        withAnimation(.easeInOut(duration: 0.3)) {
            cardOffset = -UIScreen.main.bounds.width
            cardOpacity = 0
            cardScale = 0.8
            cardRotation = -15
        }
        
        // Update content and slide in from right
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if currentScreen < screens.count - 1 {
                currentScreen += 1
                cardOffset = UIScreen.main.bounds.width
                cardRotation = 15
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    cardOffset = 0
                    cardOpacity = 1
                    cardScale = 1
                    cardRotation = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isAnimating = false
                }
            } else {
                withAnimation(.easeInOut(duration: 0.6)) {
                    navigateToHome = true
                    opacity = 0
                    scale = 0.8
                    offset = 50
                }
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

// Reused OnboardingScreen struct
struct OnboardingScreen1 {
    let title: String
    let icon: String
    let description: String
    let features: [String]
}


struct OnboardingPatient_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingPatient().preferredColorScheme(.light)
            OnboardingPatient().preferredColorScheme(.dark)
            HomePatient().preferredColorScheme(.light)
            HomePatient().preferredColorScheme(.dark)
        }
    }
}
