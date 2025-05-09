import Foundation

class DoctorServices {
    private let baseURL = Constants.baseURL2
    
    // Use the secure session for all requests
    var session: URLSession {
        URLSession.ngrokSession
    }
    
    // Helper method to build URLs properly
    func buildURL(endpoint: String) -> URL? {
        // Ensure baseURL ends with a slash and endpoint doesn't begin with one
        let base = baseURL.hasSuffix("/") ? baseURL : baseURL + "/"
        let path = endpoint.hasPrefix("/") ? String(endpoint.dropFirst()) : endpoint
        
        let urlString = base + path
        print("[SwatiSwapna] Building URL: \(urlString)")
        return URL(string: urlString)
    }
    
    //
    func fetchAppointmentDetails(appointmentId: Int) async throws -> AppointmentDetailResponse {
        guard let url = URL(string: "http://ec2-13-127-223-203.ap-south-1.compute.amazonaws.com/api/hospital/general/appointments/\(appointmentId)/") else {
            print("[SwatiSwapna] Invalid URL for appointment details")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = UserDefaults.accessToken
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("[SwatiSwapna] Fetching details for appointmentId: \(appointmentId)")
        print("[SwatiSwapna] Constructed URL: \(url.absoluteString)")
        print("[SwatiSwapna] Request headers: \(request.allHTTPHeaderFields ?? [:])")
        print("[SwatiSwapna] Access token: \(token.isEmpty ? "Empty" : "Present")")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("[SwatiSwapna] Appointment details status: \(httpResponse.statusCode)")
        if let rawData = String(data: data, encoding: .utf8) {
            print("[SwatiSwapna] Raw response: \(rawData)")
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                let appointmentDetails = try decoder.decode(AppointmentDetailResponse.self, from: data)
                print("[SwatiSwapna] Successfully decoded appointment details for ID: \(appointmentDetails.appointmentId)")
                
                // Add these diagnostic prints
                print("[DEBUG] Appointment date from API: \(appointmentDetails.date)")
                
                // Log parsed date to verify format
                let isoFormatter = DateFormatter()
                isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                let simpleFormatter = DateFormatter()
                simpleFormatter.dateFormat = "yyyy-MM-dd"
                
                if let date = isoFormatter.date(from: appointmentDetails.date) {
                    print("[DEBUG] Successfully parsed as ISO date: \(date)")
                } else if let date = simpleFormatter.date(from: appointmentDetails.date) {
                    print("[DEBUG] Successfully parsed as simple date: \(date)")
                } else {
                    print("[DEBUG] Could not parse date format: \(appointmentDetails.date)")
                }
                
                return appointmentDetails
            } catch {
                print("[SwatiSwapna] Decoding error: \(error)")
                throw NetworkError.decodingError
            }
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound("Appointment with ID \(appointmentId) not found")
        default:
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
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
    func enterDiagnosis(appointmentId: Int, diagnosisData: DiagnosisRequest) async throws -> DoctorResponse.DiagnosisResponse {
        guard let url = buildURL(endpoint: DoctorEndpoints.Appointment.diagnosis(appointmentId: appointmentId)) else {
            print("[SwatiSwapna] Invalid URL for entering diagnosis")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        // Encode the diagnosis request
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
                print("[SwatiSwapna] Successfully entered diagnosis: \(result.message)")
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
    func enterPrescription(appointmentId: Int, prescription: PrescriptionRequest) async throws -> DoctorResponse.PrescriptionResponse {
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
    
    // MARK: - Recommend Lab Tests
    func recommendLabTests(appointmentId: Int, request: RecommendLabTestRequest) async throws -> DoctorResponse.RecommendLabTestResponse {
        guard let url = buildURL(endpoint: "api/hospital/general/appointments/\(appointmentId)/recommend-lab-tests/") else {
            print("[SwatiSwapna] Invalid URL for recommending lab tests")
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        // Modified to include lab_id
        let requestDict: [String: Any] = [
            "test_type_ids": request.test_type_ids,
            "priority": request.priority,
            "test_datetime": request.test_datetime,
            "lab_id": request.lab_id
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestDict)
        urlRequest.httpBody = jsonData
        
        // Log request body
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("[SwatiSwapna] Lab test request JSON: \(jsonString)")
        }
        
        print("[SwatiSwapna] Recommending lab tests at: \(url.absoluteString)")
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("[SwatiSwapna] Recommend lab tests status: \(httpResponse.statusCode)")
        
        // Log response
        if let responseString = String(data: data, encoding: .utf8) {
            print("[SwatiSwapna] Lab test response: \(responseString)")
        }
        
        // Process response
        if (200...299).contains(httpResponse.statusCode) {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(DoctorResponse.RecommendLabTestResponse.self, from: data)
            } catch {
                print("[SwatiSwapna] Failed to decode lab test response: \(error)")
                
                // Create simple success response
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    return DoctorResponse.RecommendLabTestResponse(
                        message: message,
                        lab_tests: []
                    )
                }
                
                throw NetworkError.decodingError
            }
        } else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMsg = errorJson["error"] as? String {
                throw NetworkError.serverError(errorMsg)
            }
            
            throw NetworkError.serverError("HTTP error \(httpResponse.statusCode)")
        }
    }
    // MARK: - Fetch Medicine List
    func fetchMedicineList() async throws -> [DoctorResponse.Medicine] {
        guard let url = buildURL(endpoint: DoctorEndpoints.Medicine.list) else {
            print("[SwatiSwapna] Invalid URL for medicine list")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        print("[SwatiSwapna] Fetching medicine list from: \(url.absoluteString)")
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("[SwatiSwapna] Medicine list status: \(httpResponse.statusCode)")
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                let medicines = try decoder.decode([DoctorResponse.Medicine].self, from: data)
                print("[SwatiSwapna] Successfully decoded \(medicines.count) medicines")
                return medicines
            } catch {
                print("[SwatiSwapna] Decoding error: \(error)")
                throw NetworkError.decodingError
            }
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Fetch Target Organs
    func fetchTargetOrgans() async throws -> [DoctorResponse.TargetOrgan] {
        guard let url = buildURL(endpoint: DoctorEndpoints.TargetOrgans.list) else {
            print("[SwatiSwapna] Invalid URL for target organs")
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        print("[SwatiSwapna] Fetching target organs from: \(url.absoluteString)")
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("[SwatiSwapna] Target organs status: \(httpResponse.statusCode)")
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                let organs = try decoder.decode([DoctorResponse.TargetOrgan].self, from: data)
                print("[SwatiSwapna] Successfully decoded \(organs.count) target organs")
                return organs
            } catch {
                print("[SwatiSwapna] Decoding error: \(error)")
                throw NetworkError.decodingError
            }
        case 401:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Fetch Lab Test Types
    func fetchLabTestTypes() async throws -> [DoctorResponse.LabTestType] {
        guard let url = buildURL(endpoint: "api/hospital/general/lab-test-types/") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            if let httpResponse = response as? HTTPURLResponse {
                print("[SwatiSwapna] Failed to fetch lab test types: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("[SwatiSwapna] Error response: \(responseString)")
                }
            }
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([DoctorResponse.LabTestType].self, from: data)
        } catch {
            print("[SwatiSwapna] Failed to decode lab test types: \(error)")
            throw NetworkError.decodingError
        }
    }
    
    // Function to submit prescription
    func submitPrescription(_ prescription: PrescriptionRequest) async throws -> ApiResponse {
        let url = URL(string: "\(baseURL)/api/prescriptions/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(prescription)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw ApiError.serverError(statusCode: httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(ApiResponse.self, from: data)
    }
    
    struct ApiResponse: Codable {
        let success: Bool
        let message: String
    }
    
    enum ApiError: Error {
        case invalidResponse
        case serverError(statusCode: Int)
        case decodingError
    }
    
}
