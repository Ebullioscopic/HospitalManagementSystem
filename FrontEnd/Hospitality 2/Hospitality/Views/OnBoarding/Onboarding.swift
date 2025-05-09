import SwiftUI
import UIKit
import Combine

// MARK: - Onboarding Screens for Different User Types

struct AdminOnboarding: View {
    @State private var navigateToDashboard = false
    
    var body: some View {
        OnboardingBase(
            title: "Admin Dashboard",
            icon: "shield.fill",
            description: "Complete administrative oversight",
            features: [
                "Manage all hospital staff",
                "Oversee facility operations",
                "Generate reports",
                "Configure system settings"
            ],
            buttonText: "Enter Dashboard",
            destination: AnyView(AdminHomeView())
        )
        .onChange(of: navigateToDashboard) { newValue in
            if newValue {
                UserDefaults.hasCompletedOnboarding = true
                UserDefaults.standard.synchronize()
            }
        }
    }
}

struct DoctorOnboarding: View {
    let doctorId: String
    @State private var navigateToDashboard = false
    
    var body: some View {
        OnboardingBase(
            title: "Doctor Portal",
            icon: "stethoscope",
            description: "Efficient patient management",
            features: [
                "View patient schedules",
                "Access medical records",
                "Order tests",
                "Prescribe medications"
            ],
            buttonText: "Begin Patient Care",
            destination: AnyView(DoctorDashboardView(doctorId: doctorId))
        )
        .onChange(of: navigateToDashboard) { newValue in
            if newValue {
                UserDefaults.hasCompletedOnboarding = true
                UserDefaults.standard.synchronize()
            }
        }
    }
}

struct PatientOnboarding: View {
    @State private var navigateToDashboard = false
    
    var body: some View {
        OnboardingBase(
            title: "Patient Portal",
            icon: "heart.fill",
            description: "Your healthcare simplified",
            features: [
                "Get Doctor Recommandations",
                "Book Appointments",
                "View Test Results",
                "View Prescriptions"
            ],
            buttonText: "Access My Health",
            destination: AnyView(HomePatient())
        )
        .onChange(of: navigateToDashboard) { newValue in
            if newValue {
                UserDefaults.hasCompletedOnboarding = true
                UserDefaults.standard.synchronize()
            }
        }
    }
}

struct LabTechOnboarding: View {
    @State private var navigateToDashboard = false
    
    var body: some View {
        OnboardingBase(
            title: "Lab Technician",
            icon: "testtube.2",
            description: "Efficient lab management",
            features: [
                "Process test orders",
                "Upload results",
                "Manage lab inventory",
                "Track specimens"
            ],
            buttonText: "Enter Lab Portal",
            destination: AnyView(LabTechnicianView())
        )
        .onChange(of: navigateToDashboard) { newValue in
            if newValue {
                UserDefaults.hasCompletedOnboarding = true
                UserDefaults.standard.synchronize()
            }
        }
    }
}

// MARK: - Reusable Onboarding Base Component

struct OnboardingBase: View {
    let title: String
    let icon: String
    let description: String
    let features: [String]
    let buttonText: String
    let destination: AnyView
    
    @State private var navigate = false
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.8
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color(hex: "101420") : Color(hex: "E8F5FF"),
                        colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: icon)
                                .foregroundColor(colorScheme == .dark ? .blue : Color(hex: "4A90E2"))
                                .font(.system(size: 24))
                            
                            Text(title)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                    }
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // Content Card
                    VStack(spacing: 25) {
                        ZStack {
                            Circle()
                                .fill(colorScheme == .dark ? Color.blue.opacity(0.1) : Color.blue.opacity(0.05))
                                .frame(width: 180, height: 180)
                            
                            Circle()
                                .fill(colorScheme == .dark ? Color.blue.opacity(0.15) : Color.blue.opacity(0.08))
                                .frame(width: 160, height: 160)
                            
                            Image(systemName: icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(colorScheme == .dark ? .blue : Color(hex: "4A90E2"))
                        }
                        
                        VStack(spacing: 8) {
                            Text(title)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                            
                            Text(description)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(features, id: \.self) { feature in
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(colorScheme == .dark ? Color.blue.opacity(0.2) : Color.blue.opacity(0.1))
                                            .frame(width: 32, height: 32)
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(colorScheme == .dark ? .blue : Color(hex: "4A90E2"))
                                    }
                                    
                                    Text(feature)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 30)
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(.vertical, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(colorScheme == .dark ? Color(hex: "1A202C").opacity(0.7) : Color.white.opacity(0.8))
                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Continue Button
                    Button(action: {
                        navigate = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "4A90E2"), Color(hex: "5E5CE6")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 58)
                                .shadow(color: Color(hex: "4A90E2").opacity(0.4), radius: 12, x: 0, y: 6)
                            
                            Text(buttonText)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 20)
                }
                .opacity(opacity)
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        opacity = 1
                        scale = 1.0
                    }
                }
                .navigationDestination(isPresented: $navigate) {
                    destination
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
