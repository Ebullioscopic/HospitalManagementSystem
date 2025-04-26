import Foundation
import Combine
import SwiftUI

class PatientStaffLoginViewModel: ObservableObject {
    // Service instance
    private let loginService = PatientStaffLoginService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Published state properties
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    // OTP request state
    @Published var otpRequestSuccess = false
    @Published var otpValue = ""
    
    // Login state
    @Published var loginSuccess = false
    @Published var userId: Int? = nil
    @Published var userType = ""
    @Published var accessToken = ""
    @Published var refreshToken = ""
    @Published var message = ""
    
    // User types
    let userTypePatient = "patient"
    let userTypeStaff = "staff"
    
    // User type is set during initialization
//    private let userType: String
    
    init(userType: String) {
        self.userType = userType
    }
    
    // Request OTP for login
    func requestOTP(email: String, password: String) {
        print("Requesting OTP for \(userType) login: \(email)")
        isLoading = true
        errorMessage = ""
        
        loginService.requestOTP(email: email, password: password, userType: self.userType)
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
                self.otpRequestSuccess = response.status
                self.otpValue = response.otp
            }
            .store(in: &cancellables)
    }
    
    // Complete login with OTP verification
    func completeLogin(email: String, otp: String) {
        isLoading = true
        errorMessage = ""
        
        loginService.completeLogin(email: email, otp: otp, userType: self.userType)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
        
                self.userId = response.user_id
                self.userType = response.user_type
                self.accessToken = response.access_token
                self.refreshToken = response.refresh_token
                self.message = response.message
                
                // Store tokens and user info if login was successful
                if response.success {
                    self.loginService.saveTokens(
                        accessToken: response.access_token,
                        refreshToken: response.refresh_token,
                        userType: response.user_type,
                        userId: response.user_id
                    )
                }
            }
            .store(in: &cancellables)
    }
    
    // Check if user is logged in
    var isLoggedIn: Bool {
        return loginService.getAccessToken() != nil
    }
    
    // Logout function
    func logout() {
        loginService.clearAuthData()
        resetState()
    }
    
    // Reset the view model state
    func resetState() {
        otpRequestSuccess = false
        otpValue = ""
        loginSuccess = false
        userId = nil
        userType = ""
        accessToken = ""
        refreshToken = ""
        message = ""
        errorMessage = ""
    }
}
