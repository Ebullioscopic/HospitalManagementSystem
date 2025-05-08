import SwiftUI
import UIKit
import Combine

struct OTPTextField: View {
    @Binding var text: String
    @State private var individualDigits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    var onComplete: (() -> Void)? // Callback for when all digits are entered
    
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
                                    focusedField = nil // Hide keyboard
                                    DispatchQueue.main.async {
                                        updateMainText() // Update the text binding first
                                        checkIfComplete() // Then check if complete and notify
                                    }
                                }
                            }
                            
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

                if !text.isEmpty {
                    for (index, char) in text.prefix(6).enumerated() {
                        individualDigits[index] = String(char)
                    }
                }
            }
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
    
    private func checkIfComplete() {
        // Check if all digits are filled
        let allFilled = individualDigits.allSatisfy { !$0.isEmpty }
        if allFilled && text.count == 6 {
            // Only call completion handler when all 6 digits are entered
            print("OTP complete: \(text)")
            onComplete?()
        }
    }
}

struct InfoFieldName: View {
    let title: String
    @Binding var text: String
    var isTyping: Bool
    @State private var isValidName: Bool = true
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $text)
                .padding(.leading)
                .frame(height: 55)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isFocused ? Color(hex: "4A90E2") : (isValidName ? Color.gray.opacity(0.3) : Color.red.opacity(0.5)), lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(colorScheme == .dark ? .black : .white).opacity(0.1))
                        )
                )
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isFocused)
                .autocapitalization(.words)
                .onChange(of: text) { newValue in
                    isValidName = newValue.isEmpty || newValue.isValidName()
                }
            
            Text(title)
                .padding(.horizontal, 5)
                .background(Color.bg)
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
            isFocused = newValue
        }
    }
}

// InfoField for Phone Number
struct InfoFieldPhone: View {
    let title: String
    @Binding var text: String
    var isTyping: Bool
    @State private var isValidPhone: Bool = true
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $text)
                .padding(.leading)
                .frame(height: 55)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isFocused ? Color(hex: "4A90E2") : (isValidPhone ? Color.gray.opacity(0.3) : Color.red.opacity(0.5)), lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(colorScheme == .dark ? .black : .white).opacity(0.1))
                        )
                )
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isFocused)
                .keyboardType(.phonePad)
                .onChange(of: text) { newValue in
                    isValidPhone = newValue.isEmpty || newValue.isValidPhoneNumber()
                }
            
            Text(title)
                .padding(.horizontal, 5)
                .background(Color.bg)
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
            isFocused = newValue
        }
    }
}

// Extensions for validation
extension String {
    func isValidName() -> Bool {
        let nameRegex = "^[A-Za-z\\s'-]{1,50}$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: self)
    }
    
    func isValidPhoneNumber() -> Bool {
        let phoneRegex = "^\\+?1?\\d{10,14}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
}

struct InfoFieldEmail: View {
    let title: String
    @Binding var text: String
    var isTyping: Bool
    @State private var isValidEmail: Bool = true
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $text)
                .padding(.leading)
                .frame(height: 55)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isFocused ? Color(hex: "4A90E2") : (isValidEmail ? Color.gray.opacity(0.3) : Color.red.opacity(0.5)), lineWidth: 1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(colorScheme == .dark ? .black : .white).opacity(0.1))
                        )
                )
                .textFieldStyle(PlainTextFieldStyle())
                .focused($isFocused)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "4A90E2").opacity(isFocused ? 0.3 : 0), lineWidth: 2)
                )
                .onChange(of: text) { newValue in
                    isValidEmail = newValue.isEmpty || newValue.isValidEmail()
                }
            
            Text(title)
                .padding(.horizontal, 5)
                .background(Color.bg)
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
            isFocused = newValue
        }
    }
}

// Extension to validate email format
extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
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
                .background(Color.bg)
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

