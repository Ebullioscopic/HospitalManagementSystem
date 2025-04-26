import Foundation
import Combine

class PatientStaffLoginService {
    static let shared = PatientStaffLoginService()
    private let baseURL = Constants.baseURL
    private var cancellables = Set<AnyCancellable>()
    
    // Request OTP for patient/staff login
    func requestOTP(email: String, password: String, userType: String) -> AnyPublisher<AuthResponse.PatientStaffLoginResponse.OTPResponse, Error> {
        print("Entered Patient/Staff Login OTP Service")
        let endpoint = AuthEndpoint.PatientStaffLogin.requestOTP
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        print("URL: \(url)")
        
        let requestBody = AuthRequest.PatientStaffLoginRequest.OTPRequest(
            email: email,
            password: password,
            user_type: userType
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
            .decode(type: AuthResponse.PatientStaffLoginResponse.OTPResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Complete login with OTP
    func completeLogin(email: String, otp: String, userType: String) -> AnyPublisher<AuthResponse.PatientStaffLoginResponse.LoginResponse, Error> {
        print("Entered Patient/Staff Login Verification Service")
        let endpoint = AuthEndpoint.PatientStaffLogin.login
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        print("URL: \(url)")
        
        let requestBody = AuthRequest.PatientStaffLoginRequest.LoginRequest(
            email: email,
            otp: otp,
            user_type: userType
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
            .decode(type: AuthResponse.PatientStaffLoginResponse.LoginResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Helper method to handle token storage
    func saveTokens(accessToken: String, refreshToken: String, userType: String, userId: Int) {
        UserDefaults.standard.set(accessToken, forKey: "accessToken")
        UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
        UserDefaults.standard.set(userType, forKey: "userType")
        UserDefaults.standard.set(userId, forKey: "userId")
    }
    
    // Helper method to get stored access token
    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: "accessToken")
    }
    
    // Helper method to get user type
    func getUserType() -> String? {
        return UserDefaults.standard.string(forKey: "userType")
    }
    
    // Helper method to get user ID
    func getUserId() -> Int? {
        return UserDefaults.standard.integer(forKey: "userId")
    }
    
    // Clear auth data (for logout)
    func clearAuthData() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        UserDefaults.standard.removeObject(forKey: "userType") 
        UserDefaults.standard.removeObject(forKey: "userId")
    }
}