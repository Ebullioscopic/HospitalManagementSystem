//
//  DocResponseModel.swift
//  Hospitality
//
//  Created by admin44 on 27/04/25.
//

import Foundation
struct DoctorResponse {
    struct ShiftAssignmentResponse: Codable {
        let message: String
    }
    
    struct DocAppointment: Codable, Identifiable {
        var id: Int { appointmentId }
        let appointmentId: Int
        let date: String
        let slotId: Int
        let staffId: String
        let patientId: Int
        let status: String
        
        enum CodingKeys: String, CodingKey {
            case appointmentId = "appointment_id"
            case date
            case slotId = "slot_id"
            case staffId = "staff_id"
            case patientId = "patient_id"
            case status
        }
    }
    
    struct PatientProfile: Codable, Identifiable {
        var id: Int { patientId }
        let patientId: Int
        let patientName: String
        let patientEmail: String
        let patientMobile: String
        let dob: String
        let gender: Bool
        let bloodGroup: String
        let address: String?
        let profilePhoto: String?
        
        enum CodingKeys: String, CodingKey {
            case patientId = "patient_id"
            case patientName = "patient_name"
            case patientEmail = "patient_email"
            case patientMobile = "patient_mobile"
            case dob
            case gender
            case bloodGroup = "blood_group"
            case address
            case profilePhoto = "profile_photo"
        }
    }
    
    struct DocGetLatestPatientVitals: Codable {
        let patientHeight: Double
        let patientWeight: Double
        let patientHeartrate: Int
        let patientSpo2: Double
        let patientTemperature: Double
        let createdAt: String
        let appointmentId: Int
        
        enum CodingKeys: String, CodingKey {
            case patientHeight = "patient_height"
            case patientWeight = "patient_weight"
            case patientHeartrate = "patient_heartrate"
            case patientSpo2 = "patient_spo2"
            case patientTemperature = "patient_temperature"
            case createdAt = "created_at"
            case appointmentId = "appointment_id"
        }
    }
    
    struct EnterVitals : Codable{
        let message: String
    }
    
    struct DiagnosisResponse: Codable {
        let message: String
        let diagnosisId: Int
        
        enum CodingKeys: String, CodingKey {
            case message
            case diagnosisId = "diagnosis_id"
        }
    }
    
    struct PatientDoctorSlotResponse: Codable {
        let slot_id: Int
        let slot_start_time: String
        let slot_duration: Int
        let is_booked: Bool
    }
    
    struct PrescriptionResponse: Codable {
        let message: String
    }
}
