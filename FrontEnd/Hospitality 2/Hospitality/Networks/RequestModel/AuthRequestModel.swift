import SwiftUI
import Foundation

struct AuthRequest {
    
    struct PatientSignUpRequest {
            
            struct OTPRequest: Codable {
                let email: String
            }
            
            struct SignUpRequest: Codable {
                let email: String
                let otp: String
                let patient_name: String
                let patient_mobile: Int
                let password: String
            }
            
            struct UpdatePatientDetailsRequest: Codable {
                let patient_dob: Date
                let patient_gender: Bool
                let patient_blood_group: String
                let patient_address: String
            }
        }
    
    struct PatientLoginRequest {
        
        struct OTPRequest: Codable {
            let email: String
            let password: String
            let user_type: String
        }
        
        struct LoginRequest: Codable {
            let email: String
            let otp: String
            let user_type: String
        }
    }
    
    struct AdminLoginRequest {
        struct OTPRequest: Codable {
            let email: String
            let userType: String
            let password: String
            
            enum CodingKeys: String, CodingKey {
                case email
                case userType = "user_type"
                case password
            }
        }
        
        struct LoginRequest: Codable {
            let email: String
            let otp: String
            let userType: String
            
            enum CodingKeys: String, CodingKey {
                case email
                case otp
                case userType = "user_type"
            }
        }
    }
    
    struct StaffLoginRequest{
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
    
}
