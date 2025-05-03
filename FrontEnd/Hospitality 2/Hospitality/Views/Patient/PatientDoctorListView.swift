//
//  PatientDoctorListView.swift
//  Hospitality
//
//  Created by admin@33 on 28/04/25.
//

import Foundation
import SwiftUI

struct PatientDoctorListView: View {
    @State private var doctors: [PatientDoctorListResponse] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @Environment(\.presentationMode) var presentationMode
    var onAppointmentBooked: (() -> Void)?
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                ErrorView(message: errorMessage, onRetry: fetchDoctors)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Search bar
                        SearchBar(text: $searchText)
                            .padding(.horizontal)
                        
                        // Recommended doctors section
                        if !recommendedDoctors.isEmpty {
                            SectionHeaderView(title: "Recommended For You", subtitle: "Based on your medical history")
                            DoctorGridView(doctors: recommendedDoctors)
                        }
                        
                        // All doctors section
                        SectionHeaderView(title: "All Doctors", subtitle: "Available specialists")
                        DoctorGridView(doctors: filteredDoctors)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Find a Doctor")
        .onAppear {
            fetchDoctors()
        }
    }
    
    private var recommendedDoctors: [PatientDoctorListResponse] {
        // Filter doctors with recommendations (you might need to adjust this based on your API response)
        doctors.filter { $0.specialization.lowercased().contains("recommended") }
    }
    
    private var filteredDoctors: [PatientDoctorListResponse] {
        if searchText.isEmpty {
            return doctors
        } else {
            return doctors.filter { doctor in
                doctor.staff_name.lowercased().contains(searchText.lowercased()) ||
                doctor.specialization.lowercased().contains(searchText.lowercased()) ||
                doctor.doctor_type.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    private func fetchDoctors() {
        isLoading = true
        errorMessage = nil
        
        DoctorService.shared.fetchDoctorsForPatient { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let fetchedDoctors):
                    self.doctors = fetchedDoctors
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// Helper views
struct SectionHeaderView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top)
    }
}

struct DoctorGridView: View {
    let doctors: [PatientDoctorListResponse]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
            ForEach(doctors, id: \.staff_id) { doctor in
                DoctorCardView(doctor: doctor)
            }
        }
        .padding(.horizontal)
    }
}

struct DoctorCardView: View {
    let doctor: PatientDoctorListResponse
    
    var body: some View {
        NavigationLink(destination: PatientDoctorDetailView(doctorId: doctor.staff_id)) {
            VStack(alignment: .leading, spacing: 8) {
                // Doctor image placeholder
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                
                // Doctor info
                VStack(alignment: .leading, spacing: 4) {
                    Text(doctor.staff_name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(doctor.specialization)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "stethoscope")
                        Text(doctor.doctor_type)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    if doctor.on_leave {
                        Text("On Leave")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Try Again", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
