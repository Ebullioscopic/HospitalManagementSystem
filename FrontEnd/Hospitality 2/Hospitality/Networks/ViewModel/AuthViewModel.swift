//
//  AuthViewModel.swift
//  Hospitality
//
//  Created by admin29 on 25/04/25.
//

import SwiftUI
import Combine
import Foundation

class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isOTPSent = false
    
    func sendOTP(email: String, password: String, userType: String) {
        isLoading = true
        errorMessage = ""
        isOTPSent = false
        
        AuthService.shared.requestOTP(email: email, password: password, userType: userType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                self?.isLoading = false
                self?.isOTPSent = response.success && response.requires_otp
                if !response.success {
                    self?.errorMessage = response.message
                    self?.showError = true
                }
            })
            .store(in: &cancellables)
    }
    
    func verifyOTP(email: String, otp: String, userType: String, completion: @escaping (AdminLoginResponse.LoginResponse?) -> Void) {
        print("AuthViewModel: Starting OTP verification for email: \(email), userType: \(userType)")
        isLoading = true
        errorMessage = ""
        
        AuthService.shared.verifyOTP(email: email, otp: otp, userType: userType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                self?.isLoading = false
                switch result {
                case .failure(let error):
                    print("AuthViewModel: OTP verification failed: \(error)")
                    self?.errorMessage = "Failed to verify OTP: \(error.localizedDescription)"
                    self?.showError = true
                    completion(nil)
                case .finished:
                    print("AuthViewModel: OTP verification completed")
                }
            }, receiveValue: { response in
                print("AuthViewModel: Verification response received: \(response)")
                self.isLoading = false
                completion(response)
            })
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}
