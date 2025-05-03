//
//  AuthService.swift
//  Hospitality
//
//  Created by admin33 on 26/04/25.
//

import SwiftUI
import Combine
import Foundation

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
        let success: Bool
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

// MARK: - Request and Response Models
struct CreateDoctorRequest: Codable {
    let staff_name: String
    let staff_mobile: String
    let staff_joining_date: String
    let staff_email: String
    let license: String
    let experience_years: Int
    let staff_qualification: String
    let doctor_type_id: Int
    let staff_dob: String
    let staff_address: String
    let specialization: String
    
    // Helper to format date
    static func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

struct CreateDoctorResponse: Codable {
    let message: String
    let staff_id: String
}

// MARK: - Error Handling
enum DoctorCreationError: Error {
    case invalidURL
    case unauthorized
    case serverError(String)
    case decodingError
    case unknownError
}

struct DoctorListResponse: Codable {
    let staff_id: String
    let staff_name: String
    let staff_email: String
    let staff_mobile: String
    let specialization: String
    let license: String
    let experience_years: Int
    let doctor_type: String
    let on_leave: Bool
    
    // Add CodingKeys if needed to match your API response
    enum CodingKeys: String, CodingKey {
        case staff_id
        case staff_name
        case staff_email
        case staff_mobile
        case specialization
        case license
        case experience_years
        case doctor_type
        case on_leave
    }
}

struct SpecificDoctorResponse: Codable {
    let staff_id: String
    let staff_name: String
    let staff_email: String
    let staff_mobile: String
    let created_at: String
    let specialization: String
    let license: String
    let experience_years: Int
    let doctor_type: String
    let on_leave: Bool
    let staff_dob: String
    let staff_address: String
    let staff_qualification: String
}

struct PatientDoctorListResponse: Codable {
    let staff_id: String
    let staff_name: String
    let specialization: String
    let doctor_type: String
    let on_leave: Bool
}

struct PatientSpecificDoctorResponse: Codable {
    let staff_id: String
    let staff_name: String
    let specialization: String
    let doctor_type: String
    let on_leave: Bool
}

struct PatientSlotListResponse: Codable {
    let slot_id: Int
    let slot_start_time: String
    let slot_duration: Int
    let is_booked: Bool
}

struct PatientAppointRequest: Codable {
    let date: String
    let staff_id: String
    let slot_id: Int
    let reason: String
}

struct PatientAppointResponse: Codable {
    let message: String
    let appointment_id: Int
}

struct PatientAppointHistoryListResponse: Identifiable, Codable {
    let appointment_id: Int
    let date: String
    let slot_id: Int
    let staff_id: String
    let patient_id: Int
    let status: String
    let reason: String?

    var id: Int { appointment_id } // 👈 Add this
}

struct DoctorShiftRequest: Codable {
    let shift_id: Int
    let date: String
}

struct DoctorShiftResponse: Codable {
    let message: String
}

class AuthService {
    static let shared = AuthService()
    static let baseURL = Constants.baseURL

