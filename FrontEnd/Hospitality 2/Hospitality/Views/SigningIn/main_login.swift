import SwiftUI
import UIKit
import Combine

struct Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var otpCode: String = ""
    @State private var selectedRole: String = "patient"
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.8
    @State private var isLoading: Bool = false
    @State private var isOTPRequested: Bool = false
    @FocusState private var focusedField: Field?
    @Environment(\.colorScheme) var colorScheme

    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardVisible: Bool = false
    @State private var showRegistration = false
    @StateObject private var authViewModel = AuthViewModel()
    @State private var navigationPath = NavigationPath()

    // Define app routes as an enum for type-safe navigation
    enum AppRoute: Hashable {
        case adminHome
        case staffOnboarding
        case patientOnboarding
        case doctorDashboard(staffId: String)
        case patientHome
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
                        VStack(spacing: 90) {
                            Spacer()
                                .frame(height: 140)

                            VStack(spacing: 16) {
                                FormCard(
                                    email: $email,
                                    password: $password,
                                    otpCode: $otpCode,
                                    selectedRole: $selectedRole,
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
                                    isOTPRequested: isOTPRequested,
                                    action: loginAction,
                                    authViewModel: authViewModel
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
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .adminHome:
                        AdminHomeView()
                            .navigationBarBackButtonHidden(true)
                    case .staffOnboarding:
                        StaffOnboarding()
                            .navigationBarBackButtonHidden(true)
                    case .patientOnboarding:
                        OnboardingPatient()
                            .navigationBarBackButtonHidden(true)
                    case .doctorDashboard(let staffId):
                        DoctorDashboardView(doctorId: staffId)
                            .navigationBarBackButtonHidden(true)
                    case .patientHome:
                        HomePatient()
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
                .foregroundColor(Color(hex: "4A90E2"))
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
            
            // Force synchronize
            UserDefaults.standard.synchronize()
            
            print("Login: UserDefaults updated - isLoggedIn: \(UserDefaults.isLoggedIn)")
            
            DispatchQueue.main.async {
                navigationPath.removeLast(navigationPath.count) // Clear entire stack
                switch response.user_type {
                case "admin":
                    navigationPath.append(AppRoute.adminHome)
                case "staff":
                    navigationPath.append(AppRoute.staffOnboarding)
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

// Rest of your component views (StickyLogoHeaderView, FormCard, etc.) remain the same...
