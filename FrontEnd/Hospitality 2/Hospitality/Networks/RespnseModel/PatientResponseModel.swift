//
//  PatientResponseModel.swift
//  Hospitality
//
//  Created by admin29 on 26/04/25.
//

import SwiftUI
import Foundation

struct PatientResponse {
        
    struct PatientProfileResponse: Codable {
        let patientID: Int
        let patientName: String
        let patientEmail: String
        let patientMobile: String
        let patientRemark: String?
        let patientDOB: String
        let patientGender: Bool
        let patientBloodGroup: String
        let patientAddress: String?
        let profilePhoto: String?

        enum CodingKeys: String, CodingKey {
            case patientID = "patient_id"
            case patientName = "patient_name"
            case patientEmail = "patient_email"
            case patientMobile = "patient_mobile"
            case patientRemark = "patient_remark"
            case patientDOB = "patient_dob"
            case patientGender = "patient_gender"
            case patientBloodGroup = "patient_blood_group"
            case patientAddress = "patient_address"
            case profilePhoto = "profile_photo"
        }
    }
}
    
