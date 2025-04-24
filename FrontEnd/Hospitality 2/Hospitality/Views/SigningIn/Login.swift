import SwiftUI
import UIKit // For haptic feedback
import Combine // For keyboard notifications

struct Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var selectedRole: String = "Patient"
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.8
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var navigateToHomePatient: Bool = false
    @Environment(\.colorScheme) var colorScheme

    @State private var fieldsOffset: CGFloat = 50
    @State private var buttonOffset: CGFloat = 100
    @State private var logoRotation: Double = 0
    @State private var navigateToAdminDashboard: Bool = false
    
    // Keyboard handling
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardVisible: Bool = false
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, password
    }
    
    // Available roles
    let roles = ["Admin", "Staff", "Patient"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background (unchanged)
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
                
                // Main Content
                VStack(spacing: 0) {
                    // Content area (unchanged)
                    VStack(spacing: 20) {
                        // Logo and branding section (unchanged)
                        VStack(spacing: 5) {
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
                            
                            Text("Hospitality")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                            
                            Text("Healthcare made simple")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                                .padding(.bottom, keyboardVisible ? 15 : 30)
                        }
                        .animation(.easeInOut(duration: 0.3), value: keyboardVisible)
                        
                        // Form fields (unchanged)
                        VStack(spacing: 22) {
                            // Role selection buttons
                            VStack {
                                HStack(spacing: 0) {
                                    Spacer(minLength: 0)
                                    
                                    HStack(spacing: 10) {
                                        ForEach(roles, id: \.self) { role in
                                            RoleButton(
                                                role: role,
                                                isSelected: selectedRole == role,
                                                action: {
                                                    withAnimation(.spring()) {
                                                        selectedRole = role
                                                        triggerHaptic(style: .light)
                                                    }
                                                }
                                            )
                                        }
                                    }
                                    
                                    Spacer(minLength: 0)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            
                            // Full Name field
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
                            
                            // Current selected role indicator
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Selected Role")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(colorScheme == .dark ? .gray : Color(hex: "4A5568"))
                                    .padding(.leading, 4)
                                
                                HStack {
                                    Image(systemName: getRoleIcon(for: selectedRole))
                                        .foregroundColor(.gray)
                                        .padding(.leading, 12)
                                    
                                    Text(selectedRole)
                                        .foregroundColor(Color(hex: "4A5568"))
                                        .font(.system(size: 16))
                                        .padding(.vertical, 14)
                                    
                                    Spacer()
                                    
                                    Text("Selected")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "4A90E2"))
                                        .padding(.trailing, 12)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                )
                            }
                            
                            // Sign-up link
                            if selectedRole == "Patient" {
                                HStack {
                                    Spacer()
                                    Text("Don't have an account?")
                                        .foregroundColor(colorScheme == .dark ? .gray : Color(hex: "4A5568"))
                                    
                                    NavigationLink(destination: Register()) {
                                        Text("Register")
                                            .foregroundColor(Color(hex: "4A90E2"))
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.top, 5)
                                .padding(.bottom, 5)
                            }
                            
                            Spacer()
                                .frame(height: keyboardVisible ? max(keyboardHeight - 100, 20) : 20)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Fixed position login button
                    VStack {
                        Spacer()
                        
                        Button(action: {
                            // Dismiss keyboard
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
                                        
                                        // Check login conditions
                                        if email.isEmpty || password.isEmpty {
                                            showError = true
                                        } else {
                                            // Check for admin credentials
                                            if selectedRole == "Admin" && email.lowercased() == "admin@gmail.com" && password == "admin123" {
                                                navigateToAdminDashboard = true
                                            }
                                            // Check for patient login
                                            else if selectedRole == "Patient" {
                                                navigateToHomePatient = true
                                            } else {
                                                showError = true
                                            }
                                        }
                                    }
                                }
                            }
                        }) {
                            ZStack {
                                if isLoading {
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
                                                Text("Login")
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
                        .padding(.bottom, 20)
                        .disabled(isLoading)
                        .scaleEffect(scale)
                        .background(
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
                    .frame(height: 90)
                    .background(colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF"))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        opacity = 1
                    }
                    
                    withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                        scale = 1.0
                    }
                }
                .onReceive(keyboardPublisher) { output in
                    withAnimation(.easeOut(duration: 0.25)) {
                        self.keyboardHeight = output.0
                        self.keyboardVisible = output.1
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .alert("Error", isPresented: $showError) {
                    Button("OK", role: .cancel) {
                        showError = false
                    }
                    .foregroundColor(Color(hex: "4A90E2"))
                } message: {
                    Text(selectedRole == "Patient" ? "Please fill in all fields" : "Navigation only available for Patient role")
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "4A5568"))
                }
                // Navigation to HomePatient
                .navigationDestination(isPresented: $navigateToHomePatient) {
                    HomePatient()
                        .navigationBarBackButtonHidden(true)
                }
                
                .navigationDestination(isPresented: $navigateToAdminDashboard) {
                    AdminHomeView() // You'll need to create this view
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
    
    // Get appropriate icon for each role (unchanged)
    private func getRoleIcon(for role: String) -> String {
        switch role {
        case "Admin":
            return "shield.fill"
        case "Staff":
            return "person.2.fill"
        case "Doctor":
            return "stethoscope"
        case "Patient":
            return "person.fill"
        case "Pharmacy":
            return "pill.fill"
        default:
            return "person.fill"
        }
    }
    
    // Haptic Feedback (unchanged)
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // Keyboard publisher (unchanged)
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

// RoleButton, Color extension, and Preview remain unchanged
struct RoleButton: View {
    let role: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    private var roleIcon: String {
        switch role {
        case "Admin":
            return "shield.fill"
        case "Staff":
            return "person.2.fill"
        case "Doctor":
            return "stethoscope"
        case "Patient":
            return "person.fill"
        case "Pharmacy":
            return "pill.fill"
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
        case "Doctor":
            return Color(hex: "E53E3E")
        case "Patient":
            return Color(hex: "38A169")
        case "Pharmacy":
            return Color(hex: "DD6B20")
        default:
            return Color(hex: "4A90E2")
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? roleColor : Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: roleIcon)
                        .foregroundColor(isSelected ? .white : colorScheme == .dark ? .white.opacity(0.7) : Color(hex: "4A5568"))
                        .font(.system(size: 22))
                }
                
                Text(role)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? roleColor : colorScheme == .dark ? .white.opacity(0.7) : Color(hex: "4A5568"))
            }
            .padding(.vertical, 5)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
    }
}

struct InfoField: View {
    let title: String
    @Binding var text: String
    @FocusState var isTyping: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $text)
                .padding(.leading)
                .padding(.top, 10)  // Added top padding to lower the text input
                .frame(height: 55)
                .focused($isTyping)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
                .background(
                    isTyping ? .main : Color.primary,
                    in: RoundedRectangle(cornerRadius: 14)
                        .stroke(lineWidth: 1)
                )
                .textFieldStyle(PlainTextFieldStyle())
            
            Text(title)
                .font(.system(size: isTyping || !text.isEmpty ? 13 : 17))  // More precise font size control
                .padding(.horizontal, 5)
                .background(Color(UIColor.clear))  // Better background handling
                .foregroundStyle(isTyping ? .gray : Color.gray)
                .padding(.leading, 11)
                .offset(y: isTyping || !text.isEmpty ? -14 : 0)  // Adjusted offset values
                .animation(.easeInOut(duration: 0.2), value: isTyping || !text.isEmpty)
                .onTapGesture {
                    isTyping = true
                }
        }
        .padding(.top, 10)  // Added top padding to the entire container
        .animation(.easeInOut(duration: 0.2), value: isTyping)
    }
}

