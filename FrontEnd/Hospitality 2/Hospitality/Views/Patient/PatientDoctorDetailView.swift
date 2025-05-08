import Foundation
import SwiftUI

struct PatientDoctorDetailView: View {
    let doctorId: String
    var onAppointmentBooked: (() -> Void)?
    
    @Environment(\.presentationMode) var presentationMode
    @State private var doctor: PatientSpecificDoctorResponse?
    @State private var slots: [PatientSlotListResponse] = []
    @State private var selectedDate = Date()
    @State private var selectedSlot: PatientSlotListResponse?
    @State private var reason = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var reasonError: String?
    @State private var appointmentSuccess = false
    @State private var showConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading && doctor == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 300)
                } else if let errorMessage = errorMessage {
                    ErrorView(message: errorMessage, onRetry: fetchDoctorDetails)
                } else if let doctor = doctor {
                    // Doctor Information Section
                    VStack(spacing: 16) {
                        // Doctor Image and Basic Info
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(doctor.staff_name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(doctor.specialization)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if doctor.on_leave {
                                    Text("Currently on leave")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // Doctor Type
                        HStack {
                            Image(systemName: "stethoscope")
                            Text(doctor.doctor_type)
                            Spacer()
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Date Picker Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Date")
                            .font(.headline)
                        
                        DatePicker("",
                                  selection: $selectedDate,
                                  in: Date()...(Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()),
                                  displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .onChange(of: selectedDate) { _ in
                                fetchSlots()
                            }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Available Slots Section
                    if isLoading && slots.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 100)
                    } else if slots.isEmpty {
                        Text("No available slots for selected date")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Available Slots")
                                .font(.headline)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                                ForEach(slots, id: \.slot_id) { slot in
                                    SlotButton(
                                        slot: slot,
                                        isSelected: selectedSlot?.slot_id == slot.slot_id,
                                        onSelect: {
                                            if !isSlotPassed(date: selectedDate, timeString: slot.slot_start_time) {
                                                selectedSlot = slot
                                            }
                                        },
                                        isPassed: isSlotPassed(date: selectedDate, timeString: slot.slot_start_time)
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    // Reason for Visit Section (now required)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reason for Visit (Required)")
                            .font(.headline)
                        
                        TextEditor(text: $reason)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(reasonError != nil ? Color.red : Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .onChange(of: reason) { _ in
                                // Clear error when user starts typing
                                if !reason.isEmpty {
                                    reasonError = nil
                                }
                            }
                        
                        // Error message for reason field
                        if let error = reasonError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Book Appointment Button
                    Button(action: bookAppointment) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        } else {
                            Text("Book Appointment")
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
            }
            .padding()
        }
        .navigationTitle("Doctor Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchDoctorDetails()
            fetchSlots()
        }
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text(appointmentSuccess ? "Success" : "Error"),
                message: Text(appointmentSuccess ?
                             "Your appointment has been booked successfully!" :
                             errorMessage ?? "Failed to book appointment. Please try again."),
                dismissButton: .default(Text("OK")) {
                    if appointmentSuccess {
                        // Call the callback to notify parent view
                        onAppointmentBooked?()
                        
                        // Dismiss all views to return to home page
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            // Find the root navigation controller and pop to root
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first,
                               let rootViewController = window.rootViewController,
                               let navigationController = findNavigationController(in: rootViewController) {
                                navigationController.popToRootViewController(animated: true)
                            } else {
                                // Fallback to just dismissing the current view
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            )
        }
    }
    // Helper function to find the navigation controller
    private func findNavigationController(in viewController: UIViewController) -> UINavigationController? {
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        for child in viewController.children {
            if let navigationController = findNavigationController(in: child) {
                return navigationController
            }
        }
        
        return nil
    }
    
    // Function to check if a slot's time has already passed
    private func isSlotPassed(date: Date, timeString: String) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        
        // First check if the date is in the past
        if !calendar.isDateInToday(date) {
            return date < now
        }
        
        // For today, we need to parse the time format which appears to be "HH:mm:ss"
        let timeComponents = timeString.components(separatedBy: ":")
        guard timeComponents.count >= 2,
              let hour = Int(timeComponents[0]),
              let minute = Int(timeComponents[1]) else {
            print("Failed to parse time: \(timeString)")
            return false
        }
        
        // Get current time components
        let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
        let currentHour = currentComponents.hour ?? 0
        let currentMinute = currentComponents.minute ?? 0
        
        // Compare times
        if hour < currentHour {
            return true
        } else if hour == currentHour {
            return minute <= currentMinute
        } else {
            return false
        }
    }
    
    private func fetchDoctorDetails() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(Constants.baseURL)/hospital/general/doctors/\(doctorId)/") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
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
                    let response = try JSONDecoder().decode(PatientSpecificDoctorResponse.self, from: data)
                    self.doctor = response
                } catch {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
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
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
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
                    self.slots = response.filter { !$0.is_booked }
                    self.selectedSlot = nil // Reset selected slot when date changes
                    
                    // If the selected slot is now in the past, deselect it
                    if let selected = self.selectedSlot,
                       isSlotPassed(date: selectedDate, timeString: selected.slot_start_time) {
                        self.selectedSlot = nil
                    }
                } catch {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    private func bookAppointment() {
        guard let selectedSlot = selectedSlot else {
            errorMessage = "Please select a time slot"
            showConfirmation = true
            return
        }
        
        // Validate reason field is not empty
        let trimmedReason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedReason.isEmpty {
            reasonError = "Please enter a reason for your visit"
            return
        }
        
        isLoading = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)
        
        let requestBody = PatientAppointRequest(
            date: dateString,
            staff_id: doctorId,
            slot_id: selectedSlot.slot_id,
            reason: trimmedReason
        )
        
        guard let url = URL(string: "\(Constants.baseURL)/hospital/general/appointments/") else {
            errorMessage = "Invalid URL"
            isLoading = false
            showConfirmation = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            errorMessage = "Failed to encode request: \(error.localizedDescription)"
            isLoading = false
            showConfirmation = true
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    appointmentSuccess = false
                    showConfirmation = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Invalid response"
                    appointmentSuccess = false
                    showConfirmation = true
                    return
                }
                
                if httpResponse.statusCode == 400 {
                    // Try to parse specific error message from API
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let errorMsg = json["error"] as? String {
                            errorMessage = errorMsg
                        } else if let errors = json["errors"] as? [String: Any], let reasonErrors = errors["reason"] as? [String] {
                            errorMessage = reasonErrors.joined(separator: ", ")
                        } else {
                            errorMessage = "Invalid appointment details"
                        }
                    } else {
                        errorMessage = "Invalid appointment details"
                    }
                    appointmentSuccess = false
                    showConfirmation = true
                    return
                } else if httpResponse.statusCode == 409 {
                    errorMessage = "This slot is no longer available. Please select another slot."
                    appointmentSuccess = false
                    showConfirmation = true
                    return
                } else if !(200...299).contains(httpResponse.statusCode) {
                    errorMessage = "Server error: \(httpResponse.statusCode)"
                    appointmentSuccess = false
                    showConfirmation = true
                    return
                }
                
                // Success case
                do {
                    let response = try JSONDecoder().decode(PatientAppointResponse.self, from: data!)
                    print("Appointment booked successfully with ID: \(response.appointment_id)")
                    appointmentSuccess = true
                    showConfirmation = true
                } catch {
                    errorMessage = "Failed to parse response: \(error.localizedDescription)"
                    appointmentSuccess = false
                    showConfirmation = true
                }
            }
        }.resume()
    }
}

struct SlotButton: View {
    let slot: PatientSlotListResponse
    let isSelected: Bool
    let onSelect: () -> Void
    let isPassed: Bool
    
    var body: some View {
        Button(action: onSelect) {
            Text(slot.slot_start_time)
                .font(.subheadline)
                .foregroundColor(isPassed ? .gray : (isSelected ? .white : .primary))
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(
                    isPassed ? Color.gray.opacity(0.3) :
                        (isSelected ? Color.blue : Color(.secondarySystemBackground))
                )
                .cornerRadius(8)
                .overlay(
                    isPassed ?
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1) :
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: isSelected ? 1 : 0)
                )
        }
        .disabled(isPassed)
    }
}

// Helper extension to trim strings (if not already available)
extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Request Models
//struct PatientAppointRequest: Codable {
//    let date: String
//    let staff_id: String
//    let slot_id: Int
//    let reason: String
//}
//
//struct PatientAppointResponse: Codable {
//    let appointment_id: Int
//    let message: String
//}
