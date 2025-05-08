import SwiftUI

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
            
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 200)
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

struct AppointmentHistoryCard: View {
    let appointment: PatientAppointHistoryListResponse
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Appointment #\(appointment.appointment_id)")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    Text("\(formatDate(appointment.date)) • Slot \(appointment.slot_id)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .gray)
                }
                
                Spacer()
                
                StatusBadge(status: appointment.status)
            }
            
            Divider()
            
            HStack {
                // Check if staff_id exists and use it directly without optional binding
                VStack(alignment: .leading, spacing: 4) {
                    Text("Doctor")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.5) : .gray.opacity(0.7))
                    
                    Text(appointment.staff_id ?? "Unknown Doctor")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .black)
                }
                
                Spacer()
                
                // Display slot time based on slot ID
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.5) : .gray.opacity(0.7))
                    
                    Text(getTimeForSlot(appointment.slot_id))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .black)
                }
            }
            
            if let reason = appointment.reason, !reason.isEmpty {
                Text("Reason: \(reason)")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .gray)
                    .padding(.top, 4)
            } else {
                Text("No reason provided")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.5) : .gray.opacity(0.7))
                    .italic()
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                .shadow(
                    color: colorScheme == .dark ? Color.black.opacity(0.4) : Color.gray.opacity(0.2),
                    radius: 5, x: 0, y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue, lineWidth: 1)
        )
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return dateString
        }
        
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    private func getTimeForSlot(_ slotId: Int) -> String {
        // Simple mapping of slot ID to time
        // You can customize this based on your app's slot timing structure
        switch slotId {
            case 1: return "9:00 AM - 9:30 AM"
            case 2: return "9:30 AM - 10:00 AM"
            case 3: return "10:00 AM - 10:30 AM"
            case 4: return "10:30 AM - 11:00 AM"
            case 5: return "11:00 AM - 11:30 AM"
            case 6: return "11:30 AM - 12:00 PM"
            case 7: return "2:00 PM - 2:30 PM"
            case 8: return "2:30 PM - 3:00 PM"
            case 9: return "3:00 PM - 3:30 PM"
            case 10: return "3:30 PM - 4:00 PM"
            default: return "Slot \(slotId)"
        }
    }
}

struct RefreshableScrollView<Content: View>: View {
    let onRefresh: (@escaping () -> Void) -> Void
    let content: Content
    
    init(onRefresh: @escaping (@escaping () -> Void) -> Void, @ViewBuilder content: () -> Content) {
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 15.0, *) {
            ScrollView {
                content
                    .refreshable {
                        await withCheckedContinuation { continuation in
                            onRefresh {
                                continuation.resume()
                            }
                        }
                    }
            }
        } else {
            ScrollView {
                content
            }
        }
    }
}

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
                    
                    ReportsContent()
                        .tabItem {
                            Image(systemName: "chart.bar.doc.horizontal")
                            Text("Reports")
                        }
                        .tag(1)
                    
                    DoctorAppointmentsView()
                        .tabItem {
                            Image(systemName: "calendar.badge.clock")
                            Text("Appointments")
                        }
                        .tag(2)
                }
                .accentColor(colorScheme == .dark ? .blue : Color(hex: "4A90E2"))
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func getSampleAppointments() -> [AppointmentData] {
        return [
//            AppointmentData(
//                doctorName: "Dr. Sarah Johnson",
//                specialty: "Cardiologist",
//                date: "Apr 15, 2025",
//                time: "10:30 AM",
//                status: .completed,
//                notes: "Regular checkup, blood pressure normal. Follow-up in 6 months recommended."
//            ),
//            AppointmentData(
//                doctorName: "Dr. Michael Chen",
//                specialty: "Dermatologist",
//                date: "Mar 28, 2025",
//                time: "2:15 PM",
//                status: .completed,
//                notes: "Skin condition follow-up, prescribed new medication. Apply topical cream twice daily."
//            ),
//            AppointmentData(
//                doctorName: "Dr. Emily Wilson",
//                specialty: "Orthopedist",
//                date: "Apr 25, 2025",
//                time: "9:00 AM",
//                status: .upcoming,
//                notes: "Annual joint assessment. Bring previous X-ray reports if available."
//            ),
//            AppointmentData(
//                doctorName: "Dr. Robert Garcia",
//                specialty: "Neurologist",
//                date: "Feb 10, 2025",
//                time: "1:45 PM",
//                status: .completed,
//                notes: "Headache consultation, recommended lifestyle changes."
//            )
        ]
    }
}


