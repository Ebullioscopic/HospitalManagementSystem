import SwiftUI

// Main detail view for a selected appointment
struct AppointmentDetailView: View {
    let appointment: DoctorResponse.DocAppointment
    @StateObject private var viewModel = AppointmentDetailViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var activeTab: DetailTab = .overview
    @State private var showingRescheduleView = false
    
    
    enum DetailTab {
        case overview, diagnosis, prescription, vitals, profile
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tab selector
                    TabSelectionView(activeTab: $activeTab)
                    
                    // Content based on selected tab
                    ScrollView {
                        VStack(spacing: 16) {
                            AppointmentHeaderCard(appointment: appointment)
                                .padding(.horizontal)
                            
                            // Dynamic content based on selected tab
                            Group {
                                switch activeTab {
                                case .overview:
                                    AppointmentOverviewView(appointment: appointment)
                                case .diagnosis:
                                    if viewModel.isLoadingDiagnosis {
                                        LoadingView(message: "Loading diagnosis...")
                                    } else if let diagnosis = viewModel.diagnosis {
                                        DiagnosisDetailView(diagnosis: diagnosis)
                                    } else {
                                        EmptyStateView(
                                            icon: "stethoscope",
                                            title: "No Diagnosis",
                                            message: "No diagnosis information is available for this appointment."
                                        )
                                    }
                                case .prescription:
                                    if viewModel.isLoadingPrescription {
                                        LoadingView(message: "Loading prescription...")
                                    } else if let prescription = viewModel.prescription {
                                        PrescriptionDetailView(prescription: prescription)
                                    } else {
                                        EmptyStateView(
                                            icon: "pills",
                                            title: "No Prescription",
                                            message: "No prescription has been issued for this appointment."
                                        )
                                    }
                                case .vitals:
                                    if viewModel.isLoadingVitals {
                                        LoadingView(message: "Loading vitals...")
                                    } else if let vitals = viewModel.vitals {
                                        VitalsDetailView(vitals: vitals)
                                    } else {
                                        EmptyStateView(
                                            icon: "heart.text.square",
                                            title: "No Vitals",
                                            message: "No vitals data has been recorded for this appointment."
                                        )
                                    }
                                case .profile:
                                    if viewModel.isLoadingProfile {
                                        LoadingView(message: "Loading profile...")
                                    } else if let profile = viewModel.patientProfile {
                                        PatientProfileView(profile: profile)
                                    } else {
                                        EmptyStateView(
                                            icon: "person.crop.circle.badge.exclamationmark",
                                            title: "Profile Unavailable",
                                            message: "Unable to load patient profile information."
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Appointment Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if canReschedule(appointment) {
                            Button(action: {
                                showingRescheduleView = true
                            }) {
                                Label("Reschedule", systemImage: "calendar.badge.clock")
                            }
                        }
                        
                        Button(action: {
                            // Refresh data
                            viewModel.loadAllData(appointment: appointment)
                        }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        
                        // Add export option if needed
                        Button(action: {
                            // Export function
                        }) {
                            Label("Export Details", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .onAppear {
                viewModel.loadAllData(appointment: appointment)
            }
            .sheet(isPresented: $showingRescheduleView) {
                AppointmentRescheduleView(
                    appointmentId: appointment.appointmentId,
                    doctorId: appointment.staffId,
                    currentDate: appointment.date,
                    currentSlotId: appointment.slotId,
                    reason: "",
                    onRescheduleComplete: {
                        showingRescheduleView = false
                    }
                )
            }
        }
    }
    
    private func canReschedule(_ appointment: DoctorResponse.DocAppointment) -> Bool {
        return !isBeforeToday(appointment.date) &&
               appointment.status.lowercased() != "cancelled" &&
               appointment.status.lowercased() != "completed"
    }
    
    private func isBeforeToday(_ dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let appointmentDate = dateFormatter.date(from: dateString) else {
            return false
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return appointmentDate < today
    }
}

// View model for the detail view
class AppointmentDetailViewModel: ObservableObject {
    // Patient profile
    @Published var patientProfile: DoctorResponse.PatientProfile?
    @Published var isLoadingProfile = false
    @Published var profileError: String?
    
    // Vitals
    @Published var vitals: DoctorResponse.DocGetLatestPatientVitals?
    @Published var isLoadingVitals = false
    @Published var vitalsError: String?
    
    // Diagnosis
    @Published var diagnosis: DoctorResponse.DiagnosisResponse?
    @Published var isLoadingDiagnosis = false
    @Published var diagnosisError: String?
    
    // Prescription
    @Published var prescription: DoctorResponse.PrescriptionResponse?
    @Published var isLoadingPrescription = false
    @Published var prescriptionError: String?
    
    // Lab tests
    @Published var labTests: [DoctorResponse.RecommendedLabTest] = []
    @Published var isLoadingLabTests = false
    @Published var labTestsError: String?
    
    private let doctorServices = DoctorServices()
    
    func loadAllData(appointment: DoctorResponse.DocAppointment) {
        loadPatientProfile(patientId: String(appointment.patientId))
        loadPatientVitals(patientId: String(appointment.patientId))
        // For diagnosis and prescription, we would need the actual IDs
        // In a real implementation, we might need to make API calls to get these
        
        // Simulating diagnosis and prescription fetch
        // In a real implementation, replace with actual API calls
        fetchDiagnosis(appointmentId: appointment.appointmentId)
        fetchPrescription(appointmentId: appointment.appointmentId)
    }
    
    func loadPatientProfile(patientId: String) {
        isLoadingProfile = true
        profileError = nil
        
        Task {
            do {
                let profile = try await doctorServices.fetchPatientProfile(patientId: patientId)
                DispatchQueue.main.async {
                    self.patientProfile = profile
                    self.isLoadingProfile = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.profileError = error.localizedDescription
                    self.isLoadingProfile = false
                }
            }
        }
    }
    
    func loadPatientVitals(patientId: String) {
        isLoadingVitals = true
        vitalsError = nil
        
        Task {
            do {
                let fetchedVitals = try await doctorServices.fetchPatientLatestVitals(patientId: patientId)
                DispatchQueue.main.async {
                    self.vitals = fetchedVitals
                    self.isLoadingVitals = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.vitalsError = error.localizedDescription
                    self.isLoadingVitals = false
                }
            }
        }
    }
    
    func fetchDiagnosis(appointmentId: Int) {
        // In a real implementation, you would need an API endpoint to fetch diagnosis by appointment ID
        // This is a placeholder for demonstration purposes
        isLoadingDiagnosis = true
        diagnosisError = nil
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoadingDiagnosis = false
            
            // For demonstration, create a mock diagnosis response 50% of the time
            if Bool.random() {
                self.diagnosis = DoctorResponse.DiagnosisResponse(
                    message: "Diagnosis retrieved successfully",
                    diagnosisId: 123
                )
            } else {
                // No diagnosis available
                self.diagnosis = nil
            }
        }
    }
    
    func fetchPrescription(appointmentId: Int) {
        // In a real implementation, you would need an API endpoint to fetch prescription by appointment ID
        // This is a placeholder for demonstration purposes
        isLoadingPrescription = true
        prescriptionError = nil
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isLoadingPrescription = false
            
            // For demonstration, create a mock prescription response 60% of the time
            if Bool.random() && Bool.random() {
                self.prescription = DoctorResponse.PrescriptionResponse(
                    message: "Prescription retrieved successfully"
                )
            } else {
                // No prescription available
                self.prescription = nil
            }
        }
    }
}

// Tab selection component
struct TabSelectionView: View {
    @Binding var activeTab: AppointmentDetailView.DetailTab
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                TabButton(title: "Overview", systemImage: "doc.text", isActive: activeTab == .overview) {
                    activeTab = .overview
                }
                
                TabButton(title: "Diagnosis", systemImage: "stethoscope", isActive: activeTab == .diagnosis) {
                    activeTab = .diagnosis
                }
                
                TabButton(title: "Prescription", systemImage: "pills", isActive: activeTab == .prescription) {
                    activeTab = .prescription
                }
                
                TabButton(title: "Vitals", systemImage: "heart.text.square", isActive: activeTab == .vitals) {
                    activeTab = .vitals
                }
                
                TabButton(title: "Profile", systemImage: "person", isActive: activeTab == .profile) {
                    activeTab = .profile
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
}

// Tab button component
struct TabButton: View {
    let title: String
    let systemImage: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 18))
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(isActive ? .blue : .gray)
            .frame(height: 50)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isActive ? Color.blue.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isActive ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Appointment header card
struct AppointmentHeaderCard: View {
    let appointment: DoctorResponse.DocAppointment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Appointment #\(appointment.appointmentId)")
                        .font(.system(size: 18, weight: .bold))
                    
                    Text("\(formatDate(appointment.date)) • Slot \(appointment.slotId)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: appointment.status)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Doctor")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Staff ID: \(appointment.staffId)")
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Patient")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("ID: \(appointment.patientId)")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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
}

// Overview tab content
struct AppointmentOverviewView: View {
    let appointment: DoctorResponse.DocAppointment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView1(title: "Appointment Summary")
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(label: "Appointment ID", value: "\(appointment.appointmentId)")
                InfoRow(label: "Date", value: formatDate(appointment.date))
                InfoRow(label: "Time Slot", value: "Slot \(appointment.slotId)")
                InfoRow(label: "Staff ID", value: appointment.staffId)
                InfoRow(label: "Patient ID", value: "\(appointment.patientId)")
                InfoRow(label: "Status", value: appointment.status)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Timeline
            SectionHeaderView1(title: "Appointment Timeline")
            
            AppointmentTimelineView(status: appointment.status.lowercased())
        }
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
}

// Section header component
struct SectionHeaderView1: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
            
            Spacer()
        }
        .padding(.top, 8)
    }
}

// Info row component
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// Timeline component
struct AppointmentTimelineView: View {
    let status: String
    
    var body: some View {
        VStack(spacing: 0) {
            TimelineItem(
                title: "Appointment Scheduled",
                description: "Appointment has been booked",
                isCompleted: true,
                isLast: false
            )
            
            TimelineItem(
                title: "Check-in",
                description: "Patient checked in",
                isCompleted: ["upcoming", "scheduled"].contains(status) ? false : true,
                isLast: false
            )
            
            TimelineItem(
                title: "Consultation",
                description: "Doctor consultation",
                isCompleted: status == "completed",
                isLast: false
            )
            
            TimelineItem(
                title: "Completed",
                description: "Appointment finished",
                isCompleted: status == "completed",
                isLast: true
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Timeline item component
struct TimelineItem: View {
    let title: String
    let description: String
    let isCompleted: Bool
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(isCompleted ? Color.green : Color.gray.opacity(0.5))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: isCompleted ? "checkmark" : "circle")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? Color.green : Color.gray.opacity(0.5))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(height: isLast ? 20 : 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isCompleted ? .primary : .secondary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, isLast ? 0 : 24)
            
            Spacer()
        }
    }
}

// Diagnosis detail view
struct DiagnosisDetailView: View {
    let diagnosis: DoctorResponse.DiagnosisResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView1(title: "Diagnosis Information")
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(label: "Diagnosis ID", value: "\(diagnosis.diagnosisId)")
                InfoRow(label: "Status", value: "Completed")
                InfoRow(label: "Notes", value: "Diagnosis was completed successfully. The details would be displayed here in a real implementation.")
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // In a real implementation, you would display the actual diagnosis details here
            // This is just a placeholder
            Text("Note: This is a simulated diagnosis view. In a real implementation, the complete diagnosis information would be displayed here.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

// Prescription detail view
struct PrescriptionDetailView: View {
    let prescription: DoctorResponse.PrescriptionResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView1(title: "Prescription Details")
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(label: "Status", value: "Issued")
                InfoRow(label: "Message", value: prescription.message)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Medications would be displayed here
            SectionHeaderView1(title: "Medications")
            
            VStack(spacing: 12) {
                // Sample medications - in a real implementation, these would come from the API
                MedicationRow(
                    name: "Sample Medication 1",
                    dosage: "10mg",
                    frequency: "Once daily",
                    duration: "7 days"
                )
                
                MedicationRow(
                    name: "Sample Medication 2",
                    dosage: "500mg",
                    frequency: "Twice daily",
                    duration: "5 days"
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // In a real implementation, you would display the actual prescription details here
            // This is just a placeholder
            Text("Note: This is a simulated prescription view. In a real implementation, the complete prescription information would be displayed here.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

// Medication row component
struct MedicationRow: View {
    let name: String
    let dosage: String
    let frequency: String
    let duration: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.system(size: 16, weight: .medium))
            
            HStack {
                Label {
                    Text(dosage)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "pills")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Label {
                    Text(frequency)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "clock")
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Label {
                    Text(duration)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(.orange)
                }
            }
            
            Divider()
        }
    }
}

// Vitals detail view
struct VitalsDetailView: View {
    let vitals: DoctorResponse.DocGetLatestPatientVitals
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView1(title: "Patient Vitals")
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(label: "Recorded", value: formatDate(vitals.createdAt))
                InfoRow(label: "Appointment", value: "#\(vitals.appointmentId)")
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Vitals grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                VitalCard(
                    title: "Height",
                    value: String(format: "%.1f cm", vitals.patientHeight),
                    iconName: "ruler",
                    color: .blue
                )
                
                VitalCard(
                    title: "Weight",
                    value: String(format: "%.1f kg", vitals.patientWeight),
                    iconName: "scalemass",
                    color: .green
                )
                
                VitalCard(
                    title: "Heart Rate",
                    value: "\(vitals.patientHeartrate) bpm",
                    iconName: "heart",
                    color: .red
                )
                
                VitalCard(
                    title: "SpO2",
                    value: String(format: "%.1f%%", vitals.patientSpo2),
                    iconName: "lungs",
                    color: .purple
                )
                
                VitalCard(
                    title: "Temperature",
                    value: String(format: "%.1f °C", vitals.patientTemperature),
                    iconName: "thermometer",
                    color: .orange
                )
                
                VitalCard(
                    title: "BMI",
                    value: String(format: "%.1f", calculateBMI(height: vitals.patientHeight, weight: vitals.patientWeight)),
                    iconName: "figure.mixed.cardio",
                    color: .teal
                )
            }
        }
    }
    
    private func calculateBMI(height: Double, weight: Double) -> Double {
        // Height in meters (convert from cm)
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Adjust format based on your API
        
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .short
        return outputFormatter.string(from: date)
    }
}

// Vital card component
struct VitalCard: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                )
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Patient profile view
struct PatientProfileView: View {
    let profile: DoctorResponse.PatientProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView1(title: "Patient Information")
            
