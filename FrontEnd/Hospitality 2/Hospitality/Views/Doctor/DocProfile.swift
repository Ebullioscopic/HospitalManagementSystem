//
//  DocProfile.swift
//  Hospitality
//
//  Created by admin@33 on 28/04/25.
//

import SwiftUI
import UIKit

struct DocProfile: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var showLogoutConfirmation = false
    
    // Doctor data
    private let doctorName = UserDefaults.email
    private let doctorSpecialty = "Cardiology"
    private let staffID = "DOC-12345"
    
    // Shift selection state
    @State private var selectedDate = Date()
    @State private var selectedSlots: Set<Int> = []
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    let availableSlots = [
        (id: 1, name: "Morning (8AM-12PM)"),
        (id: 2, name: "Afternoon (12PM-4PM)"),
        (id: 3, name: "Evening (4PM-8PM)"),
        (id: 4, name: "Night (8PM-12AM)")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    profileHeader
                    shiftSelectionSection
                    accountSection
                    settingsSection
                    logoutButton
                }
                .padding()
            }
            .navigationTitle("Doctor Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            // Add alerts directly using .alert(isPresented:content:)
            .alert("Log Out", isPresented: $showLogoutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) { logout() }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your availability has been successfully submitted.")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var profileHeader: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "4A90E2"))
                .padding(.bottom, 10)
            
            Text(doctorName)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Doctor")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(doctorSpecialty)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 2)
            
            Text("Staff ID: \(staffID)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 2)
        }
        .padding(.vertical, 30)
    }
    
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
        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
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
                        selectedSlots.insert(slot.id)
                    } else {
                        selectedSlots.remove(slot.id)
                    }
                }
            )) {
                Text(slot.name)
                    .font(.subheadline)
            }
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
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .disabled(isSubmitting || selectedSlots.isEmpty)
        .opacity(isSubmitting || selectedSlots.isEmpty ? 0.6 : 1)
    }
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("ACCOUNT")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            NavigationLink(destination: Text("Edit Profile")) {
                ProfileRow(icon: "person.fill", title: "Edit Profile")
            }
            
            NavigationLink(destination: Text("Change Password")) {
                ProfileRow(icon: "lock.fill", title: "Change Password")
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Divider()
                .padding(.vertical, 10)
            
            Text("SETTINGS")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            NavigationLink(destination: Text("Notifications")) {
                ProfileRow(icon: "bell.fill", title: "Notifications")
            }
            
            NavigationLink(destination: Text("Privacy")) {
                ProfileRow(icon: "hand.raised.fill", title: "Privacy")
            }
        }
    }
    
    private var logoutButton: some View {
        Button(action: { showLogoutConfirmation = true }) {
            HStack {
                Image(systemName: "arrow.left.square.fill")
                    .foregroundColor(.red)
                Text("Log Out")
                    .foregroundColor(.red)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red.opacity(0.1))
            )
        }
        .padding(.top, 30)
        .padding(.horizontal)
    }
    
    // MARK: - Helper Functions
    
    private func submitShifts() {
        guard !selectedSlots.isEmpty else { return }
        
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
    
    private func logout() {
        UserDefaults.clearAuthData()
        dismiss()
        NotificationCenter.default.post(name: .logout, object: nil)
    }
}

#Preview {
    DocProfile()
        .preferredColorScheme(.dark)
}
