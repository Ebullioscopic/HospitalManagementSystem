import SwiftUI

struct SplashScreen: View {
    @State private var opacity = 1.0
    @State private var scale: CGFloat = 1.0
    @State private var isActive = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background gradient matching the login screen
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(hex: "101420") : Color(hex: "E8F5FF"),
                    colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Background patterns - matching login screen
            ForEach(0..<10) { i in
                Circle()
                    .fill(colorScheme == .dark ?
                          Color.blue.opacity(0.05) :
                          Color.blue.opacity(0.03))
                    .frame(width: CGFloat.random(in: 50...200))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: 3)
            }
            
            // Icon and text - matching login screen styling
            VStack(spacing: 5) {
                // Logo - same as in login screen
                ZStack {
                    Circle()
                        .fill(Color(hex: "4A90E2"))
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 0)
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                
                // Brand text - same as in login screen
                Text("Hospitality")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                    .padding(.top, 10)
                
                Text("Healthcare made simple")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
            }
            .opacity(opacity)
            .onAppear {
                // Animation
                withAnimation(.easeInOut(duration: 1.5)) {
                    scale = 1.2
                    opacity = 0.8
                }
                
                // Fade out after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        opacity = 0
                        scale = 0.8
                    }
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            // Transition to the first screen after splash
            Onboarding()
        }
    }
}



struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SplashScreen()
                .preferredColorScheme(.light)
            
            SplashScreen()
                .preferredColorScheme(.dark)
        }
    }
}
