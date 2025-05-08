import SwiftUI
import UIKit
import Combine

struct Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var otpCode: String = ""
    @State private var selectedRole: String = "patient"
    @State private var staffSubRole: String = UserDefaults.staffSubRole
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.8
    @State private var isLoading: Bool = false
    @State private var isOTPRequested: Bool = false
    @FocusState private var focusedField: Field?
    @Environment(\.colorScheme) var colorScheme

    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardVisible: Bool = false
    @State private var showRegistration: Bool = false
    @StateObject private var authViewModel = AuthViewModel()
    @State private var navigationPath = NavigationPath()

    enum AppRoute: Hashable {
        case adminHome
        case adminOnboarding
        case doctorOnboarding(staffId: String)
        case patientOnboarding
        case labTechOnboarding
        case doctorDashboard(staffId: String)
        case patientHome
        case labTechnicianView
    }

    enum Field: Hashable {
        case email, password, otp
    }

    let roles = ["admin", "staff", "patient"]

    var body: some View {
        NavigationStack(path: $navigationPath) {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    BackgroundView()
                    StickyLogoHeaderView()
                        .zIndex(1)

                    ScrollView {
                        VStack(spacing: 20) {
                            Spacer()
                                .frame(height: 140)

                            VStack(spacing: 16) {
                                FormCard(
                                    email: $email,
                                    password: $password,
                                    otpCode: $otpCode,
                                    selectedRole: $selectedRole,
                                    staffSubRole: $staffSubRole,
                                    isOTPRequested: $isOTPRequested,
                                    focusedField: focusedField,
                                    isFocusedEmail: focusedField == .email,
                                    isFocusedPassword: focusedField == .password,
                                    requestOTP: requestOTP,
                                    verifyOTP: verifyOTP,
                                    isLoading: isLoading,
                                    authViewModel: authViewModel
                                )

                                if selectedRole == "patient" {
                                    RegistrationLinkCard(showRegistration: $showRegistration)
                                }

                                SignInButton(
                                    isLoading: $isLoading,
                                    scale: $scale,
                                    otpText: $otpCode,
                                    action: loginAction,
                                    authViewModel: authViewModel
                                )
                            }
                            .padding(.horizontal, 30)
                            .padding(.top, 16)
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                }
                .frame(width: geometry.size.width)
                .edgesIgnoringSafeArea(.all)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .adminHome:
                        AdminHomeView()
                            .navigationBarBackButtonHidden(true)
                    case .adminOnboarding:
                        AdminOnboarding()
                            .navigationBarBackButtonHidden(true)
                    case .doctorOnboarding(let staffId):
                        DoctorOnboarding(doctorId: staffId)
                            .navigationBarBackButtonHidden(true)
                    case .patientOnboarding:
                        PatientOnboarding()
                            .navigationBarBackButtonHidden(true)
                    case .labTechOnboarding:
                        LabTechOnboarding()
                            .navigationBarBackButtonHidden(true)
                    case .doctorDashboard(let staffId):
                        DoctorDashboardView(doctorId: staffId)
                            .navigationBarBackButtonHidden(true)
                    case .patientHome:
                        HomePatient()
                            .navigationBarBackButtonHidden(true)
                    case .labTechnicianView:
                        LabTechnicianView()
                            .navigationBarBackButtonHidden(true)
                    }
                }
            }
            .onReceive(keyboardPublisher) { output in
                withAnimation(.easeOut(duration: 0.25)) {
                    self.keyboardHeight = output.0
                    self.keyboardVisible = output.1
                }
            }
            .onChange(of: authViewModel.isOTPSent) { newValue in
                if newValue {
                    isOTPRequested = true
                    focusedField = .otp
                }
            }
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
            .alert("Error", isPresented: $authViewModel.showError) {
                Button("OK", role: .cancel) {
                    authViewModel.showError = false
                }
            } message: {
                Text(authViewModel.errorMessage)
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "4A5568"))
            }
        }
    }

    private func requestOTP() {
        guard !email.isEmpty else {
            authViewModel.errorMessage = "Please enter your email address"
            authViewModel.showError = true
            return
        }

        guard !password.isEmpty else {
            authViewModel.errorMessage = "Please enter your password"
            authViewModel.showError = true
            return
        }

        authViewModel.sendOTP(email: email, password: password, userType: selectedRole)
    }

    private func verifyOTP() {
        guard !otpCode.isEmpty, otpCode.count == 6 else {
            authViewModel.errorMessage = "Please enter the 6-digit verification code"
            authViewModel.showError = true
            print("Login: OTP validation failed - invalid OTP")
            return
        }

        print("Login: Verifying OTP: \(otpCode), Email: \(email), UserType: \(selectedRole)")
        authViewModel.verifyOTP(email: email, otp: otpCode, userType: selectedRole) { response in
            DispatchQueue.main.async {
                if let response = response {
                    print("Login: OTP verification response: \(response)")
                    self.handleLoginResponse(response: response)
                } else {
                    print("Login: No response received from verifyOTP")
                    authViewModel.errorMessage = "Failed to verify OTP. Please try again."
                    authViewModel.showError = true
                }
            }
        }
    }

    private func handleLoginResponse(response: AdminLoginResponse.LoginResponse) {
        print("Login: Handling Login Response: success=\(response.success)")
        if response.success {
            // Set all user defaults
            UserDefaults.isLoggedIn = true
            UserDefaults.userId = response.user_id
            UserDefaults.userType = response.user_type
            UserDefaults.accessToken = response.access_token
            UserDefaults.refreshToken = response.refresh_token
            UserDefaults.email = email
            UserDefaults.staffSubRole = staffSubRole
            UserDefaults.hasCompletedOnboarding = false
            
            // Store staff_id for all staff types (admin, doctor, lab tech)
            if response.user_type == "admin" || response.user_type == "staff" {
                UserDefaults.standard.set(response.user_id, forKey: "staff_id")
            }
            
            // Force synchronize
            UserDefaults.standard.synchronize()
            
            DispatchQueue.main.async {
                navigationPath.removeLast(navigationPath.count) // Clear entire stack
                switch response.user_type {
                case "admin":
                    navigationPath.append(AppRoute.adminOnboarding)
                case "staff":
                    if staffSubRole == "doctor" {
                        navigationPath.append(AppRoute.doctorOnboarding(staffId: response.user_id))
                    } else {
                        // For lab technicians
                        UserDefaults.standard.set(response.user_id, forKey: "staff_id")
                        navigationPath.append(AppRoute.labTechOnboarding)
                    }
                case "patient":
                    navigationPath.append(AppRoute.patientOnboarding)
                default:
                    print("Unknown user type: \(response.user_type)")
                    authViewModel.errorMessage = "Unsupported user type"
                    authViewModel.showError = true
                }
            }
        } else {
            print("Login failed: \(response.message)")
            authViewModel.errorMessage = response.message
            authViewModel.showError = true
        }
    }

    private func loginAction() {
        guard !email.isEmpty else {
            authViewModel.errorMessage = "Please enter your email"
            authViewModel.showError = true
            return
        }

        guard isOTPRequested else {
            authViewModel.errorMessage = "Please request a verification code first"
            authViewModel.showError = true
            return
        }

        guard otpCode.count == 6 else {
            authViewModel.errorMessage = "Please enter the 6-digit verification code"
            authViewModel.showError = true
            return
        }

        focusedField = nil

        withAnimation(.easeInOut(duration: 0.6)) {
            isLoading = true
            scale = 0.95
        }

        verifyOTP()
    }

    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

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

