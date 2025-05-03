//
//  UserSignup.swift
//  Hospitality
//
//  Created by admin29 on 25/04/25.
//
import SwiftUI
import Foundation
import Combine

// Base URL for all API calls
struct APIConstants {
    static let baseURL = "https://hggzrg5w-8000.inc1.devtunnels.ms"
}

// MARK: - Request Models
struct OTPRequestForSignUp: Codable {
    let email: String
}

struct OTPVerificationRequest: Codable {
    let email: String
    let otp: String
    let patient_name: String
    let patient_mobile: String
}

// MARK: - Response Models
struct OTPResponse: Codable {
    let message: String
    let status: String
}

struct AuthenticationResponse: Codable {
    let message: String
    let patient_id: Int?
    let access_token: String?
    let refresh_token: String?
}

struct UpdateProfileRequest: Codable {
    let patient_dob: String
    let patient_gender: Bool
    let patient_blood_group: String
    let patient_address: String?
}

struct ProfileUpdateResponse: Codable {
    let message: String
    let created: Bool
}

struct PatientProfileResponse: Codable {
    let patient_id: Int
    let patient_name: String
    let patient_email: String
    let patient_mobile: String
    let patient_remark: String?
    let patient_dob: String
    let patient_gender: Bool
    let patient_blood_group: String?
    let patient_address: String?
    let profile_photo: String?
}

// MARK: - Error Handling
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
    case unknownError
    case unauthorized
}

// MARK: - Authentication Service
class AuthenticationService {
    static let shared = AuthenticationService()
    
