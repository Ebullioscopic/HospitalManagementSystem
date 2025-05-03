import SwiftUI
import UIKit
import Combine

struct OTPTextField: View {
    @Binding var text: String
    @State private var individualDigits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Verification Code")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "4A5568"))
                .padding(.leading, 4)
            
            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    TextField("", text: $individualDigits[index])
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 42, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(focusedField == index ? Color(hex: "4A90E2") : Color.gray.opacity(0.3), lineWidth: 1.5)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.1))
                                )
                        )
                        .focused($focusedField, equals: index)
                        .onChange(of: individualDigits[index]) { newValue in
                            // Limit to one character
                            if newValue.count > 1 {
                                individualDigits[index] = String(newValue.suffix(1))
                            }
                            
                            // Move to next field if a character was entered
                            if !newValue.isEmpty {
                                if index < 5 {
                                    focusedField = index + 1
                                } else {
                                    focusedField = nil // Hide keyboard if last digit
                                }
                            }
                            
                            // Update the main text binding
                            updateMainText()
                        }
                        .onReceive(Just(individualDigits[index])) { newValue in
                            // Only allow numbers
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                individualDigits[index] = filtered
                            }
                        }
                        .accessibilityLabel("Verification code digit \(index + 1)")
                        .accessibilityHint("Enter a single digit")
                }
            }
            .frame(height: 50)
            .onAppear {
                // Set initial focus to the first field
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = 0
                }
                
                // Initialize individualDigits from text if needed
                if !text.isEmpty {
                    for (index, char) in text.prefix(6).enumerated() {
                        individualDigits[index] = String(char)
                    }
                }
            }
            // Handle backspace key to move to previous field when deleting
            .overlay(
                TextField("", text: .constant(""))
                    .frame(width: 0, height: 0)
                    .opacity(0)
                    .focused($focusedField, equals: -1)
                    .onSubmit {
                        focusedField = 0
                    }
            )
        }
    }
    
    private func updateMainText() {
        text = individualDigits.joined()
    }
}

// MARK: - InfoField Components
struct InfoField : View {
    let title: String
    @Binding var text: String
    @FocusState var isTyping: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $text)
                .padding(.leading)
                .frame(height: 55)
                .focused($isTyping)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isTyping ? Color(hex: "4A90E2") : Color.gray.opacity(0.3), lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(colorScheme == .dark ? .black : .white).opacity(0.1))
                        )
                )
                .textFieldStyle(PlainTextFieldStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "4A90E2").opacity(isTyping ? 0.3 : 0), lineWidth: 2)
                )
            
            Text(title)
                .padding(.horizontal, 5)
                .background(colorScheme == .dark ? Color(hex: "1E1E1E").opacity(isTyping || !text.isEmpty ? 1 : 0) : Color.white.opacity(isTyping || !text.isEmpty ? 1 : 0))
                .foregroundStyle(isTyping ? Color(hex: "4A90E2") : Color.gray)
                .font(.system(size: 14, weight: isTyping ? .medium : .regular))
                .padding(.leading)
                .offset(y: isTyping || !text.isEmpty ? -27 : 0)
                .onTapGesture {
                    isTyping = true
                }
        }
        .animation(.linear(duration: 0.2), value: isTyping)
    }
}

struct InfoFieldPassword: View {
    let title: String
    @Binding var text: String
    var isTyping: Bool  // This should be a Bool, not FocusState
    @State private var showPassword = false
    @FocusState private var isFocused: Bool  // Internal focus state
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .leading) {
            // Toggle between SecureField and TextField based on showPassword
            HStack {
                Group {
                    if showPassword {
                        TextField("", text: $text)
                    } else {
                        SecureField("", text: $text)
                    }
                }
                .padding(.leading)
                .focused($isFocused)  // Use internal focus state
                
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Color.gray.opacity(0.7))
                        .padding(.trailing, 12)
                }
            }
            .frame(height: 55)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isFocused ? Color(hex: "4A90E2") : Color.gray.opacity(0.3), lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(colorScheme == .dark ? .black : .white).opacity(0.1))
                    )
            )
            .textFieldStyle(PlainTextFieldStyle())
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "4A90E2").opacity(isFocused ? 0.3 : 0), lineWidth: 2)
            )

            // Floating label
            Text(title)
                .padding(.horizontal, 5)
                .background(colorScheme == .dark ? Color(hex: "1E1E1E").opacity(isFocused || !text.isEmpty ? 1 : 0) : Color.white.opacity(isFocused || !text.isEmpty ? 1 : 0))
                .foregroundStyle(isFocused ? Color(hex: "4A90E2") : Color.gray)
                .font(.system(size: 14, weight: isFocused ? .medium : .regular))
                .padding(.leading)
                .offset(y: isFocused || !text.isEmpty ? -27 : 0)
                .onTapGesture {
                    isFocused = true
                }
        }
        .animation(.linear(duration: 0.2), value: isFocused)
        .onChange(of: isTyping) { newValue in
            // Sync with parent's focus state
            isFocused = newValue
        }
        .onChange(of: isFocused) { newValue in
            // Notify parent if focus changes internally
            // Note: You'll need to add a callback for this
        }
    }
}



