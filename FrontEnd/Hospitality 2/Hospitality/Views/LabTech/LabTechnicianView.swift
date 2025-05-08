//
//  LabTechnicianView.swift
//  Hospitality
//
//  Created by admin@33 on 05/05/25.
//

import SwiftUI

// MARK: - Data Models
struct AppointmentListResponse: Identifiable, Codable {
    let id: Int
    let patientName: String
    let staffName: String
    let createdDate: String
    let slotStartTime: String
    let status: String
    let reason: String
    let labTests: [LabTest2]
    
    enum CodingKeys: String, CodingKey {
        case id = "appointment_id"
        case patientName = "patient_name"
        case staffName = "staff_name"
        case createdDate = "created_at"
        case slotStartTime = "slot_start_time"
        case status
        case reason
        case labTests = "lab_tests"
    }
}

struct LabTest2: Identifiable, Codable {
    let id: Int
    let testType: String
    let testDateTime: String
    let priority: String
    let isPaid: Bool
    let testResult: TestResult?
    
    enum CodingKeys: String, CodingKey {
        case id = "lab_test_id"
        case testType = "test_type"
        case testDateTime = "test_datetime"
        case priority
        case isPaid = "is_paid"
        case testResult = "test_result"
    }
}

struct TestResult: Codable {
    let notes: String?
    let platelets: Int?
    let rbcCount: Double?
    let wbcCount: Int?
    let hemoglobin: Double?
    
    enum CodingKeys: String, CodingKey {
        case notes
        case platelets
        case rbcCount = "rbc_count"
        case wbcCount = "wbc_count"
        case hemoglobin
    }
}

struct LabTestResultRequest: Encodable {
    let testResult: TestResultRequest
    
    enum CodingKeys: String, CodingKey {
        case testResult = "test_result"
    }
}

struct TestResultRequest: Encodable {
    let notes: String?
    let platelets: Int?
    let rbcCount: Double?
    let wbcCount: Int?
    let hemoglobin: Double?
    
    enum CodingKeys: String, CodingKey {
        case notes
        case platelets
        case rbcCount = "rbc_count"
        case wbcCount = "wbc_count"
        case hemoglobin
    }
}

struct TestResultResponse: Decodable {
    let message: String
    let labTestId: Int
    
    enum CodingKeys: String, CodingKey {
        case message
        case labTestId = "lab_test_id"
    }
}

// MARK: - Main View
struct LabTechnicianView: View {
    @StateObject private var viewModel = LabTechnicianViewModel()
    @State private var showingProfile = false
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading appointments...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.appointments.isEmpty {
                    Text("No appointments found")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.appointments) { appointment in
                        AppointmentCard(appointment: appointment, viewModel: viewModel)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Lab Tech Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(systemName: "person.circle")
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                LabTechProfileView()
            }
            .onAppear {
                viewModel.fetchAppointments()
            }
        }
    }
}

// MARK: - Subviews
struct AppointmentCard: View {
    let appointment: AppointmentListResponse
    @ObservedObject var viewModel: LabTechnicianViewModel
    @State private var showingResultInput = false
    @State private var selectedTest: LabTest2?
    @State private var hemoglobin: String = ""
    @State private var wbcCount: String = ""
    @State private var rbcCount: String = ""
    @State private var platelets: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Patient: \(appointment.patientName)")
                    .font(.headline)
                Spacer()
                Text(appointment.status)
                    .font(.caption)
                    .padding(4)
                    .background(statusColor(for: appointment.status))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            Text("Doctor: \(appointment.staffName)")
                .font(.subheadline)
            
            Text("Date: \(appointment.createdDate)")
                .font(.subheadline)
            
            Text("Slot: \(appointment.slotStartTime)")
                .font(.subheadline)
            
