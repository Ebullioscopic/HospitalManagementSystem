import SwiftUI

struct AppointmentsListView: View {
    @State private var appointments: [DoctorResponse.DocAppointment] = []
    @State private var currentDateTime = Date()
    @State private var filterOption = "All"
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.colorScheme) var colorScheme
    
    private let filterOptions = ["Upcoming", "Completed", "Missed"]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(hex: "101420") : Color(hex: "E8F5FF"),
                    colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                if let error = errorMessage {
                    ErrorViewAppoint(error: error, onRetry: loadAppointments)
                } else if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding(.top, 50)
                } else {
                    Spacer()
                    
                    Picker("Filter", selection: $filterOption) {
                        ForEach(filterOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if filteredAppointments.isEmpty {
                                EmptyStateView(
                                    icon: "calendar.badge.exclamationmark",
                                    title: "No Appointments",
                                    message: "You don't have any \(filterOption.lowercased()) appointments."
                                )
                                .padding(.top, 40)
                            } else {
                                ForEach(filteredAppointments) { appointment in
                                    NavigationLink(destination: AppointmentDetailsView(appointment: appointment)) {
                                        AppointmentCardView(appointment: appointment, currentDateTime: $currentDateTime)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Appointments")
        .onAppear {
            currentDateTime = Date()
            loadAppointments()
            
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                currentDateTime = Date()
            }
        }
    }
    
    private func loadAppointments() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedAppointments = try await DoctorServices().fetchDoctorAppointmentHistory()
                DispatchQueue.main.async {
                    if fetchedAppointments.isEmpty {
                        self.errorMessage = "No appointments found."
                        self.isLoading = false
                        return
                    }
                    self.appointments = fetchedAppointments
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private var filteredAppointments: [DoctorResponse.DocAppointment] {
        switch filterOption {
        case "Upcoming":
            return appointments.filter { $0.status.lowercased() == "upcoming" }
        case "Completed":
            return appointments.filter { $0.status.lowercased() == "completed" }
        case "Missed":
            return appointments.filter { $0.status.lowercased() == "missed" || $0.status.lowercased() == "cancelled" }
        default:
            return appointments
        }
    }
}

struct AppointmentCardView: View {
    let appointment: DoctorResponse.DocAppointment
    @Binding var currentDateTime: Date
    @State private var patientName: String = "Loading..."
    @State private var slotStartTime: String = "Loading..."
    @State private var isLoading = false
    @State private var isSlotLoading = false
    @State private var showError = false

    private let primaryColor = Color(hex: "0077CC")
    private let statusColor: [String: Color] = [
        "completed": .green,
        "cancelled": .red,
        "upcoming": .blue,
        "missed": .orange
    ]
    
    var body: some View {
        HStack(spacing: 12) {
            // Date Badge
            VStack(spacing: 4) {
                Text(getDayFromDate(appointment.date))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(primaryColor)
                
                Text(getMonthFromDate(appointment.date).uppercased())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(getYearFromDate(appointment.date))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)
            .padding(.vertical, 8)
            .background(primaryColor.opacity(0.1))
            .cornerRadius(8)
            
            // Appointment Details
            VStack(alignment: .leading, spacing: 6) {
                // Patient Name
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text(patientName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                // Slot Time
                if isSlotLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text(slotStartTime)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                // Patient ID
                Text("Patient ID: \(appointment.patientId)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status Badge
            if let statusColor = statusColor[appointment.status.lowercased()] {
                Text(appointment.status.capitalized)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(statusColor.opacity(0.15))
                    )
                    .foregroundColor(statusColor)
            }
            
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .onAppear {
            loadPatientName()
            loadSlotTime()
        }
        .alert("Failed to load data", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private var dateBadge: some View {
        VStack(spacing: 4) {
            Text(getDayFromDate(appointment.date))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(primaryColor)
            
            Text(getMonthFromDate(appointment.date).uppercased())
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
            
            Text(getYearFromDate(appointment.date))
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(width: 60)
        .padding(.vertical, 8)
        .background(primaryColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var timeDisplay: some View {
        VStack(alignment: .trailing) {
            if isSlotLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Text(slotStartTime)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Text("Appointment Time")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var patientInfoSection: some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundColor(primaryColor)
            
            VStack(alignment: .leading) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text(patientName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Text("Patient ID: \(appointment.patientId)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var statusAndIdSection: some View {
        HStack {
            StatusBadge(status: appointment.status)
                .padding(6)
                .background(Color(.systemBackground))
                .cornerRadius(8)
            
            Spacer()
            
            Text("Appointment \(appointment.id)")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
    
    private func loadPatientName() {
        guard !isLoading else { return }
        
        if let cachedName = PatientCache.shared.getName(for: appointment.patientId) {
            patientName = cachedName
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let profile = try await DoctorServices().fetchPatientProfile(patientId: String(appointment.patientId))
                DispatchQueue.main.async {
                    patientName = profile.patientName
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    patientName = "Patient \(appointment.patientId)"
                    isLoading = false
                    showError = true
                }
            }
        }
    }
    
    private func loadSlotTime() {
        guard !isSlotLoading else { return }
        
        isSlotLoading = true
        
        Task {
            do {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                guard let appointmentDate = dateFormatter.date(from: String(appointment.date.prefix(10))) else {
                    throw NetworkError.unknownError
                }
                
                let dateString = dateFormatter.string(from: appointmentDate)
                let slots = try await DoctorServices().fetchDoctorSlots(doctorId: appointment.staffId, date: dateString)
                
                if let slot = slots.first(where: { $0.slot_id == appointment.slotId }) {
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "HH:mm:ss"
                    if let timeDate = timeFormatter.date(from: slot.slot_start_time) {
                        timeFormatter.dateFormat = "HH:mm"
                        DispatchQueue.main.async {
                            slotStartTime = timeFormatter.string(from: timeDate)
                            isSlotLoading = false
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        slotStartTime = "N/A"
                        isSlotLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    slotStartTime = "N/A"
                    isSlotLoading = false
                    showError = true
                }
            }
        }
    }
    
        // Helper functions
        private func getDayFromDate(_ dateString: String) -> String {
            if dateString.count >= 10 {
                let dayStartIndex = dateString.index(dateString.startIndex, offsetBy: 8)
                let dayEndIndex = dateString.index(dateString.startIndex, offsetBy: 10)
                return String(dateString[dayStartIndex..<dayEndIndex])
            }
            return "??"
        }
    
        private func getMonthFromDate(_ dateString: String) -> String {
            if dateString.count >= 7 {
                let monthStartIndex = dateString.index(dateString.startIndex, offsetBy: 5)
                let monthEndIndex = dateString.index(dateString.startIndex, offsetBy: 7)
                let monthNumber = String(dateString[monthStartIndex..<monthEndIndex])
    
                let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                if let month = Int(monthNumber), month >= 1, month <= 12 {
                    return months[month - 1]
                }
            }
            return "???"
        }
    
        private func getYearFromDate(_ dateString: String) -> String {
            if dateString.count >= 4 {
                let yearEndIndex = dateString.index(dateString.startIndex, offsetBy: 4)
                return String(dateString[..<yearEndIndex])
            }
            return "????"
        }
}

struct ErrorViewAppoint: View {
    let error: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)

            Text("Error Loading Appointments")
                .font(.headline)

            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button(action: onRetry) {
                Label("Try Again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .padding()
    }
}