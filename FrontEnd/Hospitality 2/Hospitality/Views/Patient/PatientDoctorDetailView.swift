//
//  PatientDoctorDetailView.swift
//  Hospitality
//
//  Created by admin@33 on 28/04/25.
//

import Foundation
import SwiftUI

struct PatientDoctorDetailView: View {
    let doctorId: String
    @State private var doctor: PatientSpecificDoctorResponse?
    @State private var slots: [PatientSlotListResponse] = []
    @State private var selectedDate = Date()
    @State private var selectedSlot: PatientSlotListResponse?
    @State private var reason = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
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
                                        onSelect: { selectedSlot = slot }
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    // Reason for Visit Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reason for Visit (Optional)")
                            .font(.headline)
                        
                        TextEditor(text: $reason)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Book Appointment Button
                    Button(action: bookAppointment) {
                        Text("Book Appointment")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedSlot == nil ? Color.gray : Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(selectedSlot == nil)
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
                             "Failed to book appointment. Please try again."),
                dismissButton: .default(Text("OK")) {
                    if appointmentSuccess {
                        // Navigate back or perform other actions
                    }
                }
            )
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
                } catch {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    private func bookAppointment() {
        guard let selectedSlot = selectedSlot else { return }
        
        isLoading = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)
        
        let requestBody = PatientAppointRequest(
            date: dateString,
            staff_id: doctorId,
            slot_id: selectedSlot.slot_id,
            reason: reason
        )
        
        guard let url = URL(string: "\(Constants.baseURL)/hospital/general/appointments/") else {
            errorMessage = "Invalid URL"
            isLoading = false
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
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
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
                
                guard (200...299).contains(httpResponse.statusCode), let data = data else {
                    errorMessage = "Server returned status code \(httpResponse.statusCode)"
                    appointmentSuccess = false
                    showConfirmation = true
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(PatientAppointResponse.self, from: data)
                    print("Appointment booked successfully with ID: \(response.appointment_id)")
                    appointmentSuccess = true
                    showConfirmation = true
                } catch {
                    errorMessage = "Failed to decode response: \(error.localizedDescription)"
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
    
    var body: some View {
        Button(action: onSelect) {
            Text(slot.slot_start_time)
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
                .cornerRadius(8)
        }
    }
}