    func requestOTP(email: String, password: String, userType: String) -> AnyPublisher<AdminLoginResponse.OtpResponse, Error> {
        let url = URL(string: "\(AuthService.baseURL)/accounts/login/")!
        let requestBody = AdminLoginRequest.OTPRequest(
            email: email,
            user_type: userType,
            password: password
        )
        
        // Add debug print
        print("Sending OTP request with: \(requestBody)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(requestBody)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Print the raw request body for debugging
        if let body = request.httpBody {
            print("Request body: \(String(data: body, encoding: .utf8) ?? "Unable to decode")")
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                let rawString = String(data: output.data, encoding: .utf8) ?? "No data"
                print("Raw OTP response: \(rawString)")
                
                if httpResponse.statusCode == 200 {
                    do {
                        let response = try JSONDecoder().decode(AdminLoginResponse.OtpResponse.self, from: output.data)
                        return response
                    } catch {
                        print("Decoding error: \(error)")
                        if let errorResponse = try? JSONDecoder().decode([String: String].self, from: output.data) {
                            throw NSError(domain: "", code: httpResponse.statusCode,
                                        userInfo: [NSLocalizedDescriptionKey: errorResponse["message"] ?? "Invalid response format"])
                        }
                        throw error
                    }
                } else {
                    if let errorResponse = try? JSONDecoder().decode([String: String].self, from: output.data) {
                        throw NSError(domain: "", code: httpResponse.statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: errorResponse["message"] ?? "Unknown error"])
                    }
                    throw URLError(.badServerResponse)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func verifyOTP(email: String, otp: String, userType: String) -> AnyPublisher<AdminLoginResponse.LoginResponse, Error> {
        let url = URL(string: "\(AuthService.baseURL)/accounts/verify-login-otp/")!
        let requestBody = AdminLoginRequest.LoginRequest(
            email: email,
            otp: otp,
            user_type: userType
        )
        
        print("Sending OTP verification request: \(requestBody)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(requestBody)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse else {
                    print("VerifyOTP: No HTTP response received")
                    throw URLError(.badServerResponse)
                }
                
                let rawString = String(data: output.data, encoding: .utf8) ?? "No data"
                print("VerifyOTP: Raw login response (status: \(httpResponse.statusCode)): \(rawString)")
                
                if httpResponse.statusCode == 200 {
                    do {
                        let response = try JSONDecoder().decode(AdminLoginResponse.LoginResponse.self, from: output.data)
                        print("VerifyOTP: Decoded response: \(response)")
                        return response
                    } catch {
                        print("VerifyOTP: Decoding error: \(error)")
                        if let errorResponse = try? JSONDecoder().decode([String: String].self, from: output.data) {
                            throw NSError(domain: "", code: httpResponse.statusCode,
                                        userInfo: [NSLocalizedDescriptionKey: errorResponse["message"] ?? "Invalid response format"])
                        }
                        throw error
                    }
                } else {
                    print("VerifyOTP: Non-200 status code: \(httpResponse.statusCode)")
                    if let errorResponse = try? JSONDecoder().decode([String: String].self, from: output.data) {
                        throw NSError(domain: "", code: httpResponse.statusCode,
                                    userInfo: [NSLocalizedDescriptionKey: errorResponse["message"] ?? "Unknown error"])
                    }
                    throw URLError(.badServerResponse)
                }
            }
            .eraseToAnyPublisher()
    }
}

class DoctorService {
    static let shared = DoctorService()
    private let baseURL = Constants.baseURL
    
    func createDoctor(
        name: String,
        email: String,
        mobile: String,
        specialization: String,
        license: String,
        experienceYears: Int,
        doctorTypeId: Int,
        joiningDate: Date,
        dob: String,
        address: String,
        qualifications: String,
        completion: @escaping (Result<CreateDoctorResponse, DoctorCreationError>) -> Void
    ) {
        // Format the joining date
        let joiningDateString = CreateDoctorRequest.formattedDate(from: joiningDate)
        
        // Create request body
        let requestBody = CreateDoctorRequest(
            staff_name: name,
            staff_mobile: mobile,
            staff_joining_date: joiningDateString,
            staff_email: email,
            license: license,
            experience_years: experienceYears,
            staff_qualification: qualifications,
            doctor_type_id: doctorTypeId,
            staff_dob: dob,
            staff_address: address,
            specialization: specialization
        )
        
        print(requestBody)
        // Create URL
        guard let url = URL(string: "\(baseURL)/hospital/admin/doctors/create/") else {
            completion(.failure(.invalidURL))
            return
        }
        print("\(UserDefaults.accessToken)")
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            completion(.failure(.decodingError))
            return
        }
        
        // Make the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network errors
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            
            // Check for valid HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknownError))
                return
            }
            
            // Check for unauthorized
            if httpResponse.statusCode == 401 {
                completion(.failure(.unauthorized))
                return
            }
            
            // Check for successful response
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                completion(.failure(.serverError(errorMessage)))
                return
            }
            
            // Decode the response
            do {
                let response = try JSONDecoder().decode(CreateDoctorResponse.self, from: data)
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func fetchDoctors(completion: @escaping (Result<[DoctorListResponse], DoctorCreationError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/hospital/admin/doctors/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknownError))
                return
            }
            
            if httpResponse.statusCode == 401 {
                completion(.failure(.unauthorized))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                completion(.failure(.serverError(errorMessage)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode([DoctorListResponse].self, from: data)
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func fetchDoctorsForPatient(completion: @escaping (Result<[PatientDoctorListResponse], DoctorCreationError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/hospital/general/doctors/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.unknownError))
                return
            }
            
            if httpResponse.statusCode == 401 {
                completion(.failure(.unauthorized))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                completion(.failure(.serverError(errorMessage)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode([PatientDoctorListResponse].self, from: data)
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}

extension UserDefaults {
    private enum Keys {
        static let isLoggedIn = "isLoggedIn"
        static let userId = "userId"
        static let userType = "userType"
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let email = "email"
    }
    
    static var isLoggedIn: Bool {
        get { standard.bool(forKey: Keys.isLoggedIn) }
        set { standard.set(newValue, forKey: Keys.isLoggedIn) }
    }
    
    static var userId: String {
        get { standard.string(forKey: Keys.userId) ?? "" }
        set { standard.set(newValue, forKey: Keys.userId) }
    }
    
    static var userType: String {
        get { standard.string(forKey: Keys.userType) ?? "" }
        set { standard.set(newValue, forKey: Keys.userType) }
    }
    
    static var accessToken: String {
        get { standard.string(forKey: Keys.accessToken) ?? "" }
        set { standard.set(newValue, forKey: Keys.accessToken) }
    }
    
    static var refreshToken: String {
        get { standard.string(forKey: Keys.refreshToken) ?? "" }
        set { standard.set(newValue, forKey: Keys.refreshToken) }
    }
    
    static var email: String {
        get { standard.string(forKey: Keys.email) ?? "" }
        set { standard.set(newValue, forKey: Keys.email) }
    }
    
    static func clearAuthData() {
        let keys = [Keys.isLoggedIn, Keys.userId, Keys.userType, Keys.accessToken, Keys.refreshToken, Keys.email]
        keys.forEach { standard.removeObject(forKey: $0) }
    }
}
