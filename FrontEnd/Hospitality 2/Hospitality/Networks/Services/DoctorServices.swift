//import Foundation
//
//class DoctorServices {
//    private let baseURL = Constants.baseURL
//    private let endpoints = DoctorEndpoints.DoctorShift()
//    
//    // MARK: - Fetch Doctor Shifts
//    func fetchDoctorShifts(doctorId: String) async throws -> [DoctorResponse.PatientDoctorSlotResponse] {
//        guard let url = URL(string: baseURL + DoctorEndpoints.DoctorShift.shifts(doctorId: doctorId)) else {
//            throw NetworkError.invalidURL
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
//            throw NetworkError.unauthorized
//        }
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NetworkError.invalidResponse
//        }
//        
//        switch httpResponse.statusCode {
//        case 200...299:
//            do {
//                let decoder = JSONDecoder()
//                return try decoder.decode([DoctorResponse.PatientDoctorSlotResponse].self, from: data)
//            } catch {
//                print("Decoding error: \(error)")
//                throw NetworkError.decodingError
//            }
//        case 401:
//            throw NetworkError.unauthorized
//        default:
//            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
//        }
//    }
//    
//    // MARK: - Fetch Doctor Appointment History
//    func fetchDoctorAppointmentHistory() async throws -> [DoctorResponse.DocAppointment] {
//        guard let url = URL(string: baseURL + DoctorEndpoints.Appointment.history) else {
//            throw NetworkError.invalidURL
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
//            throw NetworkError.unauthorized
//        }
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NetworkError.invalidResponse
//        }
//        
//        switch httpResponse.statusCode {
//        case 200...299:
//            do {
//                let decoder = JSONDecoder()
//                return try decoder.decode([DoctorResponse.DocAppointment].self, from: data)
//            } catch {
//                print("Decoding error: \(error)")
//                throw NetworkError.decodingError
//            }
//        case 401:
//            throw NetworkError.unauthorized
//        default:
//            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
//        }
//    }
//    
//    // MARK: - Fetch Patient Profile
//    func fetchPatientProfile(patientId: String) async throws -> DoctorResponse.PatientProfile {
//        guard let url = URL(string: baseURL + DoctorEndpoints.Patient.profile(patientId: patientId)) else {
//            throw NetworkError.invalidURL
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
//            throw NetworkError.unauthorized
//        }
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NetworkError.invalidResponse
//        }
//        
//        switch httpResponse.statusCode {
//        case 200...299:
//            do {
//                let decoder = JSONDecoder()
//                return try decoder.decode(DoctorResponse.PatientProfile.self, from: data)
//            } catch {
//                print("Decoding error: \(error)")
//                throw NetworkError.decodingError
//            }
//        case 401:
//            throw NetworkError.unauthorized
//        default:
//            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
//        }
//    }
//    
//    // MARK: - Fetch Patient Latest Vitals
//    func fetchPatientLatestVitals(patientId: String) async throws -> DoctorResponse.DocGetLatestPatientVitals {
//        guard let url = URL(string: baseURL + DoctorEndpoints.Patient.latestVitals(patientId: patientId)) else {
//            throw NetworkError.invalidURL
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
//            throw NetworkError.unauthorized
//        }
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NetworkError.invalidResponse
//        }
//        
//        switch httpResponse.statusCode {
//        case 200...299:
//            do {
//                let decoder = JSONDecoder()
//                return try decoder.decode(DoctorResponse.DocGetLatestPatientVitals.self, from: data)
//            } catch {
//                print("Decoding error: \(error)")
//                throw NetworkError.decodingError
//            }
//        case 401:
//            throw NetworkError.unauthorized
//        default:
//            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
//        }
//    }
//    
//    // MARK: - Enter Vitals
//    func enterVitals(appointmentId: Int, vitals: [String: Any]) async throws -> DoctorResponse.EnterVitals {
//        guard let url = URL(string: baseURL + DoctorEndpoints.Appointment.vitals(appointmentId: String(appointmentId))) else {
//            throw NetworkError.invalidURL
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
//            throw NetworkError.unauthorized
//        }
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        
//        let bodyData = try JSONSerialization.data(withJSONObject: vitals, options: [])
//        request.httpBody = bodyData
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NetworkError.invalidResponse
//        }
//        
//        switch httpResponse.statusCode {
//        case 200...299:
//            do {
//                let decoder = JSONDecoder()
//                return try decoder.decode(DoctorResponse.EnterVitals.self, from: data)
//            } catch {
//                print("Decoding error: \(error)")
//                throw NetworkError.decodingError
//            }
//        case 401:
//            throw NetworkError.unauthorized
//        default:
//            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
//        }
//    }
//    
//    // MARK: - Handle Diagnosis
//    func handleDiagnosis(diagnosisId: Int) async throws -> DoctorResponse.DiagnosisResponse {
//        guard let url = URL(string: "https://your-api-endpoint/diagnosis/\(diagnosisId)") else {
//            throw NetworkError.invalidURL
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NetworkError.invalidResponse
//        }
//        
//        switch httpResponse.statusCode {
//        case 200...299:
//            let decoder = JSONDecoder()
//            return try decoder.decode(DoctorResponse.DiagnosisResponse.self, from: data)
//        default:
//            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
//        }
//    }
//}