            if !appointment.labTests.isEmpty {
                Text("Lab Tests:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(appointment.labTests) { test in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("• \(test.testType)")
                                .font(.caption)
                            Spacer()
                            
                            if test.testResult != nil {
                                Text("Completed")
                                    .font(.caption2)
                                    .padding(4)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            } else {
                                Button(action: {
                                    selectedTest = test
                                    showingResultInput = true
                                }) {
                                    Text("Enter Results")
                                        .font(.caption2)
                                        .padding(4)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        
                        Text("Priority: \(test.priority)")
                            .font(.caption)
                        Text("Date: \(test.testDateTime)")
                            .font(.caption)
                        Text("Paid: \(test.isPaid ? "Yes" : "No")")
                            .font(.caption)
                        
                        if let result = test.testResult {
                            Text("Results:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            if let notes = result.notes {
                                Text("Notes: \(notes)")
                                    .font(.caption)
                            }
                            if let platelets = result.platelets {
                                Text("Platelets: \(platelets)")
                                    .font(.caption)
                            }
                            if let rbc = result.rbcCount {
                                Text("RBC: \(rbc)")
                                    .font(.caption)
                            }
                            if let wbc = result.wbcCount {
                                Text("WBC: \(wbc)")
                                    .font(.caption)
                            }
                            if let hemoglobin = result.hemoglobin {
                                Text("Hemoglobin: \(hemoglobin)")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            
            Text("Reason: \(appointment.reason)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
        .padding(.vertical, 4)
        .sheet(isPresented: $showingResultInput) {
            if let test = selectedTest {
                LabTestResultInputView(
                    test: test,
                    hemoglobin: $hemoglobin,
                    wbcCount: $wbcCount,
                    rbcCount: $rbcCount,
                    platelets: $platelets,
                    notes: $notes,
                    onSubmit: {
                        submitResults(for: test)
                    },
                    onCancel: {
                        showingResultInput = false
                        resetForm()
                    }
                )
            }
        }
    }
    
    private func submitResults(for test: LabTest2) {
        guard let hemoglobinValue = Double(hemoglobin),
              let wbcValue = Int(wbcCount),
              let rbcValue = Double(rbcCount),
              let plateletsValue = Int(platelets) else {
            viewModel.errorMessage = "Please enter valid numeric values"
            return
        }
        
        let request = LabTestResultRequest(
            testResult: TestResultRequest(
                notes: notes.isEmpty ? nil : notes,
                platelets: plateletsValue,
                rbcCount: rbcValue,
                wbcCount: wbcValue,
                hemoglobin: hemoglobinValue
            )
        )
        
        viewModel.submitTestResults(testId: test.id, request: request) { success in
            if success {
                showingResultInput = false
                resetForm()
                viewModel.fetchAppointments()
            }
        }
    }
    
    private func resetForm() {
        hemoglobin = ""
        wbcCount = ""
        rbcCount = ""
        platelets = ""
        notes = ""
        selectedTest = nil
    }
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "scheduled": return .blue
        case "completed": return .green
        case "cancelled": return .red
        default: return .gray
        }
    }
}

struct LabTestResultInputView: View {
    let test: LabTest2
    @Binding var hemoglobin: String
    @Binding var wbcCount: String
    @Binding var rbcCount: String
    @Binding var platelets: String
    @Binding var notes: String
    let onSubmit: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Test: \(test.testType)")) {
                    TextField("Hemoglobin (g/dL)", text: $hemoglobin)
                        .keyboardType(.decimalPad)
                    TextField("WBC Count (cells/μL)", text: $wbcCount)
                        .keyboardType(.numberPad)
                    TextField("RBC Count (million cells/μL)", text: $rbcCount)
                        .keyboardType(.decimalPad)
                    TextField("Platelets (platelets/μL)", text: $platelets)
                        .keyboardType(.numberPad)
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle("Enter Test Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit", action: onSubmit)
                }
            }
        }
    }
}

// MARK: - ViewModel
class LabTechnicianViewModel: ObservableObject {
    @Published var appointments: [AppointmentListResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let baseURL = Constants.baseURL
    
    func fetchAppointments() {
        guard let url = URL(string: "\(baseURL)/hospital/general/lab-technician/assigned-patients/") else {
            errorMessage = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response from server"
                    return
                }
                
                if httpResponse.statusCode == 401 {
                    self?.errorMessage = "Unauthorized access. Please log in again."
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode), let data = data else {
                    let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                    self?.errorMessage = "Server error: \(errorMessage)"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode([AppointmentListResponse].self, from: data)
                    self?.appointments = response
                } catch {
                    self?.errorMessage = "Error decoding response: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    func submitTestResults(testId: Int, request: LabTestResultRequest, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/hospital/general/lab-tests/\(testId)/results/") else {
            errorMessage = "Invalid URL"
            completion(false)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            errorMessage = "Error encoding request data: \(error.localizedDescription)"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response from server"
                    completion(false)
                    return
                }
                
                if httpResponse.statusCode == 401 {
                    self?.errorMessage = "Unauthorized access. Please log in again."
                    completion(false)
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                    self?.errorMessage = "Server error: \(errorMessage)"
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }.resume()
    }
}

struct LabTechnicianView_Previews: PreviewProvider {
    static var previews: some View {
        LabTechnicianView()
    }
}
