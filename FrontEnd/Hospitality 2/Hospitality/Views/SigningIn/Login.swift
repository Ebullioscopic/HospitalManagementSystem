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
    @FocusState var isTyping: Bool
    @State private var showPassword = false
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
                .focused($isTyping)
                
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

            // Floating label
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

struct Login: View {
    @State private var email: String = ""
    @State private var otpCode: String = ""
    @State private var selectedRole: String = "Patient"
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.8
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var navigateToHomePatient: Bool = false
    @State private var navigateToAdminDashboard: Bool = false
    @State private var isOTPRequested: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    @FocusState private var focusedField: Field?
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardVisible: Bool = false
    @State private var scrollOffset: CGFloat = 0
    
    enum Field: Hashable {
        case email, otp
    }
    
    let roles = ["Admin", "Staff", "Patient"]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // Animated background
                    BackgroundView()
                    
                    // Sticky Header with Logo
                    StickyLogoHeaderView()
                        .zIndex(1) // Keep it above other content
                    
                    // Main content
                    ScrollView {
                        VStack(spacing: 90) {
                            // Spacer to push content below the sticky header
                            Spacer()
                                .frame(height: 140)
                            
                            // Content Cards
                            VStack(spacing: 16) {
                                // Main card with form
                                FormCard(
                                    email: $email,
                                    otpCode: $otpCode,
                                    selectedRole: $selectedRole,
                                    isOTPRequested: $isOTPRequested,
                                    focusedField: focusedField,
                                    isFocusedEmail: focusedField == .email,
                                    requestOTP: requestOTP,
                                    isLoading: isLoading
                                )
                                
                                // Sign-up link card for patients
                                if selectedRole == "Patient" {
                                    RegistrationLinkCard()
                                }
                                
                                // Login button
                                SignInButton(
                                    isLoading: $isLoading,
                                    scale: $scale,
                                    isOTPRequested: isOTPRequested,
                                    action: loginAction
                                )
                                

                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                }
                .frame(width: geometry.size.width)
                .edgesIgnoringSafeArea(.all)
            }
            .onReceive(keyboardPublisher) { output in
                withAnimation(.easeOut(duration: 0.25)) {
                    self.keyboardHeight = output.0
                    self.keyboardVisible = output.1
                }
            }
            .onTapGesture {
                focusedField = nil // Dismiss keyboard on tap
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    opacity = 1
                }
                withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                    scale = 1.0
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {
                    showError = false
                }
                .foregroundColor(Color(hex: "4A90E2"))
            } message: {
                Text(errorMessage)
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "4A5568"))
            }
            .navigationDestination(isPresented: $navigateToHomePatient) {
                HomePatient()
                    .navigationBarBackButtonHidden(true)
            }
            .navigationDestination(isPresented: $navigateToAdminDashboard) {
                adminTabBarView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    // MARK: - Functions
    private func requestOTP() {
        guard !email.isEmpty else {
            showError(message: "Please enter your email address")
            return
        }
        
        withAnimation(.easeInOut) {
            isOTPRequested = true
            focusedField = .otp
        }
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
        }
    }
    
    private func loginAction() {
        guard !email.isEmpty else {
            showError(message: "Please enter your email")
            return
        }
        
        guard isOTPRequested else {
            showError(message: "Please request a verification code first")
            return
        }
        
        guard otpCode.count == 6 else {
            showError(message: "Please enter the 6-digit verification code")
            return
        }
        
        // Dismiss keyboard
        focusedField = nil
        
        withAnimation(.easeInOut(duration: 0.6)) {
            isLoading = true
            scale = 0.95
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                isLoading = false
                scale = 1.0
                
                if selectedRole == "Admin" && email.lowercased() == "admin@gmail.com" {
                    navigateToAdminDashboard = true
                } else {
                    navigateToHomePatient = true
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
        triggerHaptic(style: .heavy)
    }
    
    // Haptic Feedback
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Keyboard publisher
    var keyboardPublisher: AnyPublisher<(CGFloat, Bool), Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { notification -> (CGFloat, Bool) in
                    let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
                    return (keyboardHeight, true)
                },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ -> (CGFloat, Bool) in
                    return (0, false)
                }
        )
        .eraseToAnyPublisher()
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

struct LogoHeaderView: View {
    var keyboardVisible: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var pulseScale = false
    
    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                // Animated background circles
                Circle()
                    .fill(Color(hex: "4A90E2").opacity(0.2))
                    .frame(width: pulseScale ? 90 : 80, height: pulseScale ? 90 : 80)
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseScale)
                
                Circle()
                    .fill(Color(hex: "4A90E2"))
                    .frame(width: 70, height: 70)
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .foregroundColor(.white)
                    .accessibilityLabel("Hospitality Logo")
                    .scaleEffect(pulseScale ? 1.1 : 1.0)
                    .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulseScale)
            }
            .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 0)
            .padding(.bottom, 8)
            .onAppear {
                pulseScale = true
            }
            
            Text("Hospitality")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                .accessibilityAddTraits(.isHeader)
            
            Text("Healthcare made simple")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                .padding(.bottom, keyboardVisible ? 5 : 10)
        }
    }
}

