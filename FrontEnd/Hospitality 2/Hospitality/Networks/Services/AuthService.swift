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

enum DoctorCreationError: Error {
    case invalidURL
    case encodingError
    case decodingError
    case serverError(String)
    case unauthorized
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
    let doctor_type_id: Int?
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
        case doctor_type_id
        case on_leave
    }
}

struct SpecificDoctorResponse: Codable {
    var staff_id: String
    var staff_name: String
    var staff_email: String
    var staff_mobile: String
    var created_at: String
    var specialization: String
    var license: String
    var experience_years: Int
    var doctor_type: DoctorType
    var on_leave: Bool
    var staff_dob: String
    var staff_address: String?
    var staff_qualification: String
    var profile_photo: String?
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

struct EditDoctorRequest: Codable {
    let staff_name: String
    let staff_email: String
    let staff_mobile: String
    let on_leave: Bool
    let specialization: String
    let license: String
    let experience_years: Int
    let doctor_type_id: Int
    let staff_dob: String
    let staff_address: String?
    let staff_qualification: String
    let profile_photo: String?
    
    // Helper initializer
    init(
        staff_name: String,
        staff_email: String,
        staff_mobile: String,
        on_leave: Bool,
        specialization: String,
        license: String,
        experience_years: Int,
        doctor_type_id: Int,
        staff_dob: String,
        staff_address: String?,
        staff_qualification: String,
        profile_photo: String
    ) {
        self.staff_name = staff_name
        self.staff_email = staff_email
        self.staff_mobile = staff_mobile
        self.on_leave = on_leave
        self.specialization = specialization
        self.license = license
        self.experience_years = experience_years
        self.doctor_type_id = doctor_type_id
        self.staff_dob = staff_dob
        self.staff_address = staff_address
        self.staff_qualification = staff_qualification
        self.profile_photo = profile_photo
    }
}

struct EditDoctorResponse: Codable {
    let message: String
}

struct createLabTechRequest: Codable {
    let staff_name: String
    let staff_email: String
    let staff_mobile: String
    let certification: String
    let lab_experience_years: Int
    let assigned_lab: String
    let staff_joining_date: String
}

struct createLabTechResponse: Codable {
    let message: String
    let staff_id: String
}

struct LabTechListResponse: Codable {
    let staff_id: String
    let staff_name: String
    let staff_email: String
    let staff_mobile: String
    let certification: String
    let lab_experience_years: Int
    let assigned_lab: String
    let on_leave: Bool
}

struct SpecificLabTechResponse: Codable {
    let staff_id: String
    let staff_name: String
    let staff_email: String
    let staff_mobile: String
    let created_at: String
    let certification: String
    let lab_experience_years: Int
    let assigned_lab: String
    let on_leave: Bool
    let staff_dob: String?
    let staff_address: String?
    let staff_qualification: String?
    let profile_photo: String?
}

struct UpdateLabTechRequest {
    let staff_name: String
    let staff_email: String
    let staff_mobile: String
    let certification: String
    let lab_experience_years: Int
    let assigned_lab: String
    let on_leave: Bool
    let staff_dob: String?
    let staff_address: String?
    let staff_qualification: String?
    let profile_photo: Data?
}

struct UpdateLabTechResponse: Codable {
    let message: String
}

enum LabTechError: Error {
    case invalidURL
    case unauthorized
    case serverError(String)
    case decodingError
    case unknownError
}

struct DeleteLabTechResponse: Codable {
    let message: String
}

struct CreateLabRequest: Codable {
    let lab_name: String
    let lab_type: Int
    let functional: Bool
}

struct CreateLabResponse: Codable {
    let lab_id: Int
    let lab_name: String
    let lab_type: Int
    let lab_type_name: String
    let functional: Bool
}

struct AppointmentListResponsefetch: Codable, Identifiable {
    let id: Int // Conform to Identifiable
    let patient: Int
    let patient_name: String
    let staff: String
    let staff_name: String
    let slot: Int
    let slot_start_time: String
    let created_at: String
    let status: String
    let reason: String
    let lab_tests: [LabTestResponsefetch]
    
