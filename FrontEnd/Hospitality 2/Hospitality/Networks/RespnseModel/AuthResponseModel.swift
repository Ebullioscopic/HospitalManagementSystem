import SwiftUI
import Foundation


struct AuthResponse {
    
    struct PatientSignUpResponse {
        
        struct OTPResponse: Codable {
            let message: String
            let status: String
        }
        
        struct SignUpResponse: Codable {
            let message: String
            let patient_id: Int
            let access_token: String
            let refresh_token: String
            // let status: Bool
        }
        
        struct UpdatePatientDetailsResponse: Codable {
            let message: String
            let created: String
            let success: Bool
        }
    }
    
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
    
    struct AdminLoginResponse{
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
    
}
