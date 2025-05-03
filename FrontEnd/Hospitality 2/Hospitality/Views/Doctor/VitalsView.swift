//import SwiftUI
//
//struct VitalsFormView: View {
//    let appointmentId: Int
//    @ObservedObject var viewModel: DoctorViewModel
//    
//    @State private var height: String = ""
//    @State private var weight: String = ""
//    @State private var heartRate: String = ""
//    @State private var spo2: String = ""
//    @State private var temperature: String = ""
//    
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Patient Vitals")) {
//                    HStack {
//                        Image(systemName: "ruler")
//                            .foregroundColor(.blue)
//                            .frame(width: 30)
//                        TextField("Height (cm)", text: $height)
//                            .keyboardType(.decimalPad)
//                    }
//                    
//                    HStack {
//                        Image(systemName: "scalemass")
//                            .foregroundColor(.blue)
//                            .frame(width: 30)
//                        TextField("Weight (kg)", text: $weight)
//                            .keyboardType(.decimalPad)
//                    }
//                    
//                    HStack {
//                        Image(systemName: "heart")
//                            .foregroundColor(.red)
//                            .frame(width: 30)
//                        TextField("Heart Rate (bpm)", text: $heartRate)
//                            .keyboardType(.numberPad)
//                    }
//                    
//                    HStack {
//                        Image(systemName: "lungs")
//                            .foregroundColor(.blue)
//                            .frame(width: 30)
//                        TextField("SPO2 (%)", text: $spo2)
//                            .keyboardType(.decimalPad)
//                    }
//                    
//                    HStack {
//                        Image(systemName: "thermometer")
//                            .foregroundColor(.orange)
//                            .frame(width: 30)
//                        TextField("Temperature (°C)", text: $temperature)
//                            .keyboardType(.decimalPad)
//                    }
//                }
//                
//                if viewModel.isLoading {
//                    HStack {
//                        Spacer()
//                        ProgressView("Saving...")
//                        Spacer()
//                    }
//                } else if !viewModel.enterVitalsMessage.isEmpty {
//                    Section {
//                        HStack {
//                            Image(systemName: "checkmark.circle.fill")
//                                .foregroundColor(.green)
//                            Text(viewModel.enterVitalsMessage)
//                                .foregroundColor(.green)
//                            Spacer()
//                        }
//                    }
//                } else if let errorMessage = viewModel.errorMessage {
//                    Section {
//                        HStack {
//                            Image(systemName: "exclamationmark.triangle.fill")
//                                .foregroundColor(.red)
//                            Text(errorMessage)
//                                .foregroundColor(.red)
//                            Spacer()
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Enter Vitals")
//            .toolbar {
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Save") {
//                        submitVitals()
//                    }
//                    .disabled(viewModel.isLoading || !isFormValid())
//                }
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                    .disabled(viewModel.isLoading)
//                }
//            }
//        }
//    }
//    
//    private func isFormValid() -> Bool {
//        return !height.isEmpty && !weight.isEmpty && !heartRate.isEmpty &&
//               !spo2.isEmpty && !temperature.isEmpty
//    }
//    
//    private func submitVitals() {
//        let vitals: [String: Any] = [
//            "patient_height": Double(height) ?? 0.0,
//            "patient_weight": Double(weight) ?? 0.0,
//            "patient_heartrate": Int(heartRate) ?? 0,
//            "patient_spo2": Double(spo2) ?? 0.0,
//            "patient_temperature": Double(temperature) ?? 0.0
//        ]
//        
//        viewModel.enterVitals(appointmentId: appointmentId, vitals: vitals)
//        
//        // Dismiss after successful submission
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            if !viewModel.enterVitalsMessage.isEmpty && viewModel.errorMessage == nil {
//                dismiss()
//            }
//        }
//    }
//}
//
import SwiftUI
struct ConsultationView: View {
    let appointmentId: Int
    let patientId: Int
    
    @State private var diagnosis: String = ""
    @State private var prescription: String = ""
    @State private var followUpNotes: String = ""
    @State private var recommendedTests: String = ""
    @State private var isSubmitting = false
    @State private var diagnosisMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Patient ID: \(patientId)")
                    .font(.headline)
                
                // Diagnosis section
                ConsultationSectionView(
                    title: "Diagnosis",
                    icon: "stethoscope",
                    text: $diagnosis,
                    placeholder: "Enter diagnosis details..."
                )
                
                // Prescription section
                ConsultationSectionView(
                    title: "Prescription",
                    icon: "pills",
                    text: $prescription,
                    placeholder: "Enter prescription details..."
                )
                
                // Tests section
                ConsultationSectionView(
                    title: "Recommended Tests",
                    icon: "cross",
                    text: $recommendedTests,
                    placeholder: "Enter recommended tests..."
                )
                
                // Follow-up section
                ConsultationSectionView(
                    title: "Follow-up Notes",
                    icon: "calendar.badge.clock",
                    text: $followUpNotes,
                    placeholder: "Enter follow-up instructions..."
                )
                
                // Submit button
                Button(action: submitConsultation) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 10)
                        } else {
                            Image(systemName: "paperplane.fill")
                                .padding(.trailing, 10)
                        }
                        Text("Submit Consultation")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isSubmitting || diagnosis.isEmpty)
                
                // Success message
                if !diagnosisMessage.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(diagnosisMessage)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Consultation")
    }
    
    private func submitConsultation() {
        // Implement the consultation submission here
        isSubmitting = true
        
        // Simulating network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            diagnosisMessage = "Consultation submitted successfully"
            isSubmitting = false
        }
    }
}

struct ConsultationSectionView: View {
    let title: String
    let icon: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Label(title, systemImage: icon)
                    .font(.headline)
                
                TextEditor(text: $text)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .overlay(
                        Group {
                            if text.isEmpty {
                                HStack {
                                    Text(placeholder)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 12)
                                    Spacer()
                                }
                                .padding(.top, 16)
                            }
                        }
                    )
            }
        }
    }
}