    func requestOTP(email: String) -> AnyPublisher<OTPResponse, Error> {
        guard let url = URL(string: "\(APIConstants.baseURL)/api/accounts/request-otp/") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        let otpRequest = OTPRequestForSignUp(email: email)
        guard let jsonData = try? JSONEncoder().encode(otpRequest) else {
            return Fail(error: NetworkError.unknownError).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                if 200..<300 ~= httpResponse.statusCode {
                    return data
                } else {
                    if let errorMessage = String(data: data, encoding: .utf8) {
                        throw NetworkError.serverError(errorMessage)
                    } else {
                        throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
                    }
                }
            }
            .decode(type: OTPResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return NetworkError.decodingError
                }
                return error
            }
            .eraseToAnyPublisher()
    }
    
    func verifyOTP(email: String, otp: String, patientName: String, patientMobile: String) -> AnyPublisher<AuthenticationResponse, Error> {
        guard let url = URL(string: "\(APIConstants.baseURL)/api/accounts/patient-signup/") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        let verificationRequest = OTPVerificationRequest(
            email: email,
            otp: otp,
            patient_name: patientName,
            patient_mobile: patientMobile
        )
        
        guard let jsonData = try? JSONEncoder().encode(verificationRequest) else {
            return Fail(error: NetworkError.unknownError).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                if 200..<300 ~= httpResponse.statusCode {
                    return data
                } else {
                    if let errorMessage = String(data: data, encoding: .utf8) {
                        throw NetworkError.serverError(errorMessage)
                    } else {
                        throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
                    }
                }
            }
            .decode(type: AuthenticationResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    return NetworkError.decodingError
                }
                return error
            }
            .eraseToAnyPublisher()
    }
    
    func updatePatientProfile(dob: Date, gender: String, bloodGroup: String) -> AnyPublisher<ProfileUpdateResponse, Error> {
        print("🚀 Starting updatePatientProfile")

        guard let url = URL(string: "\(APIConstants.baseURL)/api/accounts/patient/update-profile/") else {
            print("❌ Invalid URL")
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        print("🌐 URL: \(url)")

        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("❌ Authentication token not found")
            return Fail(error: NetworkError.serverError("Authentication token not found")).eraseToAnyPublisher()
        }
        print("🔐 Token: \(token)")

        let genderBoolean = (gender == "Male")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDob = dateFormatter.string(from: dob)

        let formParams: [String: String] = [
            "patient_dob": formattedDob,
            "patient_gender": genderBoolean ? "true" : "false",
            "patient_blood_group": bloodGroup,
            "patient_address": "123 Main St" // Example address
            // Add other fields like "patient_address" here if needed
        ]

        let formBody = formParams
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")

        print("📦 Form Body: \(formBody)")

        guard let httpBody = formBody.data(using: .utf8) else {
            print("❌ Failed to encode form body")
            return Fail(error: NetworkError.unknownError).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = httpBody
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        print("📤 Sending form-data request...")

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid HTTP response")
                    throw NetworkError.invalidResponse
                }

                print("📥 Received response with status: \(httpResponse.statusCode)")

                switch httpResponse.statusCode {
                case 401:
                    throw NetworkError.serverError("Authentication token expired")
                case 403:
                    throw NetworkError.serverError("Forbidden - Invalid permissions")
                case 400...499:
                    if let errorMessage = String(data: data, encoding: .utf8) {
                        print("⚠️ Client error: \(errorMessage)")
                        throw NetworkError.serverError(errorMessage)
                    }
                    fallthrough
                default:
                    if !(200..<300).contains(httpResponse.statusCode) {
                        throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
                    }
                }

                return data
            }
            .decode(type: ProfileUpdateResponse.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if let decodingError = error as? DecodingError {
                    print("❌ Decoding error: \(decodingError)")
                    return .decodingError
                } else if let networkError = error as? NetworkError {
                    print("❌ Network error: \(networkError)")
                    return networkError
                }
                print("❌ Unknown error: \(error)")
                return .unknownError
            }
            .eraseToAnyPublisher()
    }

    // func getPatientProfile() -> AnyPublisher<Patient, Error> {
    //     print("🔍 Fetching patient profile")
        
    //     guard let url = URL(string: "\(APIConstants.baseURL)/api/accounts/patient/profile/") else {
    //         print("❌ Invalid URL")
    //         return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
    //     }
        
    //     // Get token from UserDefaults
    //     guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
    //         print("❌ Authentication token not found")
    //         return Fail(error: NetworkError.serverError("Authentication token not found")).eraseToAnyPublisher()
    //     }
    //     print("🔐 Using token: \(token.prefix(15))...")
        
    //     var request = URLRequest(url: url)
    //     request.httpMethod = "GET"
    //     request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
    //     return URLSession.shared.dataTaskPublisher(for: request)
    //         .tryMap { data, response in
    //             guard let httpResponse = response as? HTTPURLResponse else {
    //                 throw NetworkError.invalidResponse
    //             }
                
    //             print("📥 Response code: \(httpResponse.statusCode)")
                
    //             if 200..<300 ~= httpResponse.statusCode {
    //                 return data
    //             } else {
    //                 if let errorMessage = String(data: data, encoding: .utf8) {
    //                     throw NetworkError.serverError(errorMessage)
    //                 } else {
    //                     throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
    //                 }
    //             }
    //         }
    //         .decode(type: PatientProfileResponse.self, decoder: JSONDecoder())
    //         .mapError { error in
    //             if let decodingError = error as? DecodingError {
    //                 print("❌ Decoding error: \(decodingError)")
    //                 return NetworkError.decodingError
    //             }
    //             return error
    //         }
    //         .map { response -> Patient in
    //             // Convert API response to Patient model
    //             let dateFormatter = DateFormatter()
    //             dateFormatter.dateFormat = "yyyy-MM-dd"
    //             let patientDob = dateFormatter.date(from: response.patient_dob) ?? Date()
                
    //             return Patient(
    //                 id: "\(response.patient_id)",
    //                 patient_id: "\(response.patient_id)",
    //                 patient_name: response.patient_name,
    //                 patient_email: response.patient_email,
    //                 patient_mobile: response.patient_mobile,
    //                 patient_remark: response.patient_remark,
    //                 patient_dob: patientDob,
    //                 patient_gender: response.patient_gender ? "Male" : "Female",
    //                 patient_blood_group: response.patient_blood_group,
    //                 patient_address: response.patient_address ?? "",
    //                 patient_photo: nil
    //             )
    //         }
    //         .eraseToAnyPublisher()
    // }
}

