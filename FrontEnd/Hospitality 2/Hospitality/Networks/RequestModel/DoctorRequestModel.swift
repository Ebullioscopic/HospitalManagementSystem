//
//  DoctorRequestModel.swift
//  Hospitality
//
//  Created by admin44 on 27/04/25.
//

import Foundation

// MARK: - Request Models

//1.Select shift ->post

struct SelectShiftRequest: Codable {
    let shiftId: Int
    let date: String
}

//2.Doc puts vitals->post

struct PostVitals: Codable {
    let height: Double
    let weight: Double
    let heartrate: Int
    let spo2: Double
    let temperature: Double
}

//2.Doc puts vitals->post
struct EnterDiagnosisRequest: Codable {
    let diagnosis_data: DiagnosisData
    let lab_test_required: Bool
    let follow_up_required: Bool
}

//3. doc enters diag data -> post
struct DiagnosisData: Codable {
    let organ: String
    let notes: String
    let symptoms: [String]
}

// 4. Doc enters pres data -> post
struct PrescriptionRequest: Codable {
    let remarks: String
    let medicines: [Medicine]
    
    struct Medicine: Codable {
        let medicine_id: String
        let dosage: Dosage
        let fasting_required: Bool
        
        struct Dosage: Codable {
            let morning: Int
            let afternoon: Int
            let evening: Int
        }
    }
}

