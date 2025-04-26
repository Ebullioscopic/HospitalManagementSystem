//
//  PatientService.swift
//  Hospitality
//
//  Created by admin29 on 26/04/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case unauthorized
    case serverError(Int)
    case unknown(Error)
    
    var errorMessage: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

class PatientService {
    private let baseURL = Constants.baseURL // Replace with actual base URL
    private let endpoints = PatientEndpoints.Profile()
    
    func fetchPatientProfile() async throws -> PatientResponse.PatientProfileResponse {
        guard let url = URL(string: baseURL + endpoints.getProfile) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get access token from UserDefaults
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            throw NetworkError.unauthorized
        }
        
        // Add token to headers
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(NSError(domain: "Invalid response", code: 0))
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    return try decoder.decode(PatientResponse.PatientProfileResponse.self, from: data)
                } catch {
                    print("Decoding error: \(error)")
                    throw NetworkError.decodingError
                }
            case 401:
                throw NetworkError.unauthorized
            default:
                throw NetworkError.serverError(httpResponse.statusCode)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}

