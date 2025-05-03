import SwiftUI

struct AppointmentsListView: View {
    let appointments: [DoctorResponse.DocAppointment]
    @State private var currentDateTime = Date()
    @State private var doctorName = "User"
    @State private var filterOption = "All"
    
    // Filter options
    private let filterOptions = ["All", "Today", "Upcoming", "Past"]
    
    var body: some View {
        VStack {
            // Doctor info header
            HStack {
                VStack(alignment: .leading) {
                    Text("Welcome, \(doctorName)")
                        .font(.headline)
                    Text(formattedCurrentDate())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "bell")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Filter selector
            Picker("Filter", selection: $filterOption) {
                ForEach(filterOptions, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    if filteredAppointments.isEmpty {
                        EmptyStateView(
                            icon: "You don't have any \(filterOption.lowercased()) appointments scheduled.", title: "Hey", message: "calendar.badge.exclamationmark"
                        )
                        .padding(.top, 40)
                    } else {
                        ForEach(filteredAppointments) { appointment in
                            NavigationLink(destination: AppointmentDetailsView(appointment: appointment)) {
                                AppointmentCardView(appointment: appointment)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Appointments")
        .onAppear {
            // Set current date/time when view appears
            currentDateTime = Date()
            
            // Update with current date - hardcoded for the specific timestamp
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let specificDate = dateFormatter.date(from: "2025-04-27 20:15:53") {
                currentDateTime = specificDate
            }
            
            // Start a timer to update current time every minute
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                currentDateTime = Date()
            }
        }
    }
    
    // Filter appointments based on selected option
    private var filteredAppointments: [DoctorResponse.DocAppointment] {
        switch filterOption {
        case "Today":
            return appointments.filter { isToday($0.date) }
        case "Upcoming":
            return appointments.filter { isFuture($0.date) }
        case "Past":
            return appointments.filter { isPast($0.date) }
        default:
            return appointments
        }
    }
    
    // Helper functions for date filtering
    private func isToday(_ dateString: String) -> Bool {
        let today = formattedDateOnly(Date())
        return dateString == today
    }
    
    private func isFuture(_ dateString: String) -> Bool {
        guard let appointmentDate = parseDate(dateString) else { return false }
        return appointmentDate > currentDateTime
    }
    
    private func isPast(_ dateString: String) -> Bool {
        guard let appointmentDate = parseDate(dateString) else { return false }
        return appointmentDate < currentDateTime
    }
    
    // Helper function to format current date for display
    private func formattedCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: currentDateTime)
    }
    
    // Helper function to get date-only string for comparison
    private func formattedDateOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // Helper function to parse date string from API
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}

struct AppointmentCardView: View {
    let appointment: DoctorResponse.DocAppointment
    
    var body: some View {
        HStack {
            // Left: Date indicator with improved styling
            VStack(spacing: 4) {
                Text(getDayFromDate(appointment.date))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(getMonthFromDate(appointment.date))
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(getYearFromDate(appointment.date))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60, height: 70)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            // Divider
            Rectangle()
                .fill(getStatusColor(appointment.status))
                .frame(width: 4)
                .cornerRadius(2)
                .padding(.horizontal, 8)
            
            // Right: Appointment details with more info
            VStack(alignment: .leading, spacing: 6) {
                Text("Patient #\(appointment.patientId)")
                    .font(.headline)
                
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(getPatientDisplayName(appointment.patientId))
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text("Appointment time will be displayed here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    StatusBadge(status: appointment.status)
                    Spacer()
                    Text("ID: \(appointment.appointmentId)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Helper function to get patient name (would normally come from a patient service)
    private func getPatientDisplayName(_ patientId: Int) -> String {
        // In a real app, you would lookup the patient name
        return "Patient Name"
    }
    
    // Helper functions to extract date components
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
            
            // Convert month number to name
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
    
    private func getStatusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "completed":
            return .green
        case "scheduled":
            return .blue
        case "cancelled":
            return .red
        default:
            return .gray
        }
    }
}



