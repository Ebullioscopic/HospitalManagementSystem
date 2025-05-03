//
//  PatientSignupService.swift
//  Hospitality
//
//  Created by admin@33 on 28/04/25.
//

import Foundation
import Combine



class PatientSignupService {
    static let shared = PatientSignupService()
    private let baseURL = Constants.baseURL
    private var cancellables = Set<AnyCancellable>()
    
    // Request OTP for patient signup
    func requestOTP(email: String) -> AnyPublisher<AuthResponse.PatientSignUpResponse.OTPResponse, Error> {
        print("Entered Service")
        let endpoint = AuthEndpoint.PatientSignUp.requestOTP
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        print("URL: \(url)")
        
        let requestBody = AuthRequest.PatientSignUpRequest.OTPRequest(email: email)
        
        print("Request Body: \(requestBody)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(requestBody)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { data, _ in
                // Print raw JSON string
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw Response Data:\n\(jsonString)")
                }
            })
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: AuthResponse.PatientSignUpResponse.OTPResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

    }
    
    // Complete patient signup with OTP and details
    func completeSignup(email: String, otp: String, patientName: String, patientPhone: Int, patientPassword: String) -> AnyPublisher<AuthResponse.PatientSignUpResponse.SignUpResponse, Error> {
        
        print("Entered Complete Signup Service")
        let endpoint = AuthEndpoint.PatientSignUp.signup
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        print("URL: \(url)")
        let requestBody = AuthRequest.PatientSignUpRequest.SignUpRequest(
            email: email,
            otp: otp,
            patient_name: patientName,
            patient_mobile: patientPhone,
            password: patientPassword
        )
        print("Request Body: \(requestBody)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(requestBody)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { data, _ in
                // Print raw JSON string
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw Response Data:\n\(jsonString)")
                }
            })
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: AuthResponse.PatientSignUpResponse.SignUpResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Update patient profile details
    func updatePatientDetails(
        token: String,
        patientDob: Date,
        patientGender: Bool,
        patientBloodGroup: String,
        patientAddress: String
    ) -> AnyPublisher<AuthResponse.PatientSignUpResponse.UpdatePatientDetailsResponse, Error> {
        
        let endpoint = AuthEndpoint.PatientSignUp.updateProfile
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        // Format date to string (e.g., yyyy-MM-dd)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dobString = dateFormatter.string(from: patientDob)
        
        // Map form data
        let formBody: [String: Any] = [
            "patient_dob": dobString,
            "patient_gender": patientGender ? "male" : "female",
            "patient_blood_group": patientBloodGroup,
            "patient_address": "123 Main St, SRM, Chenani"
        ]
        
        // Convert to form-urlencoded data
        let bodyData = formBody
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = bodyData
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { data, _ in
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 Raw Response Data:\n\(jsonString)")
                }
            })
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                
                // Now let's decode to check the success field
                let decoder = JSONDecoder()
                let responseObj = try decoder.decode(AuthResponse.PatientSignUpResponse.UpdatePatientDetailsResponse.self, from: data)
                
                // If API returned success: false, throw an error with the message
                if !responseObj.success {
                    throw NSError(domain: "ProfileUpdateError",
                                 code: 0,
                                 userInfo: [NSLocalizedDescriptionKey: responseObj.message])
                }
                
                return data
            }
            .decode(type: AuthResponse.PatientSignUpResponse.UpdatePatientDetailsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    
    // Helper method to handle token storage
    func saveTokens(accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(accessToken, forKey: "accessToken")
        UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
    }
    
    // Helper method to get stored access token
    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: "accessToken")
    }
}
