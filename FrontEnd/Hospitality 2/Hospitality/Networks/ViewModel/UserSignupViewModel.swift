//
//  UserSignupViewModel.swift
//  Hospitality
//
//  Created by admin@33 on 28/04/25.
//

import Foundation
import Combine
import SwiftUI

class UserSignupViewModel: ObservableObject {
    // Service instance
    private let signupService = PatientSignupService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Published state properties
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    // OTP request state
    @Published var otpRequestSuccess = false
    @Published var otpResponseMessage = ""
    
    // Signup state
    @Published var signupSuccess = false
    @Published var patientId = ""
    @Published var accessToken = ""
    @Published var refreshToken = ""
    
    // Profile update state
    @Published var profileUpdateSuccess = false
    @Published var profileUpdateMessage = ""
    
    // Request OTP for signup
    func requestOTP(email: String) {
        print("Requesting OTP for email in viewModel: \(email)")
        isLoading = true
        errorMessage = ""
        
        signupService.requestOTP(email: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                // Handle response based on actual model structure
                self.otpRequestSuccess = response.status == "success"
                self.otpResponseMessage = response.message
            }
            .store(in: &cancellables)
    }
    
    // Complete signup with OTP and personal details
    func completeSignup(email: String, otp: String, patientName: String, patientPhone: Int, patientPassword: String) {
        isLoading = true
        errorMessage = ""
        
        signupService.completeSignup(
            email: email,
            otp: otp,
            patientName: patientName,
            patientPhone: patientPhone,
            patientPassword: patientPassword
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            
            if case let .failure(error) = completion {
                self.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            // SignUpResponse doesn't have status field
            // Determine success based on presence of tokens
            self.signupSuccess = !response.access_token.isEmpty
            self.patientId = response.patient_id
            self.accessToken = response.access_token
            self.refreshToken = response.refresh_token
            
            // Store tokens if signup was successful
            if self.signupSuccess {
                self.signupService.saveTokens(
                    accessToken: response.access_token,
                    refreshToken: response.refresh_token
                )
            }
        }
        .store(in: &cancellables)
    }
    
    // Update patient profile after signup
    func updatePatientProfile(
        patientDob: Date,
        patientGender: Bool,
        patientBloodGroup: String,
        patientAddress: String
    ) {
        isLoading = true
        errorMessage = ""
        
        guard let token = signupService.getAccessToken() else {
            errorMessage = "Missing access token. Please sign in again."
            return
        }
        
        signupService.updatePatientDetails(
            token: token,
            patientDob: patientDob,
            patientGender: patientGender,
            patientBloodGroup: patientBloodGroup,
            patientAddress: patientAddress
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            
            if case let .failure(error) = completion {
                self.errorMessage = error.localizedDescription
            }
        } receiveValue: { [weak self] response in
            guard let self = self else { return }
            
            // Use the new success field directly instead of checking created string
            self.profileUpdateSuccess = response.success
            self.profileUpdateMessage = response.message
            
            // If the response indicates failure, set error message
            if !response.success {
                self.errorMessage = response.message
            }
        }
        .store(in: &cancellables)
    }
    
    // Reset the state (useful when navigating away)
    func resetState() {
        otpRequestSuccess = false
        otpResponseMessage = ""
        signupSuccess = false
        patientId = ""
        profileUpdateSuccess = false
        errorMessage = ""
    }
}
