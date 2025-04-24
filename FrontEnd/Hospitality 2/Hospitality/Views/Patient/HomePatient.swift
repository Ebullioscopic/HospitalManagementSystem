import SwiftUI

struct HomePatient: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                TabView(selection: $selectedTab) {
                                
                    HomeContent(showProfile: $showProfile)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .tag(0)
                    
                    // Reports Tab
                    ReportsContent()
                        .tabItem {
                            Image(systemName: "chart.bar.doc.horizontal")
                            Text("Reports")
                        }
                        .tag(1)
                    
                    // Appointments Tab - Replacing Bills Tab
                    PatientAppointView(appointments: getSampleAppointments())
                        .tabItem {
                            Image(systemName: "calendar.badge.clock")
                            Text("Appointments")
                        }
                        .tag(2)
                }
                .accentColor(colorScheme == .dark ? .blue : Color(hex: "4A90E2"))
                .animation(.easeInOut(duration: 0.3), value: selectedTab) // Smooth tab transition
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
    
    // Helper function to get sample appointments
    private func getSampleAppointments() -> [AppointmentData] {
        return [
            AppointmentData(
                doctorName: "Dr. Sarah Johnson",
                specialty: "Cardiologist",
                date: "Apr 15, 2025",
                time: "10:30 AM",
                status: .completed,
                notes: "Regular checkup, blood pressure normal. Follow-up in 6 months recommended."
            ),
            AppointmentData(
                doctorName: "Dr. Michael Chen",
                specialty: "Dermatologist",
                date: "Mar 28, 2025",
                time: "2:15 PM",
                status: .completed,
                notes: "Skin condition follow-up, prescribed new medication. Apply topical cream twice daily."
            ),
            AppointmentData(
                doctorName: "Dr. Emily Wilson",
                specialty: "Orthopedist",
                date: "Apr 25, 2025",
                time: "9:00 AM",
                status: .upcoming,
                notes: "Annual joint assessment. Bring previous X-ray reports if available."
            ),
            AppointmentData(
                doctorName: "Dr. Robert Garcia",
                specialty: "Neurologist",
                date: "Feb 10, 2025",
                time: "1:45 PM",
                status: .completed,
                notes: "Headache consultation, recommended lifestyle changes."
            )
        ]
    }
}

// Updated HomeContent View with Recents section instead of History
struct HomeContent: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var showProfile: Bool
    @State private var iconScale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    // Sample appointments data - now we'll filter to show only upcoming
    private let appointments = [
        AppointmentData(
            doctorName: "Dr. Sarah Johnson",
            specialty: "Cardiologist",
            date: "Apr 15, 2025",
            time: "10:30 AM",
            status: .completed,
            notes: "Regular checkup, blood pressure normal. Follow-up in 6 months recommended."
        ),
        AppointmentData(
            doctorName: "Dr. Michael Chen",
            specialty: "Dermatologist",
            date: "Mar 28, 2025",
            time: "2:15 PM",
            status: .completed,
            notes: "Skin condition follow-up, prescribed new medication. Apply topical cream twice daily."
        ),
        AppointmentData(
            doctorName: "Dr. Emily Wilson",
            specialty: "Orthopedist",
            date: "Apr 25, 2025",
            time: "9:00 AM",
            status: .upcoming,
            notes: "Annual joint assessment. Bring previous X-ray reports if available."
        ),
        AppointmentData(
            doctorName: "Dr. Robert Garcia",
            specialty: "Neurologist",
            date: "Feb 10, 2025",
            time: "1:45 PM",
            status: .completed,
            notes: "Headache consultation, recommended lifestyle changes."
        )
    ]
    
    // Filter to get only upcoming appointments
    private var upcomingAppointments: [AppointmentData] {
        return appointments.filter { $0.status == .upcoming }
    }
    
    var body: some View {
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
            
            // Background circles similar to onboarding
            ForEach(0..<8) { _ in
                Circle()
                    .fill(colorScheme == .dark ? Color.blue.opacity(0.05) : Color.blue.opacity(0.03))
                    .frame(width: CGFloat.random(in: 50...200))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: 3)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with profile icon on the right
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome to Patient Dashboard")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                            
                            Text("What would you like to do today?")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            triggerHaptic()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                showProfile = true
                            }
                        }) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "4A90E2"))
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.blue.opacity(0.1))
                                )
                                .scaleEffect(iconScale)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal)
                    
                    // Single appointment scheduling card (centered and wider)
                    HStack {
                        Spacer()
                        NavigationLink(destination: AppointmentSchedulingView()) {
                            SquareScheduleCard(
                                icon: "calendar.badge.plus",
                                title: "Schedule Appointment",
                                color: colorScheme == .dark ? Color(hex: "1E88E5") : Color(hex: "2196F3")
                            )
                            .frame(width: 300) // Wider card
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            triggerHaptic()
                        })
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Upcoming Appointments")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                            
                            Spacer()
                            
                          
                        }
                        .padding(.horizontal)
                        
                        // Only show upcoming appointments in Recents section
                        if upcomingAppointments.isEmpty {
                            Text("No upcoming appointments")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                                .padding(.horizontal)
                                .padding(.vertical, 20)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(upcomingAppointments) { appointment in
                                    AppointmentCard(appointment: appointment)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    opacity = 1.0
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                    iconScale = 1.0
                }
            }
        }
    }
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// Updated SquareScheduleCard Component
struct SquareScheduleCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: (() -> Void)?
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    init(icon: String, title: String, color: Color, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.color = color
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.3), color.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
                
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(color)
            }
            
            // Title
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 200) // Slightly taller for better proportions
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                .shadow(
                    color: colorScheme == .dark ? Color.black.opacity(0.4) : Color.gray.opacity(0.2),
                    radius: 12, x: 0, y: 6
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.4), color.opacity(0.2)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            action != nil ? TapGesture().onEnded {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPressed = false
                    }
                    action?()
                }
            } : nil
        )
    }
}

// Reusable card component for scheduling options
struct ScheduleCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
                action()
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon with colored background
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                .padding(.bottom, 4)
                
                // Title
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                
                // Description
                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 180)
            .background(
                RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.15), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(0.3), lineWidth: 1.5)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// BillsContent remains the same but is no longer used in the TabView
struct BillsContent: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var opacity: Double = 0.0
    
    var body: some View {
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
            
            // Background circles similar to onboarding
            ForEach(0..<8) { _ in
                Circle()
                    .fill(colorScheme == .dark ? Color.blue.opacity(0.05) : Color.blue.opacity(0.03))
                    .frame(width: CGFloat.random(in: 50...200))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: 3)
            }
            
            VStack {
                Text("Bills")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                
                Text("Track your medical expenses")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
            }
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    opacity = 1.0
                }
            }
        }
    }
}

struct HomePatient_Previews: PreviewProvider {
    static var previews: some View {
        HomePatient()
            .previewDevice("iPhone 14")
    }
}

