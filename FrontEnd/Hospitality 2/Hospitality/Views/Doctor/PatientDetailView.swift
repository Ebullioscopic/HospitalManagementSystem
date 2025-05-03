////
////  PatientDetailView.swift
////  Hospitality
////
////  Created by admin64 on 27/04/25.
////
//
//import SwiftUI
//
//// MARK: - Patient Detail View
//struct PatientDetailView: View {
//    @EnvironmentObject var dataStore: HospitalDataStore
//    let patient: Patient
//    
//    // Mock patient vitals for demonstration
//    private var mockVitals: PatientVitals {
//        PatientVitals(
//            id: "v1",
//            patientId: patient.id,
//            patientHeight: 175.0,
//            patientWeight: 72.5,
//            patientHeartrate: 78,
//            patientSpo2: 98,
//            patientTemperature: 36.8,
//            appointmentId: "a1"
//        )
//    }
//    
//    // Mock prescription structure based on new model
//    private var mockPrescriptions: [(medicine: Medicine, prescribedMedicine: PrescribedMedicine)] {
//        [
//            (
//                Medicine(medicineID: "m1", medicineName: "Ibuprofen", medicineRemarks: "Take with food"),
//                PrescribedMedicine(
//                    prescribedMedicineID: "pm1",
//                    prescriptionID: "pr1",
//                    medicineID: "m1",
//                    medicineDosage: ["morning": "200mg", "evening": "200mg"],
//                    fastingRequired: "No"
//                )
//            ),
//            (
//                Medicine(medicineID: "m2", medicineName: "Amoxicillin", medicineRemarks: "Complete full course"),
//                PrescribedMedicine(
//                    prescribedMedicineID: "pm2",
//                    prescriptionID: "pr1",
//                    medicineID: "m2",
//                    medicineDosage: ["morning": "500mg", "afternoon": "500mg", "evening": "500mg"],
//                    fastingRequired: "Yes"
//                )
//            )
//        ]
//    }
//    
//    // Mock lab tests for demonstration
//    private var mockLabTests: [LabTest] {
//        [
//            LabTest(
//                id: "lt1",
//                labId: "l1",
//                testDateTime: Date().addingTimeInterval(-86400),
//                testResult: ["WBC": "6.5", "RBC": "4.7", "HGB": "14.2"],
//                testType: "Complete Blood Count",
//                appointmentId: "a1",
//                tranId: "t1"
//            )
//        ]
//    }
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                patientHeader
//                basicInfoSection
//                medicalInfoSection
//                vitalsSection
//                prescriptionsSection
//                labTestsSection
//                
//                NavigationLink(destination: VitalsView()) {
//                    Text("Start Appointment")
//                        .fontWeight(.semibold)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.accentColor)
//                        .foregroundColor(.white)
//                        .cornerRadius(12)
//                        .shadow(radius: 3)
//                }
//                .padding(.top)
//            }
//            .padding()
//        }
//        .navigationTitle("Appointment Details")
//        .navigationBarTitleDisplayMode(.inline)
////        .toolbar {
////            ToolbarItem(placement: .navigationBarTrailing) {
////                Button(action: {}) {
////                    Image(systemName: "square.and.pencil")
////                }
////            }
////        }
//    }
//    
//    // MARK: - Subviews
//    
//    private var patientHeader: some View {
//        HStack(alignment: .top, spacing: 20) {
//            Circle()
//                .fill(Color.blue.opacity(0.2))
//                .frame(width: 80, height: 80)
//                .overlay(
//                    Text(String(patient.patientName.prefix(1)))
//                        .font(.title)
//                        .bold()
//                )
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(patient.patientName)
//                    .font(.title2)
//                    .bold()
//                
//                Text("\(patient.patientGender) • \(ageFromDOB(patient.patientDob)) years")
//                    .foregroundColor(.secondary)
//                
//                if let bloodGroup = patient.patientBloodGroup {
//                    Text("Blood Group: \(bloodGroup)")
//                        .foregroundColor(.secondary)
//                }
//            }
//            
//            Spacer()
//        }
//    }
//    
//    private var basicInfoSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            SectionHeader(title: "Basic Information", icon: "info.circle")
//            
//            InfoRow(label: "Date of Birth", value: patient.patientDob.formatted(date: .long, time: .omitted))
//            InfoRow(label: "Mobile", value: patient.patientMobile)
//            
//            if let email = patient.patientEmail {
//                InfoRow(label: "Email", value: email)
//            }
//            
//            // Static mock address (since PatientDetails is not connected here yet)
//           // InfoRow(label: "Address", value: "123 Medical St, Health City, HC 12345")
//            
////            if let remark = patient.patientRemark {
////                InfoRow(label: "Remarks", value: remark)
////            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(10)
//    }
//    
//    private var medicalInfoSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            SectionHeader(title: "Medical Information", icon: "heart.text.square")
//            InfoRow(label: "Allergies", value: "Penicillin, Peanuts")
//            InfoRow(label: "Chronic Conditions", value: "Hypertension (controlled)")
//            InfoRow(label: "Last Visit", value: "2 weeks ago")
//            InfoRow(label: "Next Appointment", value: "Not scheduled")
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(10)
//    }
//    
//    private var vitalsSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            SectionHeader(title: "Latest Vitals", icon: "waveform.path.ecg")
//            
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("Height")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    Text("\(mockVitals.patientHeight, specifier: "%.1f") cm")
//                        .font(.headline)
//                }
//                Spacer()
//                VStack(alignment: .leading) {
//                    Text("Weight")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    Text("\(mockVitals.patientWeight, specifier: "%.1f") kg")
//                        .font(.headline)
//                }
//                Spacer()
//                VStack(alignment: .leading) {
//                    Text("BMI")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    Text("\(calculateBMI(height: mockVitals.patientHeight, weight: mockVitals.patientWeight), specifier: "%.1f")")
//                        .font(.headline)
//                }
//            }
//            
//            Divider()
//            
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("Heart Rate")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    Text("\(mockVitals.patientHeartrate) bpm")
//                        .font(.headline)
//                }
//                Spacer()
//                VStack(alignment: .leading) {
//                    Text("SpO₂")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    Text("\(mockVitals.patientSpo2)%")
//                        .font(.headline)
//                }
//                Spacer()
//                VStack(alignment: .leading) {
//                    Text("Temp")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    Text("\(mockVitals.patientTemperature, specifier: "%.1f")°C")
//                        .font(.headline)
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(10)
//    }
//    
//    private var prescriptionsSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            SectionHeader(title: "Current Prescriptions", icon: "pills")
//            
//            if mockPrescriptions.isEmpty {
//                EmptyStateView(message: "No current prescriptions", icon: "pills.fill")
//            } else {
//                ForEach(mockPrescriptions, id: \.prescribedMedicine.prescribedMedicineID) { item in
//                    PrescriptionCard(medicine: item.medicine, prescribedMedicine: item.prescribedMedicine)
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(10)
//    }
//    
//    private var labTestsSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            SectionHeader(title: "Recent Lab Tests", icon: "testtube.2")
//            
//            if mockLabTests.isEmpty {
//                EmptyStateView(message: "No recent lab tests", icon: "testtube.2.fill")
//            } else {
//                ForEach(mockLabTests) { test in
//                    LabTestCard(test: test)
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(10)
//    }
//    
//    // MARK: - Helper Functions
//    
//    private func ageFromDOB(_ dob: Date) -> Int {
//        let calendar = Calendar.current
//        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date())
//        return ageComponents.year ?? 0
//    }
//    
//    private func calculateBMI(height: Double, weight: Double) -> Double {
//        let heightInMeters = height / 100
//        return weight / (heightInMeters * heightInMeters)
//    }
//}
//
//// MARK: - Components
//
//struct InfoRow: View {
//    let label: String
//    let value: String
//    
//    var body: some View {
//        HStack {
//            Text(label)
//                .foregroundColor(.secondary)
//                .frame(width: 120, alignment: .leading)
//            Text(value)
//            Spacer()
//        }
//    }
//}
//
//struct PrescriptionCard: View {
//    let medicine: Medicine
//    let prescribedMedicine: PrescribedMedicine
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text(medicine.medicineName)
//                    .font(.headline)
//                Spacer()
//                if prescribedMedicine.fastingRequired == "Yes" {
//                    Text("Fasting")
//                        .font(.caption)
//                        .padding(4)
//                        .background(Color.orange.opacity(0.2))
//                        .cornerRadius(4)
//                }
//            }
//            
//            VStack(alignment: .leading, spacing: 4) {
//                ForEach(prescribedMedicine.medicineDosage.sorted(by: { $0.key < $1.key }), id: \.key) { time, dosage in
//                    HStack {
//                        Text(time.capitalized)
//                            .foregroundColor(.secondary)
//                        Text(dosage)
//                    }
//                }
//            }
//            
//            Text(medicine.medicineRemarks)
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//        .padding()
//        .background(Color(.secondarySystemBackground))
//        .cornerRadius(8)
//    }
//}
//
//struct LabTestCard: View {
//    let test: LabTest
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text(test.testType)
//                    .font(.headline)
//                Spacer()
//                Text(test.testDateTime, style: .date)
//                    .foregroundColor(.secondary)
//            }
//            
//            if !test.testResult.isEmpty {
//                VStack(alignment: .leading, spacing: 4) {
//                    ForEach(test.testResult.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
//                        HStack {
//                            Text(key)
//                                .foregroundColor(.secondary)
//                                .frame(width: 80, alignment: .leading)
//                            Text(value)
//                            Spacer()
//                        }
//                    }
//                }
//            }
//        }
//        .padding()
//        .background(Color(.secondarySystemBackground))
//        .cornerRadius(8)
//    }
//}
//// MARK: - Patient Detail Preview
//
//struct PatientDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        let mockPatient = Patient(
//            id: "p1",
//            patientName: "John Doe",
//            patientEmail: "john.doe@example.com",
//            patientMobile: "+1234567890",
//            patientDob: Calendar.current.date(byAdding: .year, value: -35, to: Date())!,
//            patientGender: "Male",
//            patientBloodGroup: "A+",
//            patientRemark: "Allergic to penicillin"
//        )
//        
//        NavigationView {
//            PatientDetailView(patient: mockPatient)
//                .environmentObject(MockHospitalDataStore())
//        }
//    }
//}