// MARK: - New Sticky Logo Header
struct StickyLogoHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var pulseScale = false
    @State private var rotationAngle = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
            // Gradient Top Bar
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            colorScheme == .dark ? Color(hex: "101420").opacity(0.95) : Color(hex: "E8F5FF").opacity(0.95),
                            colorScheme == .dark ? Color(hex: "101420").opacity(0.9) : Color(hex: "E8F5FF").opacity(0.9)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(height: 40)
                .overlay(
                    // Animated Sparkles
                    ZStack {
                        ForEach(0..<5) { i in
                            Image(systemName: "sparkle")
                                .font(.system(size: CGFloat.random(in: 8...12)))
                                .foregroundColor(Color(hex: "4A90E2").opacity(0.6))
                                .offset(x: CGFloat.random(in: -100...100), y: CGFloat.random(in: 5...15))
                                .rotationEffect(.degrees(pulseScale ? Double.random(in: -30...30) : 0))
                        }
                    }
                )
            
            // Logo Content
            HStack {
                Spacer()
                
                VStack(spacing: 2) {
                    ZStack {
                        // Glowing outer circles for beautiful effect
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "4A90E2").opacity(0.7),
                                        Color(hex: "4A90E2").opacity(0.0)
                                    ]),
                                    center: .center,
                                    startRadius: 25,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 100, height: 100)
                            .scaleEffect(pulseScale ? 1.1 : 0.9)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "5E5CE6"),
                                        Color(hex: "4A90E2")
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                            .shadow(color: Color(hex: "4A90E2").opacity(0.6), radius: pulseScale ? 8 : 5, x: 0, y: 0)
                        
                        // Rotating small circles around main logo
                        ZStack {
                            ForEach(0..<3) { i in
                                Circle()
                                    .fill(Color.white.opacity(0.7))
                                    .frame(width: 12, height: 12)
                                    .offset(x: 0, y: -40)
                                    .rotationEffect(.degrees(Double(i) * 120 + rotationAngle))
                            }
                        }
                        .rotationEffect(.degrees(rotationAngle))
                        
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: 0)
                            .accessibilityLabel("Hospitality Logo")
                            .scaleEffect(pulseScale ? 1.1 : 1.0)
                    }
                    .frame(width: 80, height: 80)
                    
                    Text("Hospitality")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                        .accessibilityAddTraits(.isHeader)
                        .shadow(color: colorScheme == .dark ? .clear : Color(hex: "4A90E2").opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    Text("Healthcare made simple")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                }
                
                Spacer()
            }
            .padding(.top, 50) // Extra padding for status bar
            .padding(.bottom, 10)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color(hex: "101420").opacity(0.95) : Color(hex: "E8F5FF").opacity(0.95),
                        colorScheme == .dark ? Color(hex: "1A202C").opacity(0.9) : Color(hex: "F0F8FF").opacity(0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            // Add frosted glass effect (blur) for a more premium look
            .background(
                TransparentBlurView(style: colorScheme == .dark ? .dark : .light)
                    .opacity(0.9)
            )
            .onAppear {
                // Start animations
                withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    pulseScale.toggle()
                }
                
                // Continuous rotation animation
                withAnimation(Animation.linear(duration: 12).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }
        }
    }
}

// Transparent blur view for a frosted glass effect
struct TransparentBlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

// MARK: - Component Views





    
    // MARK: - View Components
    


