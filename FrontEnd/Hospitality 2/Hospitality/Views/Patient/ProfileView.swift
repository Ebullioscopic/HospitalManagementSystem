import SwiftUI
import UIKit // For haptic feedback

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var iconPulse: CGFloat = 1.0
    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background with gradient matching app's aesthetic
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(hex: "101420") : Color(hex: "E8F5FF"),
                    colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Background circles for visual effect
            ForEach(0..<8) { _ in
                Circle()
                    .fill(colorScheme == .dark ? Color.blue.opacity(0.05) : Color.blue.opacity(0.03))
                    .frame(width: CGFloat.random(in: 50...200))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: 3)
            }
            
            // Modal content
            VStack(spacing: 10) {
                // Close button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        triggerHaptic()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.blue.opacity(0.1))
                            )
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 20)
                
                // Profile content
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile avatar
                        ZStack {
                            Circle()
                                .fill(colorScheme == .dark ? Color(hex: "1E88E5").opacity(0.2) : Color(hex: "4A90E2").opacity(0.15))
                                .frame(width: 120, height: 120)
                                .scaleEffect(iconPulse)
                            
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .foregroundColor(colorScheme == .dark ? Color(hex: "1E88E5") : Color(hex: "4A90E2"))
                                .shadow(color: colorScheme == .dark ? Color(hex: "1E88E5").opacity(0.4) : Color(hex: "4A90E2").opacity(0.3), radius: 8)
                        }
                        
                        Text("John Doe")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                        
                        Text("Patient ID: P-12345")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                        
                        // Menu items
                        VStack(spacing: 0) {
                            ProfileMenuItem(icon: "person.fill", title: "Personal Information")
                            ProfileMenuItem(icon: "heart.fill", title: "Medical History")
                            ProfileMenuItem(icon: "bell.fill", title: "Notifications")
                            ProfileMenuItem(icon: "gearshape.fill", title: "Settings")
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                                .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.15), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 20)
                        
                        // Logout button
                        Button(action: {
                            triggerHaptic()
                            // Logout action
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                colorScheme == .dark ? Color(hex: "1E88E5") : Color(hex: "4A90E2"),
                                                colorScheme == .dark ? Color(hex: "1976D2") : Color(hex: "5E5CE6")
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 58)
                                    .shadow(color: colorScheme == .dark ? Color(hex: "1E88E5").opacity(0.4) : Color(hex: "4A90E2").opacity(0.4), radius: 12, x: 0, y: 6)
                                
                                HStack {
                                    Image(systemName: "arrow.right.square.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("Logout")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                    .padding(.vertical, 20)
                }
            }
            .frame(maxWidth: 400) // Limit max width for better alignment on larger screens
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                cardScale = 1.0
                cardOpacity = 1.0
            }
            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                iconPulse = 1.05
            }
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            // Menu item action
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(colorScheme == .dark ? Color(hex: "1E88E5").opacity(0.2) : Color(hex: "4A90E2").opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? Color(hex: "1E88E5") : Color(hex: "4A90E2"))
                }
                
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
        }
        .background(
            colorScheme == .dark ? Color(hex: "1E2533") : .white
        )
        
        Divider()
            .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.2))
            .padding(.horizontal, 20)
    }
}



#Preview {
    ProfileView()
        .preferredColorScheme(.dark) // Preview in dark mode
}