            // Profile header
            HStack {
                ProfileImageView(imageURL: profile.profilePhoto)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.patientName)
                        .font(.system(size: 20, weight: .bold))
                    
                    Text("Patient #\(profile.patientId)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label {
                            Text(formattedAge(dob: profile.dob))
                                .font(.system(size: 12))
                        } icon: {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Label {
                            Text(profile.gender ? "Male" : "Female")
                                .font(.system(size: 12))
                        } icon: {
                            Image(systemName: profile.gender ? "person" : "person.2")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Label {
                            Text(profile.bloodGroup)
                                .font(.system(size: 12))
                        } icon: {
                            Image(systemName: "drop")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Contact information
            SectionHeaderView1(title: "Contact Information")
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(label: "Email", value: profile.patientEmail)
                InfoRow(label: "Mobile", value: profile.patientMobile)
                if let address = profile.address {
                    InfoRow(label: "Address", value: address)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    private func formattedAge(dob: String) -> String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    guard let birthDate = dateFormatter.date(from: dob) else {
                        return "Unknown"
                    }
                    
                    let calendar = Calendar.current
                    let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
                    
                    if let age = ageComponents.year {
                        return "\(age) years"
                    } else {
                        return "Unknown"
                    }
                }
            }

            // Profile image component
            struct ProfileImageView: View {
                let imageURL: String?
                
                var body: some View {
                    ZStack {
                        if let urlString = imageURL, let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.blue)
                                )
                        }
                    }
                }
            }

