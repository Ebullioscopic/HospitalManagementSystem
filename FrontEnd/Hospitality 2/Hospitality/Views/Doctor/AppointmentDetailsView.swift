import SwiftUI

struct AppointmentDetailsView: View {
    @StateObject private var viewModel = DoctorViewModel()
    let appointment: DoctorResponse.DocAppointment
    @State private var showingVitalsForm = false
    @State private var currentDate = Date()
    @State private var currentUser = "swatiswapna"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Appointment header with status
                HStack {
                    VStack(alignment: .leading) {
                        Text("Appointment #\(appointment.appointmentId)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(formattedDate(appointment.date))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: appointment.status)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Patient information section
                PatientInfoSection(
                    patientId: appointment.patientId,
                    viewModel: viewModel
                )
                
                // Appointment details section
                AppointmentInfoSection(appointment: appointment)
                
                // Vitals section (if available)
                if let vitals = viewModel.patientVitals {
                    VitalsSection(vitals: vitals)
                }
                
                // Action buttons
                ActionButtonsSection(
                    appointmentId: appointment.appointmentId,
                    patientId: appointment.patientId,
                    showingVitalsForm: $showingVitalsForm
                )
            }
            .padding()
        }
        .navigationTitle("Appointment Details")
        .onAppear {
            // Set specific current date and user
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let specificDate = dateFormatter.date(from: "2025-04-27 20:17:50") {
                currentDate = specificDate
            }
            
            // Fetch patient data
            viewModel.fetchPatientProfile(patientId: String(appointment.patientId))
            viewModel.fetchPatientVitals(patientId: String(appointment.patientId))
        }
        .sheet(isPresented: $showingVitalsForm) {
            VitalsFormView(appointmentId: appointment.appointmentId, viewModel: viewModel)
        }
    }
    
    private func formattedDate(_ dateString: String) -> String {
        // You could implement proper date formatting here
        return dateString
    }
}

// MARK: - Component Views

struct PatientInfoSection: View {
    let patientId: Int
    @ObservedObject var viewModel: DoctorViewModel
    
    var body: some View {
        GroupBox(label: SectionHeader(title: "Patient Information", icon: "person")) {
            if let patientProfile = viewModel.patientProfile {
                // If patient profile is loaded, show the information
                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(label: "Patient ID", value: "\(patientId)")
                    DetailRow(label: "Name", value: patientProfile.patientName)
                    DetailRow(label: "Mobile", value: patientProfile.patientMobile)
                    DetailRow(label: "Email", value: patientProfile.patientEmail)
                    DetailRow(label: "Date of Birth", value: patientProfile.dob)
                    DetailRow(label: "Gender", value: patientProfile.gender ? "Male" : "Female")
                    DetailRow(label: "Blood Group", value: patientProfile.bloodGroup)
                    
                    if let address = patientProfile.address {
                        DetailRow(label: "Address", value: address)
                    }
                }
            } else if viewModel.isLoading {
                // Show loading indicator if data is being fetched
                HStack {
                    Spacer()
                    ProgressView("Loading patient information...")
                    Spacer()
                }
                .padding()
            } else {
                // Show a button to fetch patient information
                VStack {
                    Text("Patient details not loaded")
                        .foregroundColor(.secondary)
                    
                    Button("Load Patient Details") {
                        viewModel.fetchPatientProfile(patientId: String(patientId))
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 8)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct AppointmentInfoSection: View {
    let appointment: DoctorResponse.DocAppointment
    
    var body: some View {
        GroupBox(label: SectionHeader(title: "Appointment Details", icon: "calendar")) {
            VStack(alignment: .leading, spacing: 12) {
                DetailRow(label: "Appointment ID", value: "\(appointment.appointmentId)")
                DetailRow(label: "Date", value: appointment.date)
                DetailRow(label: "Staff ID", value: appointment.staffId)
                DetailRow(label: "Slot ID", value: "\(appointment.slotId)")
                DetailRow(label: "Status", value: appointment.status)
            }
        }
    }
}

struct VitalsSection: View {
    let vitals: DoctorResponse.DocGetLatestPatientVitals
    
    var body: some View {
        GroupBox(label: SectionHeader(title: "Latest Vitals", icon: "heart.text.square")) {
            VStack(alignment: .leading, spacing: 12) {
                DetailRow(label: "Height", value: "\(vitals.patientHeight) cm")
                DetailRow(label: "Weight", value: "\(vitals.patientWeight) kg")
                DetailRow(label: "Heart Rate", value: "\(vitals.patientHeartrate) bpm")
                DetailRow(label: "SPO2", value: "\(vitals.patientSpo2) %")
                DetailRow(label: "Temperature", value: "\(vitals.patientTemperature) °C")
                DetailRow(label: "Recorded", value: vitals.createdAt)
                DetailRow(label: "Appointment ID", value: "\(vitals.appointmentId)")
            }
        }
    }
}

struct ActionButtonsSection: View {
    let appointmentId: Int
    let patientId: Int
    @Binding var showingVitalsForm: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                showingVitalsForm = true
            }) {
                ActionButtonContent(
                    icon: "heart.text.square",
                    title: "Enter Vitals",
                    color: .pink
                )
            }
            
            NavigationLink(destination: ConsultationView(
                appointmentId: appointmentId,
                patientId: patientId
            )) {
                ActionButtonContent(
                    icon: "stethoscope",
                    title: "Diagnose",
                    color: .blue
                )
            }
        }
        .padding(.top, 16)
    }
}