struct RegistrationLinkCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var showRegistration: Bool
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Spacer()
            Text("Don't have an account?")
                .foregroundColor(colorScheme == .dark ? .gray : Color(hex: "4A5568"))
            
            Button(action: {
                showRegistration = true
            }) {
                Text("Register")
                    .foregroundColor(Color(hex: "4A90E2"))
                    .fontWeight(.semibold)
                    .scaleEffect(isHovered ? 1.05 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .onHover { hovering in
                isHovered = hovering
            }
            .animation(.spring(response: 0.3), value: isHovered)
            
            Spacer()
        }
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(hex: "1E1E1E").opacity(0.6) : Color.white.opacity(0.8))
                .shadow(color: colorScheme == .dark ? Color.black.opacity(0.2) : Color(hex: "4A90E2").opacity(0.15), radius: 12, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "4A90E2").opacity(0.5),
                            Color(hex: "5E5CE6").opacity(0.2),
                            Color.clear,
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Don't have an account? Register")
        .accessibilityHint("Navigates to registration screen")
        .navigationDestination(isPresented: $showRegistration) {
            Register()
        }
    }
}

struct SignInButton: View {
    @Binding var isLoading: Bool
    @Binding var scale: CGFloat
    var isOTPRequested: Bool
    var action: () -> Void
    @State private var shimmerOffset: CGFloat = -0.25
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "4A90E2"),
                                    Color(hex: "5E5CE6")
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                        )
                        .frame(height: 58)
                } else {
                    // Button with shimmer effect
                    ZStack {
                        // Base gradient
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "B2BEB5"),
                                        Color(hex: "808080")
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        // Shimmer effect
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.0),
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.0)
                                    ]),
                                    startPoint: UnitPoint(x: shimmerOffset, y: shimmerOffset),
                                    endPoint: UnitPoint(x: shimmerOffset + 1, y: shimmerOffset + 1)
                                )
                            )
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: false)) {
                                    shimmerOffset = 1.25
                                }
                            }
                        
                        // Text and icon
                        HStack(spacing: 12) {
                            Text("Sign In")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 58)
                }
            }
            .shadow(color: Color(hex: "4A90E2").opacity(0.4), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .disabled(authViewModel.isLoading || !authViewModel.isOTPSent)
        .opacity(authViewModel.isOTPSent ? 1.0 : 0.7)
        .scaleEffect(scale)
        .buttonStyle(BouncyButtonStyle())
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
}

// Custom button style for a subtle bounce effect
struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// RoleButton with enhanced styling
struct RoleButton: View {
    let role: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    private var roleIcon: String {
        switch role {
        case "Admin":
            return "shield.fill"
        case "Staff":
            return "person.2.fill"
        case "Patient":
            return "person.fill"
        default:
            return "person.fill"
        }
    }
    
    private var roleColor: Color {
        switch role {
        case "Admin":
            return Color(hex: "6B46C1")
        case "Staff":
            return Color(hex: "3182CE")
        case "Patient":
            return Color(hex: "38A169")
        default:
            return Color(hex: "4A90E2")
        }
    }
    
    var body: some View {
        Button(action: {
            action()
            withAnimation(.spring(response: 0.3)) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    // Outer glow when selected
                    if isSelected {
                        Circle()
                            .fill(roleColor.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .scaleEffect(isPressed ? 1.1 : 1.0)
                    }
                    
                    Circle()
                        .fill(
                            // Fixed: Use LinearGradient for both cases to match types
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    isSelected ? roleColor : Color.gray.opacity(0.1),
                                    isSelected ? roleColor.opacity(0.8) : Color.gray.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? roleColor : Color.clear, lineWidth: 2)
                                .opacity(isSelected ? 0.4 : 0.0)
                        )
                        .shadow(
                            color: isSelected ? roleColor.opacity(0.5) : Color.clear,
                            radius: 8,
                            x: 0,
                            y: 2
                        )
                    
                    Image(systemName: roleIcon)
                        .foregroundColor(isSelected ? .white : colorScheme == .dark ? .white.opacity(0.7) : Color(hex: "4A5568"))
                        .font(.system(size: 22))
                        .opacity(isPressed ? 0.8 : 1.0)
                }
                
                Text(role)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? roleColor : colorScheme == .dark ? .white.opacity(0.7) : Color(hex: "4A5568"))
            }
            .padding(.vertical, 5)
            .scaleEffect(isSelected ? (isPressed ? 1.08 : 1.05) : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension ColorScheme {
    var isDark: Bool {
        return self == .dark
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                Login()
            }
            .preferredColorScheme(.light)
            
            NavigationStack {
                Login()
            }
            .preferredColorScheme(.dark)
        }
    }
}