// Custom Role Toggle Button
struct RoleButton: View {
    let role: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    private var displayName: String {
        // Convert first letter to uppercase for display
        let firstChar = role.prefix(1).uppercased()
        let remainingChars = role.dropFirst()
        return firstChar + remainingChars
    }
    
    private var roleIcon: String {
        switch role.lowercased() {
        case "admin":
            return "shield.fill"
        case "staff":
            return "person.3.fill"
        case "patient":
            return "heart.fill"
        case "doctor":
            return "stethoscope"
        case "lab technician":
            return "testtube.2"
        default:
            return "person.fill"
        }
    }
    
    private var roleColor: Color {
        switch role.lowercased() {
        case "admin":
            return Color(hex: "6B46C1") // Purple
        case "staff":
            return Color(hex: "3182CE") // Blue
        case "patient":
            return Color(hex: "38A169") // Green
        case "doctor":
            return Color(hex: "3182CE") // Blue
        case "lab technician":
            return Color(hex: "DD6B20") // Orange
        default:
            return Color(hex: "4A90E2") // Default blue
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
                
                Text(displayName)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? roleColor : colorScheme == .dark ? .white.opacity(0.7) : Color(hex: "4A5568"))
            }
            .padding(.vertical, 5)
            .scaleEffect(isSelected ? (isPressed ? 1.08 : 1.05) : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