// MARK: - Helper Views

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        Label(title, systemImage: icon)
            .font(.headline)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}

struct ActionButtonContent: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(color.opacity(0.1))
                .cornerRadius(15)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Supporting Components

//struct StatusBadge: View {
//    let status: String
//    
//    var body: some View {
//        Text(status)
//            .font(.caption)
//            .padding(.horizontal, 8)
//            .padding(.vertical, 4)
//            .background(getStatusColor(status))
//            .foregroundColor(.white)
//            .cornerRadius(8)
//    }
//    
//    private func getStatusColor(_ status: String) -> Color {
//        switch status.lowercased() {
//        case "completed":
//            return .green
//        case "scheduled":
//            return .blue
//        case "cancelled":
//            return .red
//        default:
//            return .gray
//        }
//    }
//}

// MARK: - Vitals Form

struct VitalsFormView: View {
    let appointmentId: Int
    @ObservedObject var viewModel: DoctorViewModel
    
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var heartRate: String = ""
    @State private var spo2: String = ""
    @State private var temperature: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Patient Vitals")) {
                    HStack {
                        Image(systemName: "ruler")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        TextField("Height (cm)", text: $height)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Image(systemName: "scalemass")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        TextField("Weight (kg)", text: $weight)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Image(systemName: "heart")
                            .foregroundColor(.red)
                            .frame(width: 30)
                        TextField("Heart Rate (bpm)", text: $heartRate)
                            .keyboardType(.numberPad)
                    }
                    
                    HStack {
                        Image(systemName: "lungs")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        TextField("SPO2 (%)", text: $spo2)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Image(systemName: "thermometer")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        TextField("Temperature (°C)", text: $temperature)
                            .keyboardType(.decimalPad)
                    }
                }
                
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Saving...")
                        Spacer()
                    }
                } else if !viewModel.enterVitalsMessage.isEmpty {
                    Section {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(viewModel.enterVitalsMessage)
                                .foregroundColor(.green)
                            Spacer()
                        }
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Enter Vitals")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        submitVitals()
                    }
                    .disabled(viewModel.isLoading || !isFormValid())
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
    
    private func isFormValid() -> Bool {
        return !height.isEmpty && !weight.isEmpty && !heartRate.isEmpty &&
               !spo2.isEmpty && !temperature.isEmpty
    }
    
    private func submitVitals() {
        guard let heightValue = Double(height),
              let weightValue = Double(weight),
              let heartrateValue = Int(heartRate),
              let spo2Value = Double(spo2),
              let temperatureValue = Double(temperature) else {
            // Handle invalid input
            viewModel.errorMessage = "Please enter valid numbers for all fields"
            return
        }
        
        // Call the updated method signature
        viewModel.enterVitals(
            appointmentId: appointmentId,
            height: heightValue,
            weight: weightValue,
            heartrate: heartrateValue,
            spo2: spo2Value,
            temperature: temperatureValue
        )
        
        // Dismiss after successful submission
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if !viewModel.enterVitalsMessage.isEmpty && viewModel.errorMessage == nil {
                dismiss()
            }
        }
    }
}