struct FormCard: View {
    @Binding var email: String
    @Binding var otpCode: String
    @Binding var selectedRole: String
    @Binding var isOTPRequested: Bool
    var focusedField: Login.Field?
    var isFocusedEmail: Bool
    let requestOTP: () -> Void
    let isLoading: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var cardHover = false
    
    var body: some View {
        VStack(spacing: 24) {
            roleSelectionSection
            emailFieldSection
            otpButtonSection
            if isOTPRequested {
                OTPTextField(text: $otpCode)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .padding(.top, 5)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(hex: "1E1E1E") : Color.white)
                .shadow(
                    color: colorScheme == .dark ?
                        Color.black.opacity(0.5) :
                        Color(hex: "4A90E2").opacity(cardHover ? 0.2 : 0.1),
                    radius: cardHover ? 20 : 15,
                    x: 0,
                    y: cardHover ? 7 : 5
                )
                .animation(.easeInOut(duration: 0.3), value: cardHover)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "4A90E2").opacity(0.7),
                            Color(hex: "5E5CE6").opacity(0.3),
                            Color.clear,
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .onAppear { cardHover = true }
    }
    
    // MARK: - View Components
    
    private var roleSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select User Type")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "4A5568"))
                .padding(.leading, 4)
                .accessibilityLabel("User type selection")
            
            HStack(spacing: 10) {
                ForEach(["Admin", "Staff", "Patient"], id: \.self) { role in
                    RoleButton(
                        role: role,
                        isSelected: selectedRole == role,
                        action: {
                            withAnimation(.spring()) {
                                selectedRole = role
                                triggerHaptic()
                            }
                        }
                    )
                    .accessibilityLabel("\(role) role")
                    .accessibilityAddTraits(selectedRole == role ? [.isSelected] : [])
                    .accessibilityHint("Double tap to select \(role) role")
                }
            }
        }
    }
    
    private var emailFieldSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email Address")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "4A5568"))
                .padding(.leading, 4)
            
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(Color(hex: "4A90E2"))
                    .font(.system(size: 16))
                    .padding(.leading, 12)
                
                TextField("Enter your email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(.system(size: 16))
                    .padding(.vertical, 15)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocusedEmail ? Color(hex: "4A90E2") : Color.gray.opacity(0.3), lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(colorScheme == .dark ? .black : .white).opacity(0.1))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "4A90E2").opacity(isFocusedEmail ? 0.3 : 0), lineWidth: 3)
            )
            .accessibilityLabel("Email address input field")
        }
    }
    
    private var otpButtonSection: some View {
        Button(action: requestOTP) {
            HStack {
                Text("Get Verification Code")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "4A90E2"), Color(hex: "5E5CE6")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: Color(hex: "4A90E2").opacity(0.3), radius: 5, x: 0, y: 2)
            .disabled(isLoading)
        }
        .buttonStyle(BouncyButtonStyle())
        .accessibilityLabel("Request verification code button")
        .accessibilityHint("Sends a verification code to your email")
    }
    
    // Haptic Feedback helper
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct RegistrationLinkCard: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Spacer()
            Text("Don't have an account?")
                .foregroundColor(colorScheme == .dark ? .gray : Color(hex: "4A5568"))
            
            NavigationLink(destination: Register()) {
                Text("Register")
                    .foregroundColor(Color(hex: "4A90E2"))
                    .fontWeight(.semibold)
                    .scaleEffect(isHovered ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3), value: isHovered)
                    .onTapGesture {
                        isHovered = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isHovered = false
                        }
                    }
            }
            Spacer()
        }
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(hex: "1E1E1E").opacity(0.6) : Color.white.opacity(0.8))
                .shadow(color: colorScheme == .dark ? Color.black.opacity(0.2) : Color(hex: "4A90E2").opacity(0.15), radius: 12, x: 0, y: 3)
        )
        // Adding beautiful card highlight
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
    }
}

struct SignInButton: View {
    @Binding var isLoading: Bool
    @Binding var scale: CGFloat
    var isOTPRequested: Bool
    var action: () -> Void
    @State private var shimmerOffset: CGFloat = -0.25
    
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
                                        Color(hex: "4A90E2"),
                                        Color(hex: "5E5CE6")
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
        .disabled(isLoading || !isOTPRequested)
        .opacity(isOTPRequested ? 1.0 : 0.7)
        .scaleEffect(scale)
        .buttonStyle(BouncyButtonStyle())
        .padding(.top, 16)
        .padding(.bottom, 20)
        .accessibilityLabel("Sign in button")
        .accessibilityHint("Verifies your code and signs you in")
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