            // Loading state view
            struct LoadingView: View {
                let message: String
                
                var body: some View {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text(message)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }

            // Empty state view
//            struct EmptyStateView: View {
//                let icon: String
//                let title: String
//                let message: String
//                
//                var body: some View {
//                    VStack(spacing: 16) {
//                        Image(systemName: icon)
//                            .font(.system(size: 40))
//                            .foregroundColor(.gray)
//                        
//                        Text(title)
//                            .font(.system(size: 18, weight: .semibold))
//                        
//                        Text(message)
//                            .font(.system(size: 14))
//                            .foregroundColor(.secondary)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal)
//                    }
//                    .padding(.vertical, 40)
//                    .frame(maxWidth: .infinity)
//                    .background(Color(.systemBackground))
//                    .cornerRadius(12)
//                }
//            }

            // Extension to the AppointmentData struct
//            struct AppointmentData {
//                let doctorName: String
//                let specialty: String
//                let date: String
//                let time: String
//                let notes: String
//            }

            // MARK: - Integration with existing code

            // This updates the existing AppointmentRow to navigate to the detail view
            struct AppointmentRowWithNavigation: View {
                let appointment: DoctorResponse.DocAppointment
                @State private var showDetailView = false
                
                var body: some View {
                    Button(action: {
                        showDetailView = true
                    }) {
                        AppointmentRow(appointment: appointment)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showDetailView) {
                        AppointmentDetailView(appointment: appointment)
                    }
                }
            }

            // Extension for the DoctorAppointmentsView to use the new row type
            extension DoctorAppointmentsView {
                // Update this in the ForEach within the LazyVStack
                func updatedAppointmentsList() -> some View {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredAppointments) { appointment in
                            AppointmentRowWithNavigation(appointment: appointment)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }

            // MARK: - Helper Extensions

            extension View {
                func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
                    clipShape(RoundedCorner(radius: radius, corners: corners))
                }
            }

            struct RoundedCorner: Shape {
                var radius: CGFloat = .infinity
                var corners: UIRectCorner = .allCorners

                func path(in rect: CGRect) -> Path {
                    let path = UIBezierPath(
                        roundedRect: rect,
                        byRoundingCorners: corners,
                        cornerRadii: CGSize(width: radius, height: radius)
                    )
                    return Path(path.cgPath)
                }
            }
