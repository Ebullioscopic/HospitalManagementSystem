import SwiftUI
import Foundation

struct AuthEndpoint {
    struct PatientSignUp {
        static let requestOTP = "/accounts/request-otp/"
        static let signup = "/accounts/patient-signup/"
        static let updateProfile = "/accounts/patient/update-profile/"
    }
    
    struct PatientLogin {
        static let requestOTP = "/accounts/request-otp"
        static let login = "/accounts/login"
    }
    
    struct AdminLogin {
        static let requestOTP = "/accounts/request-otp/"
        static let login = "/accounts/login/"
    }
}
