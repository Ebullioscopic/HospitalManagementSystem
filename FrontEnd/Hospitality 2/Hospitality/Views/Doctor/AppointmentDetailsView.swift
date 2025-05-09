import SwiftUI

struct AppointmentDetailsView: View {
    @StateObject private var viewModel = DoctorViewModel()
    let appointment: DoctorResponse.DocAppointment
    @State private var showingVitalsForm = false
    @State private var currentDate = Date()
    @State private var currentUser = "swatiswapna"
    @Environment(\.colorScheme) var colorScheme
    
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
                        showingVitalsForm: $showingVitalsForm,
                        isAppointmentCompleted: appointment.status.lowercased() == "completed"
                    )
                }
                .padding()
            }
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
    let isAppointmentCompleted: Bool
    var viewModel = DoctorViewModel()
    
    
    var body: some View {
        if !isAppointmentCompleted {
            NavigationLink(destination: VitalsFormView(appointmentId: appointmentId, viewModel: viewModel)) {
                ActionButtonContent(
                    icon: "play.circle.fill",
                    title: "Start Appointment",
                    color: .green
                )
                .padding(.top, 16)
            }
        }
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


// MARK: - Vitals Form

import SwiftUI

struct VitalsFormView: View {
    let appointmentId: Int
    @ObservedObject var viewModel: DoctorViewModel
    @Environment(\.colorScheme) var colorScheme
    
    // Input fields with validation wrappers
    @State private var heightInput = ValidatedInput(
        range: 50...250,
        placeholder: "Height (cm)",
        icon: "ruler",
        iconColor: Color(hex: "0077CC")
    )
    
    @State private var weightInput = ValidatedInput(
        range: 20...300,
        placeholder: "Weight (kg)",
        icon: "scalemass",
        iconColor: Color(hex: "0077CC")
    )
    
    @State private var heartRateInput = ValidatedInput(
        range: 40...200,
        placeholder: "Heart Rate (bpm)",
        icon: "heart.fill",
        iconColor: Color.red.opacity(0.6)
    )
    
    @State private var spo2Input = ValidatedInput(
        range: 0...100,
        placeholder: "SPO2 (%)",
        icon: "waveform.path.ecg",
        iconColor: Color(hex: "0077CC")
    )
    
    @State private var temperatureInput = ValidatedInput(
        range: 90...108,
        placeholder: "Temperature (°F)",
        icon: "thermometer",
        iconColor: Color(hex: "F5A623")
    )
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Color Scheme
    private let primaryColor = Color(hex: "0077CC")
    private let secondaryColor = Color(hex: "00A3A3")
    private let accentColor = Color(hex: "F5A623")
    
    // Navigation state
    @State private var navigateToConsultation = false
    
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
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        // Vital signs form
                        VStack(spacing: 16) {
                            // Each vital sign input with consistent styling
                            VitalFieldView(input: $heightInput)
                            VitalFieldView(input: $weightInput)
                            VitalFieldView(input: $heartRateInput)
                            VitalFieldView(input: $spo2Input)
                            VitalFieldView(input: $temperatureInput)
                        }
                        .padding(.horizontal)
                        
                        // Status messages
                        if viewModel.isLoading || !viewModel.enterVitalsMessage.isEmpty || viewModel.errorMessage != nil {
                            VStack {
                                if viewModel.isLoading {
                                    HStack {
                                        Spacer()
                                        ProgressView("Saving vitals...")
                                            .progressViewStyle(CircularProgressViewStyle())
                                        Spacer()
                                    }
                                } else if !viewModel.enterVitalsMessage.isEmpty {
                                    StatusView(
                                        icon: "checkmark.circle.fill",
                                        color: .green,
                                        message: viewModel.enterVitalsMessage
                                    )
                                } else if let errorMessage = viewModel.errorMessage {
                                    StatusView(
                                        icon: "exclamationmark.triangle.fill",
                                        color: .red,
                                        message: errorMessage
                                    )
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(colorScheme == .dark ?
                                        Color(UIColor.secondarySystemBackground) :
                                        Color(UIColor.tertiarySystemBackground)
                                    )
                            )
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.bottom, 80)
                }
                
                // Fixed action buttons at bottom
                VStack(spacing: 12) {
                    // Save Vitals button
                    Button(action: submitVitals) {
                        HStack {
                            Text("Save Vitals")
                                .fontWeight(.semibold)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.leading, 5)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isFormValid ? primaryColor : Color.gray)
                                .shadow(color: isFormValid ? primaryColor.opacity(0.3) : Color.clear, radius: 4, y: 2)
                        )
                        .foregroundColor(.white)
                    }
                    .disabled(viewModel.isLoading || !isFormValid)
                    
                    // Proceed to Consultation button (shown only after successful save)
                    if !viewModel.enterVitalsMessage.isEmpty && viewModel.errorMessage == nil {
                        NavigationLink(
                            destination: DoctorConsultationView(appointmentId: appointmentId),
                            isActive: $navigateToConsultation
                        ) {
                            Button(action: {
                                navigateToConsultation = true
                            }) {
                                HStack {
                                    Text("Proceed to Consultation")
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.right")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(secondaryColor)
                                        .shadow(color: secondaryColor.opacity(0.3), radius: 4, y: 2)
                                )
                                .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(
                    Rectangle()
                        .fill(colorScheme == .dark ? Color(hex: "101420").opacity(0.9) : Color(hex: "F7FAFF").opacity(0.9))
                        .blur(radius: 3)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, y: -5)
                )
            }
        }
        .navigationTitle("Enter Vitals")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Properties
    
    // Form validation
    private var isFormValid: Bool {
        heightInput.isValid &&
        weightInput.isValid &&
        heartRateInput.isValid &&
        spo2Input.isValid &&
        temperatureInput.isValid
    }
    
    // MARK: - Methods
    
    private func submitVitals() {
        guard isFormValid else {
            viewModel.errorMessage = "Please check the details of your entered vitals."
            return
        }
        
        guard let height = Double(heightInput.text),
              let weight = Double(weightInput.text),
              let heartRate = Int(heartRateInput.text),
              let spo2 = Double(spo2Input.text),
              let temperature = Double(temperatureInput.text) else {
            viewModel.errorMessage = "Invalid input values"
            return
        }
        
        // Call the API method
        viewModel.enterVitals(
            appointmentId: appointmentId,
            height: height,
            weight: weight,
            heartrate: heartRate,
            spo2: spo2,
            temperature: temperature
        )
    }
}

