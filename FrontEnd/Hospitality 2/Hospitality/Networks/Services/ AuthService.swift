import SwiftUI
import Combine
import Foundation

class AuthService {
    static let shared = AuthService()
    static let baseURL = Constants.baseURL
   

    func requestOTP(email: String) -> AnyPublisher<AuthResponse.PatientSignUpResponse.OTPResponse, Error> {
        print("Requesting OTP for email: \(email)")
        let endpoint = AuthEndpoint.PatientSignUp.requestOTP
        let url = URL(string: "\(AuthService.baseURL)\(endpoint)")!

        let requestBody = AuthRequest.PatientSignUpRequest.OTPRequest(email: email)
        print(requestBody)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(requestBody)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: AuthResponse.PatientSignUpResponse.OTPResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    // Add other functions similarly for signUp, updateProfile, etc.
}
