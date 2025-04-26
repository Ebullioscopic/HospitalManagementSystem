//
//  PatientViewModel.swift
//  Hospitality
//
//  Created by admin29 on 26/04/25.
//


import Foundation
import Combine

class PatientViewModel: ObservableObject {
    private let patientService = PatientService()
    
    @Published var patientProfile: PatientResponse.PatientProfileResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchProfile() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let profile = try await patientService.fetchPatientProfile()
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.patientProfile = profile
                    self.isLoading = false
                }
            } catch let error as NetworkError {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.errorMessage = error.errorMessage
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.errorMessage = "An unexpected error occurred"
                    self.isLoading = false
                }
            }
        }
    }
    
}
