import SwiftUI

struct AppointmentHistoryView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedAppointment: AppointmentData?
    @State private var showAppointmentDetails = false
    
    // Sample appointment data
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
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                ForEach(appointments) { appointment in
                    AppointmentCard(appointment: appointment)
                        .onTapGesture {
                            triggerHaptic(style: .light)
                            selectedAppointment = appointment
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showAppointmentDetails = true
                            }
                        }
                }
                
                NavigationLink(destination: PatientAppointView(appointments: appointments)) {
                    Text("View All Appointments")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.blue : Color(hex: "4A90E2"))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color.blue.opacity(0.15) : Color.blue.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(colorScheme == .dark ? Color.blue.opacity(0.3) : Color.blue.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.top, 8)
                .simultaneousGesture(TapGesture().onEnded {
                    triggerHaptic(style: .medium)
                })
            }
            .padding(.horizontal)
            
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
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// Appointment Card View
struct AppointmentCard: View {
    let appointment: AppointmentData
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Doctor icon with background
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "stethoscope")
                    .font(.system(size: 24))
                    .foregroundColor(statusColor)
            }
            
            // Appointment details
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.doctorName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                
                Text(appointment.specialty)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
                
                HStack {
                    Text("\(appointment.date) | \(appointment.time)")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(hex: "718096"))
                    
                    Spacer()
                    
                    // Status indicator
                    Text(appointment.status.rawValue)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(statusColor.opacity(0.15))
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                .shadow(color: colorScheme == .dark ? Color.black.opacity(0.2) : Color.gray.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    // Status color based on appointment status
    private var statusColor: Color {
        switch appointment.status {
        case .upcoming:
            return Color.blue
        case .completed:
            return Color.green
        case .cancelled:
            return Color.red
        case .rescheduled:
            return Color.orange
        }
    }
}

// Compact Appointment Detail Overlay
struct CompactAppointmentDetailOverlay: View {
    let appointment: AppointmentData
    @Binding var isShowing: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var scale: CGFloat = 0.9
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with doctor name and close button
            HStack {
                Text(appointment.doctorName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isShowing = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : Color(hex: "718096"))
                        .padding(6)
                        .background(
                            Circle()
                                .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                }
            }
            
            // Status pill
            Text(appointment.status.rawValue)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(statusColor.opacity(0.15))
                )
            
            Divider()
                .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.2))
            
            // Date and time
            HStack {
                // Date
                VStack(alignment: .leading, spacing: 2) {
                    Text("Date")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.5) : Color(hex: "718096"))
                    
                    Text(appointment.date)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                }
                
                Spacer()
                
                // Time
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Time")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.5) : Color(hex: "718096"))
                    
                    Text(appointment.time)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2D3748"))
                }
            }
            
            // Notes
            VStack(alignment: .leading, spacing: 2) {
                Text("Notes")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.5) : Color(hex: "718096"))
                
                Text(appointment.notes)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.9) : Color(hex: "2D3748"))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
            }
            
            // Action button for upcoming appointments
            if appointment.status == .upcoming {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        isShowing = false
                    }
                }) {
                    Text("Manage Appointment")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(colorScheme == .dark ? Color(hex: "4A90E2") : Color(hex: "2196F3"))
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(hex: "1E2533") : .white)
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .frame(width: 280)
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1
            }
        }
    }
    
    // Status color based on appointment status
    private var statusColor: Color {
        switch appointment.status {
        case .upcoming:
            return Color.blue
        case .completed:
            return Color.green
        case .cancelled:
            return Color.red
        case .rescheduled:
            return Color.orange
        }
    }
}

// Appointment Data Model
struct AppointmentData: Identifiable {
    let id = UUID()
    let doctorName: String
    let specialty: String
    let date: String
    let time: String
    let status: AppointmentStatus
    let notes: String
}

// Appointment Status Enum
enum AppointmentStatus: String {
    case upcoming = "Upcoming"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case rescheduled = "Rescheduled"
}

// Preview
struct AppointmentHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AppointmentHistoryView()
                .padding()
                .background(Color(UIColor.systemBackground))
        }
    }
}
