//
//  login_logoheader.swift
//  Hospitality
//
//  Created by admin17 on 03/05/25.
//

import Foundation
import SwiftUI

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
    @Binding var password: String
    @Binding var otpCode: String
    @Binding var selectedRole: String
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
//            Text("Password")
//                .font(.system(size: 14, weight: .medium))
//                .foregroundColor(Color(hex: "4A5568"))
//                .padding(.leading, 4)
            
            InfoFieldPassword(
                title: "Enter your password",
                text: $password,
                isTyping: isFocusedPassword
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            roleSelectionSection
            emailFieldSection
            passwordFieldSection
            otpButtonSection
            if authViewModel.isOTPSent {
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
    private var roleSelectionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select User Type")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "4A5568"))
                .padding(.leading, 4)
                .accessibilityLabel("User type selection")
            
            HStack(spacing: 10) {
                ForEach(["admin", "staff", "patient"], id: \.self) { role in
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