struct HomeContent: View {
    @State private var appointmentForDetail: DoctorResponse.DocAppointment? = nil
    @State private var showDetailView = false
    @Environment(\.colorScheme) var colorScheme
    @Binding var showProfile: Bool
    @State private var iconScale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    @State private var appointmentHistory: [PatientAppointHistoryListResponse] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var lastRefreshTime = Date()
    @State private var isRefreshing = false
    @State private var selectedAppointment: AppointmentData?
    @State private var showRescheduleView = false
    @State private var appointmentToReschedule: PatientAppointHistoryListResponse?
    
    var body: some View {
        ZStack {
            backgroundGradient
            backgroundCircles
            contentScrollView
            if let appointment = selectedAppointment {
                AppointmentDetailOverlay(
                    appointment: appointment,
                    onManageAppointment: {
                        if let appointmentToReschedule = appointmentHistory.first(where: {
                            $0.status == "upcoming" &&
                            $0.reason == appointment.notes
                        }) {
                            self.appointmentToReschedule = appointmentToReschedule
                            withAnimation {
                                selectedAppointment = nil
                                showRescheduleView = true
                            }
                        }
                    },
                    onDismiss: {
                        withAnimation {
                            selectedAppointment = nil
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                opacity = 1.0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                iconScale = 1.0
            }
            refreshAppointments()
        }
        .sheet(isPresented: $showRescheduleView) {
            if let appointment = appointmentToReschedule {
                AppointmentRescheduleView(
                    appointmentId: appointment.appointment_id,
                    doctorId: appointment.staff_id ?? "",
                    currentDate: appointment.date,
                    currentSlotId: appointment.slot_id,
                    reason: appointment.reason ?? "",
                    onRescheduleComplete: {
                        showRescheduleView = false
                        refreshAppointments()
                    }
                )
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                colorScheme == .dark ? Color(hex: "101420") : Color(hex: "E8F5FF"),
                colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var backgroundCircles: some View {
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
    }
    
    private var contentScrollView: some View {
        RefreshableScrollView(onRefresh: { done in
            refreshAppointments {
                done()
            }
        }) {
            VStack(alignment: .leading, spacing: 20) {
                headerView
                actionCardsView
                recentAppointmentsView
            }
            .padding(.vertical)
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Welcome to Patient Dashboard")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                
                Text("Last updated: \(lastRefreshTime.formatted(date: .omitted, time: .shortened))")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                NavigationLink(destination: FAQsView()) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 25))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "4A90E2"))
                }
                
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
        }
        .padding(.top, 16)
        .padding(.horizontal)
    }
    
    private var actionCardsView: some View {
        HStack {
            Spacer()
            NavigationLink(destination: PatientDoctorListView(onAppointmentBooked: {
                refreshAppointments()
            })) {
                SquareScheduleCard(
                    icon: "calendar.badge.plus",
                    title: "Schedule Appointment",
                    color: colorScheme == .dark ? Color(hex: "1E88E5") : Color(hex: "2196F3")
                )
                .frame(width: 180)
            }
            .simultaneousGesture(TapGesture().onEnded {
                triggerHaptic()
            })
            Spacer()
            NavigationLink(destination: DoctorRecommender()) {
                SquareScheduleCard(
                    icon: "brain.head.profile",
                    title: "Physician Referral",
                    color: colorScheme == .dark ? Color(hex: "FF7043") : Color(hex: "FF5722")
                )
                .frame(width: 180)
            }
            .simultaneousGesture(TapGesture().onEnded {
                triggerHaptic()
            })
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private var recentAppointmentsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming Appointments")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                
                Spacer()
                
                if isLoading && !isRefreshing {
                    ProgressView()
                }
            }
            .padding(.horizontal)
            
            if let error = errorMessage {
                ErrorView(message: error) {
                    refreshAppointments {}
                }
            } else {
                // Filter only upcoming appointments
                let upcomingAppointments = appointmentHistory.filter { $0.status.lowercased() == "upcoming" }
                
                if upcomingAppointments.isEmpty {
                    EmptyStateView(
                        icon: "calendar.badge.exclamationmark",
                        title: "No Upcoming Appointments",
                        message: "You don't have any upcoming appointments scheduled"
                    )
                } else {
                    // Use the same card style as DoctorAppointmentsView
                    VStack(spacing: 12) {
                        ForEach(upcomingAppointments.sorted(by: { $0.appointment_id > $1.appointment_id })) { appointment in
                            // Convert the PatientAppointHistoryListResponse to DocAppointment format
                            let docAppointment = DoctorResponse.DocAppointment(
                                appointmentId: appointment.appointment_id,
                                date: appointment.date,
                                slotId: appointment.slot_id,
                                staffId: appointment.staff_id ?? "Unknown",
                                patientId: appointment.patient_id,
                                status: appointment.status
                            )
                            
                            Button(action: {
                                // Set the selected appointment and show the detail view
                                appointmentForDetail = docAppointment
                                showDetailView = true
                            }) {
                                AppointmentRow(appointment: docAppointment)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        // Update sheet to use appointmentForDetail instead of selectedAppointment
        .sheet(isPresented: $showDetailView) {
            if let appointment = appointmentForDetail {
                AppointmentDetailView(appointment: appointment)
            }
        }
    }

    // Helper function to map slot IDs to time ranges
    private func getTimeForSlot(_ slotId: Int) -> String {
        // Simple mapping of slot ID to time
        // You can customize this based on your app's slot timing structure
        switch slotId {
            case 1: return "9:00 AM - 9:30 AM"
            case 2: return "9:30 AM - 10:00 AM"
            case 3: return "10:00 AM - 10:30 AM"
            case 4: return "10:30 AM - 11:00 AM"
            case 5: return "11:00 AM - 11:30 AM"
            case 6: return "11:30 AM - 12:00 PM"
            case 7: return "2:00 PM - 2:30 PM"
            case 8: return "2:30 PM - 3:00 PM"
            case 9: return "3:00 PM - 3:30 PM"
            case 10: return "3:30 PM - 4:00 PM"
            default: return "Slot \(slotId)"
        }
    }
    
    private var appointmentListView: some View {
        VStack(spacing: 16) {
            ForEach(appointmentHistory.sorted(by: { $0.appointment_id > $1.appointment_id })) { appointment in
                appointmentCardView(for: appointment)
            }
        }
    }
    
    private func appointmentCardView(for appointment: PatientAppointHistoryListResponse) -> some View {
        AppointmentHistoryCard(appointment: appointment)
            .padding(.horizontal)
            .onTapGesture {
                if appointment.status == "upcoming" {
                    withAnimation {
                        selectedAppointment = AppointmentData(
                            doctorName: appointment.staff_id ?? "Unknown",
                            specialty: appointment.reason ?? "Unknown",
                            date: appointment.date,
                            time: appointment.status ?? "Unknown",
                            notes: appointment.reason ?? "No notes provided"
                        )
                    }
                }
            }
            .transition(.opacity.combined(with: .scale(0.95)))
    }
    
    private func refreshAppointments(completion: @escaping () -> Void = {}) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(Constants.baseURL)/hospital/general/appointments/history/") else {
            errorMessage = "Invalid URL"
            isLoading = false
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                isRefreshing = false
                lastRefreshTime = Date()
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    completion()
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Invalid response"
                    completion()
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode), let data = data else {
                    errorMessage = "Server error: \(httpResponse.statusCode)"
                    completion()
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode([PatientAppointHistoryListResponse].self, from: data)
                    withAnimation {
                        appointmentHistory = response
                    }
                } catch {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
                completion()
            }
        }.resume()
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct AppointmentData: Identifiable {
    let id = UUID()
    let doctorName: String
    let specialty: String
    let date: String
    let time: String
//    let status: AppointmentStatus
    let notes: String
}
struct AppointmentDetailOverlay: View {
//    let appointment: DoctorResponse.DocAppointment
    let appointment: AppointmentData
    let onManageAppointment: () -> Void
    let onDismiss: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 20) {
                Text("Appointment Details")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                
                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(label: "Doctor", value: appointment.doctorName)
                    DetailRow(label: "Specialty", value: appointment.specialty)
                    DetailRow(label: "Date", value: appointment.date)
                    DetailRow(label: "Time", value: appointment.time)
//                    DetailRow(label: "Status", value: appointment.status.rawValue.capitalized)
                    DetailRow(label: "Notes", value: appointment.notes)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                        .shadow(
                            color: colorScheme == .dark ? Color.black.opacity(0.4) : Color.gray.opacity(0.2),
                            radius: 5, x: 0, y: 2
                        )
                )
                
//                if appointment.status == .upcoming {
//                    Button(action: {
//                        triggerHaptic()
//                        onManageAppointment()
//                    }) {
//                        Text("Reschedule Appointment")
//                            .font(.system(size: 18, weight: .semibold, design: .rounded))
//                            .foregroundColor(.white)
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.blue)
//                            .cornerRadius(10)
//                    }
//                }
                
                Button(action: {
                    triggerHaptic()
                    onDismiss()
                }) {
                    Text("Close")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "4A90E2"))
                }
                .padding(.top, 8)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .dark ? Color(hex: "101420") : Color(hex: "F0F8FF"))
                    .shadow(radius: 10)
            )
            .padding(.horizontal, 20)
        }
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct AppointmentRescheduleView: View {
    let appointmentId: Int
    let doctorId: String
    let currentDate: String
    let currentSlotId: Int
    let reason: String
    let onRescheduleComplete: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State private var doctor: PatientSpecificDoctorResponse?
    @State private var slots: [PatientSlotListResponse] = []
    @State private var selectedDate = Date()
    @State private var selectedSlot: PatientSlotListResponse?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var rescheduleSuccess = false
    @State private var showConfirmation = false
    
    private var initialDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: currentDate) ?? Date()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading && doctor == nil {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 300)
                    } else if let errorMessage = errorMessage {
                        ErrorView(message: errorMessage, onRetry: fetchDoctorDetails)
                    } else {
                        if let doctor = doctor {
                            VStack(spacing: 16) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.1))
                                            .frame(width: 80, height: 80)
                                        
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.blue)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(doctor.staff_name)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Text(doctor.specialization)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Appointment")
                                .font(.headline)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Date: \(formatDate(currentDate))")
                                    Text("Appointment ID: \(appointmentId)")
                                    if !reason.isEmpty {
                                        Text("Reason: \(reason)")
                                    }
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select New Date")
                                .font(.headline)
                            
                            DatePicker("",
                                       selection: $selectedDate,
                                       in: Date()...(Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()),
                                       displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .onChange(of: selectedDate) { _ in
                                fetchSlots()
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        if isLoading && slots.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 100)
                        } else if slots.isEmpty {
                            Text("No available slots for selected date")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Available Slots")
                                    .font(.headline)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                                    ForEach(slots, id: \.slot_id) { slot in
                                        SlotButton(
                                            slot: slot,
                                            isSelected: selectedSlot?.slot_id == slot.slot_id,
                                            onSelect: {
                                                if !isSlotPassed(date: selectedDate, timeString: slot.slot_start_time) {
                                                    selectedSlot = slot
                                                }
                                            },
                                            isPassed: isSlotPassed(date: selectedDate, timeString: slot.slot_start_time)
                                        )
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        
                        Button(action: rescheduleAppointment) {
                            Text("Reschedule Appointment")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedSlot == nil ? Color.gray : Color.blue)
                                .cornerRadius(10)
                        }
                        .disabled(selectedSlot == nil)
                        .padding(.top, 20)
                    }
                }
                .padding()
            }
            .navigationTitle("Reschedule Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                selectedDate = initialDate
                fetchDoctorDetails()
                fetchSlots()
            }
            .alert(isPresented: $showConfirmation) {
                Alert(
                    title: Text(rescheduleSuccess ? "Success" : "Error"),
                    message: Text(rescheduleSuccess ?
                                  "Your appointment has been rescheduled successfully!" :
                                    "Failed to reschedule appointment. Please try again."),
                    dismissButton: .default(Text("OK")) {
                        if rescheduleSuccess {
                            onRescheduleComplete()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    private func isSlotPassed(date: Date, timeString: String) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        
        if !calendar.isDateInToday(date) {
            return date < now
        }
        
        let timeComponents = timeString.components(separatedBy: ":")
        guard timeComponents.count >= 2,
              let hour = Int(timeComponents[0]),
              let minute = Int(timeComponents[1]) else {
            print("Failed to parse time: \(timeString)")
            return false
        }
        
        let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
        let currentHour = currentComponents.hour ?? 0
        let currentMinute = currentComponents.minute ?? 0
        
        if hour < currentHour {
            return true
        } else if hour == currentHour {
            return minute <= currentMinute
        } else {
            return false
        }
    }
    
    private func fetchDoctorDetails() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(Constants.baseURL)/hospital/general/doctors/\(doctorId)/") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Invalid response"
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode), let data = data else {
                    errorMessage = "Server returned status code \(httpResponse.statusCode)"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(PatientSpecificDoctorResponse.self, from: data)
                    self.doctor = response
                } catch {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    private func fetchSlots() {
        isLoading = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)
        
        guard let url = URL(string: "\(Constants.baseURL)/hospital/general/doctors/\(doctorId)/slots/?date=\(dateString)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Invalid response"
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode), let data = data else {
                    errorMessage = "Server returned status code \(httpResponse.statusCode)"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode([PatientSlotListResponse].self, from: data)
                    self.slots = response.filter { !$0.is_booked }
                    self.selectedSlot = nil
                } catch {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    private func rescheduleAppointment() {
        guard let selectedSlot = selectedSlot else { return }
        
        isLoading = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)
        
        let requestBody: [String: Any] = [
            "date": dateString,
            "slot_id": selectedSlot.slot_id
        ]
        
        guard let url = URL(string: "\(Constants.baseURL)/hospital/general/appointments/\(appointmentId)/reschedule/") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            errorMessage = "Failed to encode request: \(error.localizedDescription)"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    showConfirmation = true
                    rescheduleSuccess = false
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Invalid response"
                    showConfirmation = true
                    rescheduleSuccess = false
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    rescheduleSuccess = true
                    showConfirmation = true
                } else {
                    errorMessage = "Server error: \(httpResponse.statusCode)"
                    rescheduleSuccess = false
                    showConfirmation = true
                }
            }
        }.resume()
    }
}
