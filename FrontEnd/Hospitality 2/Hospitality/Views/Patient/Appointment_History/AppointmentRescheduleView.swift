import SwiftUI

struct AppointmentRescheduleView: View {
    // MARK: - Properties
    let appointmentId: Int
    let doctorId: String
    let currentDate: String
    let currentSlotId: Int
    let reason: String
    var onRescheduleComplete: (() -> Void)?
    
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate = Date()
    @State private var availableSlots: [PatientSlotListResponse] = []
    @State private var selectedSlot: PatientSlotListResponse?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var showAlert = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current appointment info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Appointment")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Date:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(formatDate(currentDate))
                                    .font(.body)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("New Date:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(formatSelectedDate())
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Date Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select New Date")
                            .font(.headline)
                        
                        DatePicker("",
                                  selection: $selectedDate,
                                  in: Date()...(Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()),
                                  displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .onChange(of: selectedDate) { _ in
                                fetchSlots()
                                selectedSlot = nil
                            }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Available Slots
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select New Time Slot")
                            .font(.headline)
                        
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 100)
                        } else if availableSlots.isEmpty {
                            Text("No available slots for selected date")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, minHeight: 100)
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                                ForEach(availableSlots, id: \.slot_id) { slot in
                                    SlotButton(
                                        slot: slot,
                                        isSelected: selectedSlot?.slot_id == slot.slot_id,
                                        onSelect: {
                                            selectedSlot = slot
                                        },
                                        isPassed: false
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Reschedule Button
                    Button(action: rescheduleAppointment) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        } else {
                            Text("Confirm Reschedule")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedSlot == nil ? Color.gray : Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(selectedSlot == nil || isLoading)
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationTitle("Reschedule Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                fetchSlots()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(successMessage != nil ? "Success" : "Error"),
                    message: Text(successMessage ?? errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK")) {
                        if successMessage != nil {
                            onRescheduleComplete?()
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Helper Functions
    private func fetchSlots() {
        isLoading = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)
        
        guard let url = URL(string: "\(Constants.baseURL)/hospital/general/doctors/\(doctorId)/slots/?date=\(dateString)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken") ?? "")", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Invalid response"
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode), let data = data else {
                    errorMessage = "Server returned status code \(httpResponse.statusCode)"
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode([PatientSlotListResponse].self, from: data)
                    self.availableSlots = response.filter { !$0.is_booked }
                } catch {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    private func rescheduleAppointment() {
        guard let selectedSlot = selectedSlot else {
            errorMessage = "Please select a time slot"
            showAlert = true
            return
        }
        
        isLoading = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)
        
        // Prepare request body
        let requestBody: [String: Any] = [
            "date": dateString,
            "slot_id": selectedSlot.slot_id
        ]
        
        guard let url = URL(string: "\(Constants.baseURL)/hospital/general/appointments/\(appointmentId)/reschedule/") else {
            errorMessage = "Invalid URL"
            isLoading = false
            showAlert = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken") ?? "")", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            errorMessage = "Failed to encode request: \(error.localizedDescription)"
            isLoading = false
            showAlert = true
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Invalid response"
                    showAlert = true
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    // Success case
                    successMessage = "Appointment rescheduled successfully!"
                    showAlert = true
                } else {
                    // Error case
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = json["message"] as? String {
                        errorMessage = message
                    } else {
                        errorMessage = "Failed to reschedule appointment (Status code: \(httpResponse.statusCode))"
                    }
                    showAlert = true
                }
            }
        }.resume()
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return dateString
    }
    
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
}

// Response model for reschedule
struct RescheduleResponse: Codable {
    let message: String
    let appointment_id: Int
    let new_date: String
    let new_slot_id: Int
}