// MARK: - Helper Structs

/// Model for validated input fields
struct ValidatedInput {
    var text: String = ""
    var range: ClosedRange<Double>
    var placeholder: String
    var icon: String
    var iconColor: Color
    var showValidation: Bool = false
    
    var isValid: Bool {
        guard !text.isEmpty else { return false }
        guard let value = Double(text) else { return false }
        return range.contains(value)
    }
    
    var rangeText: String {
        "\(Int(range.lowerBound))-\(Int(range.upperBound))"
    }
    
    var validationMessage: String? {
        guard showValidation, !text.isEmpty else { return nil }
        
        if let value = Double(text) {
            if value < range.lowerBound {
                return "Value too low (min: \(Int(range.lowerBound)))"
            } else if value > range.upperBound {
                return "Value too high (max: \(Int(range.upperBound)))"
            }
        } else {
            return "Please enter a valid number"
        }
        
        return nil
    }
}

/// View for each vital sign input field
struct VitalFieldView: View {
    @Binding var input: ValidatedInput
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Field label
            Text(input.placeholder)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            // Input field
            HStack(spacing: 12) {
                Image(systemName: input.icon)
                    .foregroundColor(input.iconColor)
                    .font(.system(size: 18))
                    .frame(width: 24)
                
                ZStack(alignment: .leading) {
                    // Placeholder
                    if input.text.isEmpty {
                        Text("Range: \(input.rangeText)")
                            .foregroundColor(.secondary.opacity(0.7))
                            .font(.subheadline)
                    }
                    
                    // Text field
                    TextField("", text: $input.text)
                        .keyboardType(.decimalPad)
                        .onChange(of: input.text) { _ in
                            // Only show validation after user begins typing
                            input.showValidation = true
                        }
                }
                
                // Validation icon
                if input.showValidation {
                    if !input.text.isEmpty {
                        Image(systemName: input.isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundColor(input.isValid ? .green : .red)
                            .font(.system(size: 16))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        input.showValidation && !input.text.isEmpty ?
                            (input.isValid ? Color.green.opacity(0.4) : Color.red.opacity(0.5)) :
                            Color.gray.opacity(0.2),
                        lineWidth: 1
                    )
            )
            
            // Validation message
            if let message = input.validationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 36)
                    .transition(.opacity)
            }
        }
    }
}

/// Status message view
struct StatusView: View {
    let icon: String
    let color: Color
    let message: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}
