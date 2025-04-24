//
//  dataModel.swift
//  Hospitality
//
//  Created by admin@33 on 23/04/25.
//

import SwiftUI

struct RegistrationDoctors: Identifiable {
    let id = UUID()
    var name: String
    var email: String
    var phone: String
    var department: String
    var specialization: String
    var qualification: String
    var experience: String
    var availability: String
    var bio: String
    var fees: String
    var shifts: [String]
}

struct LabTest: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var price: String
    var duration: String
    var instructions: String
}

struct LabTechnician: Identifiable {
    let id = UUID()
    var name: String
    var email: String
    var phone: String
    var qualification: String
    var experience: String
    var certifications: String
    var shift: String
    var specialty: String
}
