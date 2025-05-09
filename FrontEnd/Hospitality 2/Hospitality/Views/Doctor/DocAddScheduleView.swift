//
//  AddScheduleView.swift
//  Hospitality
//
//  Created by admin64 on 06/05/25.
//

import SwiftUI

struct DocAddScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    // Shift selection state
    @State private var selectedDate = Date()
    @State private var selectedSlots: Set<Int> = []
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    let availableSlots = [
        (id: 1, name: "Morning (6AM-12PM)"),
        (id: 2, name: "Afternoon (12PM-6PM)"),
        (id: 3, name: "Evening (6PM-12AM)"),
        (id: 4, name: "Night (12AM-6AM)")
    ]
    
    // Minimum date is today
    var minimumDate: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                shiftSelectionSection
            }
            .padding()
        }
        .navigationTitle("Add Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        })
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your availability has been successfully submitted.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Subviews
    
    private var shiftSelectionSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("SELECT AVAILABILITY")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            datePicker
            
            Text("Available Slots")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(availableSlots, id: \.id) { slot in
                slotToggle(slot: slot)
            }
            
            submitButton
        }
        .padding(.vertical)
    }
    
    private var datePicker: some View {
        DatePicker(
            "Select Date",
            selection: $selectedDate,
            in: minimumDate...Date.distantFuture,
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        )
        .shadow(radius: 2)
    }
    
    private func slotToggle(slot: (id: Int, name: String)) -> some View {
        HStack {
            Toggle(isOn: Binding(
                get: { selectedSlots.contains(slot.id) },
                set: { isSelected in
                    if isSelected {
                        if selectedSlots.count < 1 {
                            selectedSlots.insert(slot.id)
                        }
                    } else {
                        selectedSlots.remove(slot.id)
                    }
                }
            )) {
                Text(slot.name)
                    .font(.subheadline)
            }
            .disabled(!selectedSlots.contains(slot.id) && selectedSlots.count >= 2)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground)))
    }
    
    private var submitButton: some View {
        Button(action: submitShifts) {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "calendar.badge.plus")
                }
                Text("Submit Availability")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex:"0077CC"))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .disabled(isSubmitting || selectedSlots.isEmpty)
        .opacity(isSubmitting || selectedSlots.isEmpty ? 0.6 : 1)
    }
    
    // MARK: - Helper Functions
    
    private func submitShifts() {
        guard !selectedSlots.isEmpty else { return }
        
        // Additional validation to ensure date isn't in the past
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: selectedDate)
        
        if selectedDay < today {
            errorMessage = "Cannot add availability for past dates"
            showErrorAlert = true
            return
        }
        
        isSubmitting = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        
        let requests = selectedSlots.map { slotId in
            DoctorShiftRequest(shift_id: slotId, date: dateString)
        }
        
        let doctorId = UserDefaults.userId
        let group = DispatchGroup()
        var success = true
        var errorMsg = ""
        
        for request in requests {
            group.enter()
            
            guard let url = URL(string: "\(Constants.baseURL)/hospital/general/doctors/\(doctorId)/shifts/") else {
                errorMsg = "Invalid URL"
                success = false
                group.leave()
                return
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
            
            do {
                urlRequest.httpBody = try JSONEncoder().encode(request)
            } catch {
                errorMsg = "Failed to encode request"
                success = false
                group.leave()
                return
            }
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                defer { group.leave() }
                
                if let error = error {
                    errorMsg = error.localizedDescription
                    success = false
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMsg = "Invalid server response"
                    success = false
                    return
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    if let data = data, let errorResponse = try? JSONDecoder().decode([String: String].self, from: data) {
                        errorMsg = errorResponse["message"] ?? "Unknown error occurred"
                    } else {
                        errorMsg = "Server returned status code \(httpResponse.statusCode)"
                    }
                    success = false
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            isSubmitting = false
            
            if success {
                showSuccessAlert = true
                selectedSlots.removeAll()
            } else {
                errorMessage = errorMsg
                showErrorAlert = true
            }
        }
    }
}