import Foundation

class DoctorServices {
    private let baseURL = Constants.baseURL2
    
    // Use the secure session for all requests
    private var session: URLSession {
        URLSession.ngrokSession
    }
    
    // Helper method to build URLs properly
    private func buildURL(endpoint: String) -> URL? {
        // Ensure baseURL ends with a slash and endpoint doesn't begin with one
        let base = baseURL.hasSuffix("/") ? baseURL : baseURL + "/"
        let path = endpoint.hasPrefix("/") ? String(endpoint.dropFirst()) : endpoint
        
        let urlString = base + path
        print("[SwatiSwapna] Building URL: \(urlString)")
        return URL(string: urlString)
    }
    
    // MARK: - Fetch Doctor Shifts
    func fetchDoctorShifts(doctorId: String) async throws -> [DoctorResponse.PatientDoctorSlotResponse] {
        guard let url = buildURL(endpoint: DoctorEndpoints.DoctorShift.shifts(doctorId: doctorId)) else {
            print("[SwatiSwapna] Invalid URL for doctor shifts")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        // Create the request body with the required fields
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        // The API expects a date field according to SelectShiftRequest
        let requestBody: [String: Any] = [
            "date": today
        ]
        
        // Convert to JSON data
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        print("[SwatiSwapna] Fetching doctor shifts with POST from: \(url.absoluteString)")
        print("[SwatiSwapna] Request body: \(requestBody)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("[SwatiSwapna] Doctor shifts response status: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("[SwatiSwapna] Response data: \(responseString)")
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode([DoctorResponse.PatientDoctorSlotResponse].self, from: data)
                print("[SwatiSwapna] Successfully decoded \(result.count) shifts")
                return result
            } catch {
                print("[SwatiSwapna] Decoding error: \(error)")
                if let rawData = String(data: data, encoding: .utf8) {
                    print("[SwatiSwapna] Raw response: \(rawData)")
                }
                throw NetworkError.decodingError
            }
        case 401:
            print("[SwatiSwapna] Unauthorized access - token may be invalid")
            throw NetworkError.unauthorized
        default:
            if let errorData = String(data: data, encoding: .utf8) {
                print("[SwatiSwapna] Server error: \(errorData)")
            }
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Fetch Doctor Slots
    func fetchDoctorSlots(doctorId: String, date: String) async throws -> [DoctorResponse.PatientDoctorSlotResponse] {
        guard let url = buildURL(endpoint: DoctorEndpoints.DoctorSlots.slots(doctorId: doctorId, date: date)) else {
            print("[SwatiSwapna] Invalid URL for doctor slots")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        print("[SwatiSwapna] Fetching doctor slots from: \(url.absoluteString)")
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("[SwatiSwapna] Doctor slots response status: \(httpResponse.statusCode)")
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode([DoctorResponse.PatientDoctorSlotResponse].self, from: data)
                print("[SwatiSwapna] Successfully decoded \(result.count) slots")
                return result
            } catch {
                print("[SwatiSwapna] Decoding error: \(error)")
                if let rawData = String(data: data, encoding: .utf8) {
                    print("[SwatiSwapna] Raw response: \(rawData)")
                }
                throw NetworkError.decodingError
            }
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Fetch Doctor Appointment History
    func fetchDoctorAppointmentHistory() async throws -> [DoctorResponse.DocAppointment] {
        guard let url = buildURL(endpoint: DoctorEndpoints.Appointment.history) else {
            print("[SwatiSwapna] Invalid URL for appointment history")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        print("[SwatiSwapna] Fetching appointment history from: \(url.absoluteString)")
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("[SwatiSwapna] Appointment history status: \(httpResponse.statusCode)")
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode([DoctorResponse.DocAppointment].self, from: data)
                print("[SwatiSwapna] Successfully decoded \(result.count) appointments")
                return result
            } catch {
                print("[SwatiSwapna] Decoding error: \(error)")
                if let rawData = String(data: data, encoding: .utf8) {
                    print("[SwatiSwapna] Raw response: \(rawData)")
                }
                throw NetworkError.decodingError
            }
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Fetch Patient Profile
    func fetchPatientProfile(patientId: String) async throws -> DoctorResponse.PatientProfile {
        guard let url = buildURL(endpoint: DoctorEndpoints.Patient.profile(patientId: patientId)) else {
            print("[SwatiSwapna] Invalid URL for patient profile")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        print("[SwatiSwapna] Fetching patient profile from: \(url.absoluteString)")
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("[SwatiSwapna] Patient profile status: \(httpResponse.statusCode)")
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                let profile = try decoder.decode(DoctorResponse.PatientProfile.self, from: data)
                print("[SwatiSwapna] Successfully decoded patient profile for patient \(profile.patientId)")
                return profile
            } catch {
                print("[SwatiSwapna] Decoding error: \(error)")
                if let rawData = String(data: data, encoding: .utf8) {
                    print("[SwatiSwapna] Raw response: \(rawData)")
                }
                throw NetworkError.decodingError
            }
        case 401:
            print("[SwatiSwapna] Unauthorized access when fetching patient profile")
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Fetch Patient Latest Vitals
    func fetchPatientLatestVitals(patientId: String) async throws -> DoctorResponse.DocGetLatestPatientVitals {
        guard let url = buildURL(endpoint: DoctorEndpoints.Patient.latestVitals(patientId: patientId)) else {
            print("[SwatiSwapna] Invalid URL for patient vitals")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        print("[SwatiSwapna] Fetching latest vitals from: \(url.absoluteString)")
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("[SwatiSwapna] Latest vitals status: \(httpResponse.statusCode)")
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                let vitals = try decoder.decode(DoctorResponse.DocGetLatestPatientVitals.self, from: data)
                print("[SwatiSwapna] Successfully decoded patient vitals from \(vitals.createdAt)")
                return vitals
            } catch {
                print("[SwatiSwapna] Decoding error: \(error)")
                if let rawData = String(data: data, encoding: .utf8) {
                    print("[SwatiSwapna] Raw vitals response: \(rawData)")
                }
                throw NetworkError.decodingError
            }
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Enter Vitals
    func enterVitals(appointmentId: Int, vitals: PostVitals) async throws -> DoctorResponse.EnterVitals {
        guard let url = buildURL(endpoint: DoctorEndpoints.Appointment.vitals(appointmentId: String(appointmentId))) else {
            print("[SwatiSwapna] Invalid URL for entering vitals")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        // Use the PostVitals struct directly
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(vitals)
        
        print("[SwatiSwapna] Posting vitals to: \(url.absoluteString)")
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("[SwatiSwapna] Enter vitals status: \(httpResponse.statusCode)")
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(DoctorResponse.EnterVitals.self, from: data)
                print("[SwatiSwapna] Successfully entered vitals: \(result.message)")
                return result
            } catch {
                print("[SwatiSwapna] Decoding error when entering vitals: \(error)")
                throw NetworkError.decodingError
            }
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Enter Diagnosis
    func enterDiagnosis(appointmentId: String, diagnosisData: EnterDiagnosisRequest) async throws -> DoctorResponse.DiagnosisResponse {
        guard let url = buildURL(endpoint: DoctorEndpoints.Appointment.diagnosis(appointmentId: appointmentId)) else {
            print("[SwatiSwapna] Invalid URL for entering diagnosis")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        // Use the EnterDiagnosisRequest struct directly
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(diagnosisData)
        
        print("[SwatiSwapna] Posting diagnosis to: \(url.absoluteString)")
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("[SwatiSwapna] Enter diagnosis status: \(httpResponse.statusCode)")
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(DoctorResponse.DiagnosisResponse.self, from: data)
                print("[SwatiSwapna] Successfully entered diagnosis with ID: \(result.diagnosisId)")
                return result
            } catch {
                print("[SwatiSwapna] Decoding error when entering diagnosis: \(error)")
                throw NetworkError.decodingError
            }
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Enter Prescription
    func enterPrescription(appointmentId: String, prescription: PrescriptionRequest) async throws -> DoctorResponse.PrescriptionResponse {
        guard let url = buildURL(endpoint: DoctorEndpoints.Appointment.prescription(appointmentId: appointmentId)) else {
            print("[SwatiSwapna] Invalid URL for entering prescription")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        // Use the PrescriptionRequest struct directly
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(prescription)
        
        print("[SwatiSwapna] Posting prescription to: \(url.absoluteString)")
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("[SwatiSwapna] Enter prescription status: \(httpResponse.statusCode)")
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(DoctorResponse.PrescriptionResponse.self, from: data)
                print("[SwatiSwapna] Successfully entered prescription: \(result.message)")
                return result
            } catch {
                print("[SwatiSwapna] Decoding error when entering prescription: \(error)")
                throw NetworkError.decodingError
            }
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
    
    func handleDiagnosis(diagnosisId: Int) async throws -> DoctorResponse.DiagnosisResponse {
        guard let url = buildURL(endpoint: "api/hospital/general/diagnosis/\(diagnosisId)") else {
            print("[SwatiSwapna] Invalid URL for handling diagnosis")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        print("[SwatiSwapna] Fetching diagnosis details from: \(url.absoluteString)")
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("[SwatiSwapna] Diagnosis details status: \(httpResponse.statusCode)")
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            let result = try decoder.decode(DoctorResponse.DiagnosisResponse.self, from: data)
            print("[SwatiSwapna] Successfully fetched diagnosis details")
            return result
        default:
            if let errorData = String(data: data, encoding: .utf8) {
                print("[SwatiSwapna] Server error: \(errorData)")
            }
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
}