struct InfoFieldPassword: View {
    let title: String
    @Binding var text: String
    @FocusState var isTyping: Bool
    @State private var showPassword = false

    var body: some View {
        ZStack(alignment: .leading) {
            // Toggle between SecureField and TextField based on showPassword
            Group {
                if showPassword {
                    TextField("", text: $text)
                } else {
                    SecureField("", text: $text)
                }
            }
            .padding(.leading)
            .padding(.top, 10)  // Added top padding to lower the text input
            .frame(height: 55)
            .focused($isTyping)
            .background(
                isTyping ? Color.main : Color.primary,
                in: RoundedRectangle(cornerRadius: 14).stroke(lineWidth: 1)
            )
            .textFieldStyle(PlainTextFieldStyle())

            // Floating label
            Text(title)
                .font(.system(size: isTyping || !text.isEmpty ? 13 : 17))  // Better font scaling
                .padding(.horizontal, 5)
                .background(Color.clear.opacity(isTyping || !text.isEmpty ? 1 : 0))
                .foregroundStyle(isTyping ? .gray : Color.gray)
                .padding(.leading, 11)
                .offset(y: isTyping || !text.isEmpty ? -14 : 0)  // Adjusted offset
                .onTapGesture {
                    isTyping = true
                }

            // Show/Hide password button (unchanged)
            HStack {
                Spacer()
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
        .padding(.top, 10)  // Added container padding
        .animation(.easeInOut(duration: 0.2), value: isTyping)
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