struct StickyLogoHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var pulseScale = false
    @State private var rotationAngle = 0.0
    @State private var glowOpacity: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 0) {
          
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
                .frame(height: 75)
            
            // Logo Content in a horizontal layout
            HStack(spacing: 15) {
                // Left padding
                Spacer()
                    .frame(width: 50)
            
                
                // Medical logo with animations
                ZStack {
                    // Base gradient circle with glow
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "4A90E2"), Color(hex: "2B6CB0")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60) // Slightly smaller
                        .shadow(color: Color.blue.opacity(glowOpacity * 0.5), radius: 8, x: 0, y: 0)
                        .overlay(
                            Circle()
                                .stroke(Color.blue.opacity(glowOpacity), lineWidth: 3)
                                .blur(radius: 3)
                        )
                    
                    // Inner white circle for contrast
                    Circle()
                        .fill(Color.white)
                        .frame(width: 48, height: 48)
                    
                    // Medical cross with heartbeat
                    ZStack {
                        // Cross
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "4A90E2"))
                            .frame(width: 20, height: 36)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "4A90E2"))
                            .frame(width: 36, height: 20)
                        
                        // Heartbeat line
                        Path { path in
                            path.move(to: CGPoint(x: -15, y: 0))
                            path.addLine(to: CGPoint(x: -9, y: 0))
                            path.addLine(to: CGPoint(x: -6, y: 6))
                            path.addLine(to: CGPoint(x: 0, y: -9))
                            path.addLine(to: CGPoint(x: 6, y: 6))
                            path.addLine(to: CGPoint(x: 9, y: 0))
                            path.addLine(to: CGPoint(x: 15, y: 0))
                        }
                        .stroke(Color.red, lineWidth: 2.5)
                        .offset(y: -6)
                    }
                    .frame(width: 48, height: 48)
                    .scaleEffect(pulseScale ? 1.08 : 1.0)
                }
                .frame(width: 60, height: 60)
                
                // App name and tagline
                VStack(alignment: .leading, spacing: 2) {
                    Text("WeCare")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                        .accessibilityAddTraits(.isHeader)
                        .shadow(color: colorScheme == .dark ? .clear : Color(hex: "4A90E2").opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    Text("Health. Harmony. Hope.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                }
                
                // Right spacing
                Spacer()
            }
            .padding(.vertical, 12)
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
            .background(
                TransparentBlurView(style: colorScheme == .dark ? .dark : .light)
                    .opacity(0.6)
            )
        }
        .onAppear {
            // Start animations
            withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseScale.toggle()
            }
            
            withAnimation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 0.0
            }
        }
    }
}
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

struct RegistrationLinkCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var showRegistration: Bool
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            cardContent
        }
        .padding(.vertical, 15)
        .background(cardBackground)
        .overlay(cardBorder)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Don't have an account? Register")
        .accessibilityHint("Navigates to registration screen")
        .navigationDestination(isPresented: $showRegistration) {
            Register(isFocusedName: false, isFocusedEmail: false, isFocusedNumber: false)
        }
    }
    
    private var cardContent: some View {
        Group {
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
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(colorScheme == .dark ? Color(hex: "1E1E1E").opacity(0.6) : Color.white.opacity(0.8))
            .shadow(color: colorScheme == .dark ? Color.black.opacity(0.2) : Color(hex: "4A90E2").opacity(0.15), radius: 12, x: 0, y: 3)
    }
    
    private var cardBorder: some View {
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
    }
}

struct SignInButton: View {
    @Binding var isLoading: Bool
    @Binding var scale: CGFloat
    @Binding var otpText: String
    var action: () -> Void
    @State private var shimmerOffset: CGFloat = -0.25
    @ObservedObject var authViewModel: AuthViewModel
    
    private var isOTPComplete: Bool {
        return otpText.count == 6 && authViewModel.isOTPSent
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                buttonContent
                buttonOverlay
            }
            .frame(height: 58)
            .shadow(color: Color(hex: "4A90E2").opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .disabled(authViewModel.isLoading || !isOTPComplete)
        .opacity(isOTPComplete ? 1.0 : 0.7)
        .scaleEffect(scale)
        .buttonStyle(BouncyButtonStyle())
        .padding(.top, 16)
        .padding(.bottom, 20)
        .onChange(of: otpText) { newValue in
            print("OTP updated: \(newValue.count)/6 digits")
        }
    }
    
    private var buttonContent: some View {
        Group {
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
            } else {
                ZStack {
                    baseGradient
                    shimmerEffect
                    buttonTextAndIcon
                }
            }
        }
    }
    
    private var baseGradient: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        isOTPComplete ? Color(hex: "4A90E2") : Color(hex: "B2BEB5"),
                        isOTPComplete ? Color(hex: "5E5CE6") : Color(hex: "808080")
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
    
    private var shimmerEffect: some View {
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
    }
    
    private var buttonTextAndIcon: some View {
        HStack(spacing: 12) {
            Text("Sign In")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Image(systemName: "arrow.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
    }
    
    private var buttonOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
    }
}
                
struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
//            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
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

struct StaffRoleSelectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var navigationPath: NavigationPath
    let staffId: String
    
    var body: some View {
        ZStack {
            // Background styling
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "E8F5FF").opacity(0.8),
                    Color(hex: "F0F8FF").opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Select Your Role")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                    .padding(.top, 40)
                
                VStack(spacing: 20) {
                    // Doctor Role Button
                    Button(action: {
                        triggerHaptic()
                        navigationPath.append(Login.AppRoute.doctorDashboard(staffId: staffId))
                    }) {
                        HStack {
                            Image(systemName: "stethoscope")
                                .font(.system(size: 24))
                            Text("Doctor Dashboard")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
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
                        )
                        .foregroundColor(.white)
                        .shadow(color: Color(hex: "4A90E2").opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    
                    // Lab Technician Role Button
                    Button(action: {
                        triggerHaptic()
                        navigationPath.append(Login.AppRoute.labTechnicianView)
                    }) {
                        HStack {
                            Image(systemName: "testtube.2")
                                .font(.system(size: 24))
                            Text("Lab Technician View")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "38A169"),
                                            Color(hex: "48BB78")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .foregroundColor(.white)
                        .shadow(color: Color(hex: "38A169").opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
