import SwiftUI
import Foundation


struct AuthResponse {
    
    struct PatientLoginRequest {
        
        struct OTPResponse: Codable {
            let otp: String
            let status: Bool
        }
        
        struct LoginResponse: Codable {
            let message: String
            let user_id: Int
            let user_type: String
            let access_token: String
            let refresh_token: String
            let status: Bool
        }
    }
    
    struct AdminLoginResponse {
        struct OtpResponse: Codable {
            let message: String
            let user_id: String
            let user_type: String
            let requires_otp: Bool
            let success: Bool
        }
        
        struct LoginResponse: Codable {
            let message: String
            let user_id: String
            let user_type: String
            let access_token: String
            let refresh_token: String
            let status: Bool
        }
    }

    struct AdminLoginRequest {
        struct OTPRequest: Codable {
            let email: String
            let user_type: String
            let password: String
        }
        
        struct LoginRequest: Codable {
            let email: String
            let otp: String
            let user_type: String
        }
    }
    
    struct StaffLoginResponse{
        struct OtpResponse : Codable {
            let message: String
            let status: Bool
        }
        struct LoginResponse: Codable {
            let message: String
            let user_id: String
            let user_type: String
            let access_token: String
            let refresh_token: String
            let status: Bool
        }


    }
    
    struct PatientSignUpResponse {
            
            struct OTPResponse: Codable {
                let message: String
                let status: String
            }
            
            struct SignUpResponse: Codable {
                let message: String
                let patient_id: String
                let access_token: String
                let refresh_token: String
            }
            
            struct UpdatePatientDetailsResponse: Codable {
                let message: String
                let created: Bool
                let success: Bool
            }
        }
    
}
