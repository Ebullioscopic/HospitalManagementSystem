//
//  login_logoheader.swift
//  Hospitality
//
//  Created by admin17 on 03/05/25.
//

import Foundation
import SwiftUI

//struct LogoHeaderView: View {
//    var keyboardVisible: Bool
//    @Environment(\.colorScheme) var colorScheme
//    @State private var pulseScale = false
//
//    var body: some View {
//        VStack(spacing: 5) {
//            ZStack {
//                // Animated background circles
//                Circle()
//                    .fill(Color(hex: "4A90E2").opacity(0.2))
//                    .frame(width: pulseScale ? 90 : 80, height: pulseScale ? 90 : 80)
//                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseScale)
//
//                Circle()
//                    .fill(Color(hex: "4A90E2"))
//                    .frame(width: 70, height: 70)
//
//                Image(systemName: "heart.fill")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 35, height: 35)
//                    .foregroundColor(.white)
//                    .accessibilityLabel("Hospitality Logo")
//                    .scaleEffect(pulseScale ? 1.1 : 1.0)
//                    .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulseScale)
//            }
//            .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 0)
//            .padding(.bottom, 8)
//            .onAppear {
//                pulseScale = true
//            }
//
//            Text("Hospitality")
//                .font(.system(size: 34, weight: .bold, design: .rounded))
//                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
//                .accessibilityAddTraits(.isHeader)
//
//            Text("Healthcare made simple")
//                .font(.system(size: 16, weight: .medium, design: .rounded))
//                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
//                .padding(.bottom, keyboardVisible ? 5 : 10)
//        }
//    }
//}

struct FormCard: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var otpCode: String
    @Binding var selectedRole: String
    @Binding var staffSubRole: String
    @Binding var isOTPRequested: Bool
    var focusedField: Login.Field?
    var isFocusedEmail: Bool
    var isFocusedPassword: Bool
    let requestOTP: () -> Void
    let verifyOTP: () -> Void
    let isLoading: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var cardHover = false
    @ObservedObject var authViewModel: AuthViewModel
    
    // Add FocusState for password field
    @FocusState private var isPasswordFocused: Bool
    
    private var passwordFieldSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            InfoFieldPassword(
                title: "Enter your password",
                text: $password,
                isTyping: isFocusedPassword
            )
        }
    }
    
    private var EmailFieldSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            InfoFieldEmail(
                title: "Enter your Email",
                text: $email,
                isTyping: isFocusedEmail
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            roleSelectionSection
            EmailFieldSection
            passwordFieldSection
            otpButtonSection
            if authViewModel.isOTPSent {
                    OTPTextField(text: $otpCode, onComplete: {
                        print("FormCard: OTP complete")
                        authViewModel.isOTPSent = true
                    })
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .padding(.top, 5)
                }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color.bg : Color.bg)
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
    
    private var roleSelectionSection: some View {
            VStack(spacing: 16) {
                // Centered title
                Text("Who are you?")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "4A5568"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityLabel("User type selection")
                
                // Main role selection
                HStack(spacing: 20) {
                    Spacer()
                    ForEach(["admin", "staff", "patient"], id: \.self) { role in
                        RoleButton(
                            role: role,
                            isSelected: selectedRole == role,
                            action: {
                                withAnimation(.spring()) {
                                    selectedRole = role
                                    // Reset staffSubRole when switching away from staff
                                    if role != "staff" {
                                        staffSubRole = "doctor"
                                    }
                                    triggerHaptic()
                                }
                            }
                        )
                        .accessibilityLabel("\(role) role")
                        .accessibilityAddTraits(selectedRole == role ? [.isSelected] : [])
                        .accessibilityHint("Double tap to select \(role) role")
                    }
                    Spacer()
                }
              
                if selectedRole == "staff" {
                    VStack(spacing: 14) {
                        Text("Staff Role")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(hex: "4A5568"))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .accessibilityLabel("Staff role selection")
                        
                        HStack(spacing: 15) {
                            Spacer()
                            StaffSubRole(
                                role: "Doctor",
                                icon: "stethoscope",
                                isSelected: staffSubRole == "doctor",
                                action: {
                                    staffSubRole = "doctor"
                                    print("FormCard: Selected staffSubRole = doctor")
                                    triggerHaptic()
                                }
                            )
                            StaffSubRole(
                                role: "Lab Technician",
                                icon: "testtube.2",
                                isSelected: staffSubRole == "labTechnician",
                                action: {
                                    staffSubRole = "labTechnician"
                                    print("FormCard: Selected staffSubRole = labTechnician")
                                    triggerHaptic()
                                }
                            )
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colorScheme == .dark ? Color(hex: "1A1A1A").opacity(0.4) : Color(hex: "F7FAFC"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .strokeBorder(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "3182CE").opacity(0.4),
                                                Color(hex: "4A90E2").opacity(0.2),
                                                Color.clear
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .padding(.horizontal, 10)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.bottom, 6)
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
                RoundedRectangle(cornerRadius: 10)
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
                
                if authViewModel.isLoading {
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
            .disabled(authViewModel.isLoading)
        }
        .buttonStyle(BouncyButtonStyle())
    }
    
    // Haptic Feedback helper
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct StaffSubRole: View {
    let role: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    private var roleColor: Color {
        switch role {
        case "Doctor":
            return Color(hex: "3182CE") // Blue
        case "Lab Tech":
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
            HStack(spacing: 6) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ?
                            roleColor.opacity(0.9) :
                            Color.gray.opacity(0.1)
                        )
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: icon)
                        .foregroundColor(isSelected ? .white : colorScheme == .dark ? .white.opacity(0.7) : Color(hex: "4A5568"))
                        .font(.system(size: 14))
                }
                
                Text(role)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? roleColor : colorScheme == .dark ? .white.opacity(0.7) : Color(hex: "4A5568"))
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ?
                        (colorScheme == .dark ? Color(hex: "222222") : Color.white) :
                        Color.clear
                    )
                    .shadow(
                        color: isSelected ? roleColor.opacity(0.3) : Color.clear,
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isSelected ? roleColor : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? (isPressed ? 1.05 : 1.02) : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
