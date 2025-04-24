import SwiftUI
import UIKit // For haptic feedback
import Combine // For keyboard notifications

struct Register: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.8
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = "Please fill in all fields"
    @Environment(\.colorScheme) var colorScheme
    
    // Keyboard handling
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardVisible: Bool = false
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, email, password, confirmPassword
    }
    
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
                    
                    // Background patterns
                    ForEach(0..<10) { i in
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
                
                // Main Content with SafeArea respecting layout
                VStack(spacing: 0) {
                    // Content area (non-scrollable)
                    VStack(spacing: 20) {
                        // Logo and branding section - made more compact
                        VStack(spacing: 5) {
                            // Logo
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "4A90E2"))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.white)
                            }
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 0)
                            .padding(.top, keyboardVisible ? 5 : 20)
                            .padding(.bottom, 10)
                            
                            // Brand text
                            Text("Hospitality")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                            
                            Text("Create your account")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                                .padding(.bottom, keyboardVisible ? 15 : 30)
                        }
                        .animation(.easeInOut(duration: 0.3), value: keyboardVisible)
                        
                        // Form fields
                        VStack(spacing: 22) {
                            // Full Name field
                            VStack(alignment: .leading, spacing: 8) {
                                
                                HStack {
                                    
                                    InfoField(title: "Name", text: $name)
                                }

                            }
                            
                            // Email field
                            VStack(alignment: .leading, spacing: 8) {
                                
                                HStack {
                                    
                                    InfoField(title: "Email", text: $email)
                                }
                            }
                            
                            // Password field
                            VStack(alignment: .leading, spacing: 8) {
                                
                                HStack {
                                    
                                    InfoFieldPassword(title: "Password", text: $password)
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                
                                HStack {
                                    InfoFieldPassword(title: "Confirm Password", text: $confirmPassword)
                                }
                            }
                            
                            // Login link with NavigationLink
                            HStack {
                                Spacer()
                                Text("Already have an account?")
                                    .foregroundColor(colorScheme == .dark ? .gray : Color(hex: "4A5568"))
                                
                                NavigationLink(destination: Login()) {
                                    Text("Login")
                                        .foregroundColor(Color(hex: "4A90E2"))
                                        .fontWeight(.semibold)
                                }
                                
                                Spacer()
                            }
                            .padding(.top, 5)
                            .padding(.bottom, 5)
                            
                            // Error Message with animation
                            if showError {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    
                                    Text(errorMessage)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.red)
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.red.opacity(0.1))
                                )
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            // Spacer to ensure content pushes up adequately
                            Spacer()
                                .frame(height: keyboardVisible ? max(keyboardHeight - 100, 20) : 20)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Fixed position register button - ALWAYS VISIBLE
                    VStack {
                        Spacer() // Pushes button to bottom
                        
                        Button(action: {
                            // Dismiss keyboard first
                            focusedField = nil
                            
                            // Trigger haptic feedback
                            triggerHaptic()
                            
                            withAnimation(.easeInOut(duration: 0.6)) {
                                isLoading = true
                                scale = 0.95
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.interpolatingSpring(stiffness: 100, damping: 15)) {
                                    scale = 1.05
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    withAnimation(.easeOut(duration: 0.4)) {
                                        scale = 1.0
                                        isLoading = false
                                        validateForm()
                                    }
                                }
                            }
                        }) {
                            ZStack {
                                if isLoading {
                                    // Loading state
                                    RoundedRectangle(cornerRadius: 20)
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
                                        .frame(height: 54)
                                } else {
                                    // Normal state
                                    RoundedRectangle(cornerRadius: 20)
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
                                            HStack {
                                                Text("Register")
                                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                                    .foregroundColor(.white)
                                                
                                                Image(systemName: "arrow.right")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(.white)
                                            }
                                        )
                                        .frame(height: 54)
                                }
                            }
                            .shadow(color: Color(hex: "4A90E2").opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .navigationBarBackButtonHidden(true)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20) // Space from bottom of screen
                        .disabled(isLoading)
                        .scaleEffect(scale)
                        .background(
                            // Add gradient fade background to ensure button visibility
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        colorScheme == .dark ? Color(hex: "1A202C").opacity(0) : Color(hex: "F0F8FF").opacity(0),
                                        colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
                                    ]
                                ),
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                    }
                    .frame(height: 90) // Fixed height for button area
                    .background(colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF"))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // Dismiss keyboard when tapping outside text fields
                    focusedField = nil
                }
                .onAppear {
                    // Initial animations
                    withAnimation(.easeInOut(duration: 0.8)) {
                        opacity = 1
                    }
                    
                    withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                        scale = 1.0
                    }
                }
                // Add keyboard observers
                .onReceive(keyboardPublisher) { output in
                    withAnimation(.easeOut(duration: 0.25)) {
                        self.keyboardHeight = output.0
                        self.keyboardVisible = output.1
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
    }
    
    // Form validation
    private func validateForm() {
        if name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Please fill in all fields"
            showError = true
        } else if !isValidEmail(email) {
            errorMessage = "Please enter a valid email address"
            showError = true
        } else if password != confirmPassword {
            errorMessage = "Passwords do not match"
            showError = true
        } else if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            showError = true
        } else {
            showError = false
            // Process registration
        }
    }
    
    // Email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Haptic Feedback with optional style
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Keyboard publisher for keyboard visibility handling
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


// Preview Provider
struct Register_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                Register()
            }
            .preferredColorScheme(.light)
            
            NavigationStack {
                Register()
            }
            .preferredColorScheme(.dark)
        }
    }
}