    // Custom CodingKeys to map 'id' to 'appointment_id' in JSON
    enum CodingKeys: String, CodingKey {
        case id = "appointment_id"
        case patient
        case patient_name
        case staff
        case staff_name
        case slot
        case slot_start_time
        case created_at
        case status
        case reason
        case lab_tests
    }
}

struct LabTestResponsefetch: Codable {
    let lab_test_id: Int
    let test_type: String
    let test_datetime: String
    let priority: String
    let test_result: TestResultResponsefetch?
    let is_paid: Bool
}

struct TestResultResponsefetch: Codable {
    let notes: String?
    let platelets: Int?
    let rbc_count: Double?
    let wbc_count: Int?
    let hemoglobin: Double?
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
    
    func updateDoctor(
        staffId: String,
        request: EditDoctorRequest,
        completion: @escaping (Result<EditDoctorResponse, DoctorCreationError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/hospital/admin/doctors/\(staffId)/") else {
            print("Invalid URL: \(baseURL)/hospital/admin/doctors/\(staffId)/")
            completion(.failure(.invalidURL))
            return
        }
        
        guard !UserDefaults.accessToken.isEmpty else {
            print("Missing access token")
            completion(.failure(.unauthorized))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        
        // Set the Content-Type to multipart/form-data with a unique boundary
        let boundary = "Boundary-\(UUID().uuidString)"
        urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        // Create the form data body
        var body = Data()
        
        // Helper function to append form data fields
        func appendFormField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Append each field from the request
        appendFormField(name: "staff_name", value: request.staff_name)
        appendFormField(name: "staff_email", value: request.staff_email)
        appendFormField(name: "staff_mobile", value: request.staff_mobile)
        appendFormField(name: "on_leave", value: request.on_leave.description)
        appendFormField(name: "specialization", value: request.specialization)
        appendFormField(name: "license", value: request.license)
        appendFormField(name: "experience_years", value: "\(request.experience_years)")
        appendFormField(name: "doctor_type_id", value: "\(request.doctor_type_id)")
        appendFormField(name: "staff_dob", value: request.staff_dob)
        appendFormField(name: "staff_qualification", value: request.staff_qualification)
        
        if let address = request.staff_address {
            appendFormField(name: "staff_address", value: address)
        }
        
        if let profilePhoto = request.profile_photo {
            appendFormField(name: "profile_photo", value: profilePhoto)
        }
        
        // Close the form data
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        urlRequest.httpBody = body
        
        print("Request URL: \(url)")
        if let bodyString = String(data: body, encoding: .utf8) {
            print("Request Body: \(bodyString)")
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response: No HTTP response")
                completion(.failure(.unknownError))
                return
            }
            
            print("Response Status: \(httpResponse.statusCode)")
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    print("No response data")
                    completion(.failure(.serverError("No data received")))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(EditDoctorResponse.self, from: data)
                    print("Decoded Response: \(response)")
                    completion(.success(response))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(.decodingError))
                }
            case 401:
                print("Unauthorized request")
                completion(.failure(.unauthorized))
            case 400:
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Bad request"
                print("Bad request: \(errorMessage)")
                completion(.failure(.serverError("Bad request: \(errorMessage)")))
            case 403:
                print("Forbidden request")
                completion(.failure(.serverError("Forbidden")))
            default:
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                print("Unexpected status code: \(httpResponse.statusCode), message: \(errorMessage)")
                completion(.failure(.serverError("Unexpected status code: \(httpResponse.statusCode), message: \(errorMessage)")))
            }
        }.resume()
    }
    
    func deleteDoctor(doctorId: String, completion: @escaping (Result<Void, DoctorCreationError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/hospital/admin/doctors/\(doctorId)/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
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
            
            if httpResponse.statusCode == 204 {
                completion(.success(()))
            } else {
                completion(.failure(.serverError("Failed to delete doctor")))
            }
        }.resume()
    }
    
    func fetchSpecificDoctor(doctorId: String, completion: @escaping (Result<SpecificDoctorResponse, DoctorCreationError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/hospital/admin/doctors/\(doctorId)/") else {
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
                let response = try JSONDecoder().decode(SpecificDoctorResponse.self, from: data)
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

class LabTechnicianService: ObservableObject {
    static let shared = LabTechnicianService()
    private let baseURL = Constants.baseURL
    
    func createLabTechnician(
        name: String,
        email: String,
        mobile: String,
        certification: String,
        experienceYears: Int,
        assignedLab: String,
        joiningDate: Date,
        completion: @escaping (Result<createLabTechResponse, DoctorCreationError>) -> Void
    ) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let joiningDateString = formatter.string(from: joiningDate)
        
        let requestBody = createLabTechRequest(
            staff_name: name,
            staff_email: email,
            staff_mobile: mobile,
            certification: certification,
            lab_experience_years: experienceYears,
            assigned_lab: assignedLab,
            staff_joining_date: joiningDateString
        )
        
        guard let url = URL(string: "\(baseURL)/hospital/admin/lab-technicians/create/") else {
            completion(.failure(.invalidURL))
            return
        }
        
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
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No HTTP response")
                completion(.failure(.unknownError))
                return
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }
            
            if httpResponse.statusCode == 401 {
                print("Unauthorized access")
                completion(.failure(.unauthorized))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                print("Server error: \(errorMessage)")
                completion(.failure(.serverError(errorMessage)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(createLabTechResponse.self, from: data)
                print("Decoded Response: \(response)")
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func fetchLabTechnicians(completion: @escaping (Result<[LabTechListResponse], DoctorCreationError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/hospital/admin/lab-technicians/") else {
            print("Invalid URL: \(baseURL)/hospital/admin/lab-technicians/")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No HTTP response")
                completion(.failure(.unknownError))
                return
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }
            
            if httpResponse.statusCode == 401 {
                print("Unauthorized access")
                completion(.failure(.unauthorized))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                print("Server error: \(errorMessage)")
                completion(.failure(.serverError(errorMessage)))
                return
            }
            
            do {
                let response = try JSONDecoder().decode([LabTechListResponse].self, from: data)
                print("Decoded Response: \(response)")
                completion(.success(response))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func fetchSpecificLabTechnician(staffId: String, completion: @escaping (Result<SpecificLabTechResponse, DoctorCreationError>) -> Void) {
            guard let url = URL(string: "\(baseURL)/hospital/admin/lab-technicians/\(staffId)/") else {
                print("Invalid URL: \(baseURL)/hospital/admin/lab-technicians/\(staffId)/")
                completion(.failure(.invalidURL))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
            
            print("Fetching specific lab technician with ID: \(staffId)")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    completion(.failure(.serverError(error.localizedDescription)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("No HTTP response")
                    completion(.failure(.unknownError))
                    return
                }
                
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response Data: \(responseString)")
                }
                
                if httpResponse.statusCode == 401 {
                    print("Unauthorized access")
                    completion(.failure(.unauthorized))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode), let data = data else {
                    let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                    print("Server error: \(errorMessage)")
                    completion(.failure(.serverError(errorMessage)))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(SpecificLabTechResponse.self, from: data)
                    print("Decoded Response: \(response)")
                    completion(.success(response))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(.decodingError))
                }
            }.resume()
        }
        
    func updateLabTechnician(
        staffId: String,
        request: UpdateLabTechRequest,
        completion: @escaping (Result<UpdateLabTechResponse, LabTechError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/hospital/admin/lab-technicians/\(staffId)/") else {
            print("Invalid URL: \(baseURL)/hospital/admin/lab-technicians/\(staffId)/")
            completion(.failure(.invalidURL))
            return
        }
        
        guard !UserDefaults.accessToken.isEmpty else {
            print("Missing access token")
            completion(.failure(.unauthorized))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        
        // Set the Content-Type to multipart/form-data with a unique boundary
        let boundary = "Boundary-\(UUID().uuidString)"
        urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        // Create the form data body
        var body = Data()
        
        // Helper function to append form data fields
        func appendFormField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Append required fields from the request
        appendFormField(name: "staff_name", value: request.staff_name)
        appendFormField(name: "staff_email", value: request.staff_email)
        appendFormField(name: "staff_mobile", value: request.staff_mobile)
        appendFormField(name: "certification", value: request.certification)
        appendFormField(name: "lab_experience_years", value: "\(request.lab_experience_years)")
        appendFormField(name: "assigned_lab", value: request.assigned_lab)
        appendFormField(name: "on_leave", value: request.on_leave.description)
        
        // Append optional fields if they exist
        if let dob = request.staff_dob {
            appendFormField(name: "staff_dob", value: dob)
        }
        
        if let address = request.staff_address {
            appendFormField(name: "staff_address", value: address)
        }
        
        if let qualification = request.staff_qualification {
            appendFormField(name: "staff_qualification", value: qualification)
        }
        
        // Add image data if available
        if let imageData = request.profile_photo {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"profile_photo\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Close the form data
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        urlRequest.httpBody = body
        
        print("Request URL: \(url)")
        if let bodyString = String(data: body, encoding: .utf8) {
            print("Request Body: \(bodyString)")
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response: No HTTP response")
                completion(.failure(.unknownError))
                return
            }
            
            print("Response Status: \(httpResponse.statusCode)")
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    print("No response data")
                    completion(.failure(.serverError("No data received")))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(UpdateLabTechResponse.self, from: data)
                    print("Decoded Response: \(response)")
                    completion(.success(response))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(.decodingError))
                }
            case 401:
                print("Unauthorized request")
                completion(.failure(.unauthorized))
            case 400:
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Bad request"
                print("Bad request: \(errorMessage)")
                completion(.failure(.serverError("Bad request: \(errorMessage)")))
            case 403:
                print("Forbidden request")
                completion(.failure(.serverError("Forbidden")))
            default:
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                print("Unexpected status code: \(httpResponse.statusCode), message: \(errorMessage)")
                completion(.failure(.serverError("Unexpected status code: \(httpResponse.statusCode), message: \(errorMessage)")))
            }
        }.resume()
    }
    
    func deleteLabTechnician(staffId: String, completion: @escaping (Result<DeleteLabTechResponse, DoctorCreationError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/hospital/admin/lab-technicians/\(staffId)/") else {
            print("Invalid URL: \(baseURL)/hospital/admin/lab-technicians/\(staffId)/")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        print("Deleting lab technician with ID: \(staffId)")
        print("Request URL: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No HTTP response")
                completion(.failure(.unknownError))
                return
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }
            
            if httpResponse.statusCode == 401 {
                print("Unauthorized access")
                completion(.failure(.unauthorized))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                print("Server error: \(errorMessage)")
                completion(.failure(.serverError(errorMessage)))
                return
            }
            
            // For DELETE, we might not always get a response body
            if let data = data, !data.isEmpty {
                do {
                    let response = try JSONDecoder().decode(DeleteLabTechResponse.self, from: data)
                    print("Successfully deleted lab technician")
                    completion(.success(response))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(.decodingError))
                }
            } else {
                // If no response body, return a success with empty message
                completion(.success(DeleteLabTechResponse(message: "Successfully deleted")))
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
        static let staffSubRole = "staffSubRole"
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
    
    static var staffSubRole: String {
        get { standard.string(forKey: Keys.staffSubRole) ?? "doctor" }
        set { standard.set(newValue, forKey: Keys.staffSubRole) }
    }
    
    static func clearAuthData() {
        let keys = [Keys.isLoggedIn, Keys.userId, Keys.userType, Keys.accessToken, Keys.refreshToken, Keys.email]
        keys.forEach { standard.removeObject(forKey: $0) }
    }
    
    static var hasCompletedOnboarding: Bool {
        get { standard.bool(forKey: "hasCompletedOnboarding") }
        set { standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }
}
