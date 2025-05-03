import SwiftUI

struct PatientAppointView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    let appointments: [AppointmentData]
    @State private var searchText: String = ""
    @State private var selectedStatusFilter: String = "All"
    @State private var sortOrder: String = "Recent First"
    @State private var selectedAppointment: AppointmentData?
    @State private var showAppointmentDetails: Bool = false
    @State private var opacity: Double = 0.0
    @State private var iconScale: CGFloat = 0.8
    
    private var filteredAndSortedAppointments: [AppointmentData] {
        // Filter appointments
        let filtered = appointments.filter { appointment in
            let matchesSearch = searchText.isEmpty ||
                appointment.doctorName.lowercased().contains(searchText.lowercased()) ||
                appointment.specialty.lowercased().contains(searchText.lowercased())
            let matchesStatus = selectedStatusFilter == "All" || appointment.status.rawValue == selectedStatusFilter
            return matchesSearch && matchesStatus
        }
        
        // Sort appointments
        return filtered.sorted { a1, a2 in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            guard let date1 = dateFormatter.date(from: a1.date),
                  let date2 = dateFormatter.date(from: a2.date) else {
                return false
            }
            return sortOrder == "Recent First" ? date1 > date2 : date1 < date2
        }
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
            
            // Background circles
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
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Appointment History")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                            
                            Text("View and filter your appointments")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            triggerHaptic(style: .medium)
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
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
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search by doctor or specialty...", text: $searchText)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                            .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.15), radius: 10, x: 0, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colorScheme == .dark ? Color.blue.opacity(0.3) : Color(hex: "4A90E2").opacity(0.3), lineWidth: 1.5)
                    )
                    .padding(.horizontal)
                    
                    // Filter and Sort Pickers
                    HStack(spacing: 12) {
                        Picker("Status", selection: $selectedStatusFilter) {
                            Text("All").tag("All")
                            Text("Upcoming").tag("Upcoming")
                            Text("Completed").tag("Completed")
                            Text("Cancelled").tag("Cancelled")
                            Text("Rescheduled").tag("Rescheduled")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                                .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.15), radius: 10, x: 0, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorScheme == .dark ? Color.blue.opacity(0.3) : Color(hex: "4A90E2").opacity(0.3), lineWidth: 1.5)
                        )
                        
                        Picker("Sort", selection: $sortOrder) {
                            Text("Recent First").tag("Recent First")
                            Text("Oldest First").tag("Oldest First")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                                .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.15), radius: 10, x: 0, y: 5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorScheme == .dark ? Color.blue.opacity(0.3) : Color(hex: "4A90E2").opacity(0.3), lineWidth: 1.5)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Appointments List
                    LazyVStack(spacing: 12) {
                        if filteredAndSortedAppointments.isEmpty {
                            Text("No appointments found")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "718096"))
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(filteredAndSortedAppointments) { appointment in
                                AppointmentCard(appointment: appointment)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        triggerHaptic(style: .light)
                                        selectedAppointment = appointment
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            showAppointmentDetails = true
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.vertical)
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
            
            // Appointment Details Overlay
            if showAppointmentDetails, let appointment = selectedAppointment {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showAppointmentDetails = false
                        }
                    }
                
                CompactAppointmentDetailOverlay(
                    appointment: appointment,
                    isShowing: $showAppointmentDetails
                )
                .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
        }
        .navigationTitle("Appointments")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}



struct PatientAppointView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PatientAppointView(appointments: [
                AppointmentData(
                    doctorName: "Dr. Sarah Johnson",
                    specialty: "Cardiologist",
                    date: "Apr 15, 2025",
                    time: "10:30 AM",
                    status: .completed,
                    notes: "Regular checkup."
                ),
                AppointmentData(
                    doctorName: "Dr. Emily Wilson",
                    specialty: "Orthopedist",
                    date: "Apr 25, 2025",
                    time: "9:00 AM",
                    status: .upcoming,
                    notes: "Joint assessment."
                )
            ])
        }
        .preferredColorScheme(.light)
        
        NavigationStack {
            PatientAppointView(appointments: [
                AppointmentData(
                    doctorName: "Dr. Sarah Johnson",
                    specialty: "Cardiologist",
                    date: "Apr 15, 2025",
                    time: "10:30 AM",
                    status: .completed,
                    notes: "Regular checkup."
                )
            ])
        }
        .preferredColorScheme(.dark)
    }
}
