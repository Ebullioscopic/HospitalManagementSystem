//
//  dataModel.swift
//  Hospitality
//
//  Created by admin@33 on 23/04/25.
//

import Foundation
import SwiftUI

// MARK: - Lab Test Models
struct LabTest: Identifiable, Codable {
    let id: String
    let labId: String
    let testDateTime: Date
    let testResult: [String: String]
    let testType: String
    let appointmentId: String
    let tranId: String
}

// MARK: - Diagnosis Models
struct Diagnosis: Identifiable, Codable {
    let id: String
    let diagnosisData: [String: String]
    let appointmentId: String
    let labTestRequired: Bool
    let followUpRequired: Bool
}

// MARK: - Schedule Models
struct Schedule: Identifiable, Codable {
    let id: String
    let scheduleDate: Date
    let staffId: String
    let shift: String
}

struct Shift: Identifiable, Codable {
    let id: String
    let shiftName: String
    let startTime: Date
    let endTime: Date
}

struct Slot: Identifiable, Codable {
    let id: String
    let slotStartTime: Date
    let slotDuration: TimeInterval
    let shiftId: String
    let slotRemark: String?
}

// MARK: - Appointment Models
struct Appointment: Identifiable, Codable {
    let id: String
    let patientId: String
    let staffId: String
    let slotId: String
    let tranId: String
    let createdAt: Date
}

// MARK: - Follow Up Models
struct FollowUp: Identifiable, Codable {
    let id: String
    let appointmentId: String
    let followUpDate: Date
    let followUpRemarks: String?
}

//// MARK: - Prescription Models
//struct Prescription: Identifiable, Codable {
//    let id: String
//    let medicineName: String
//    let medicineDosage: [String: String]
//    let fastingRequired: Bool
//    let appointmentId: String
//    let prescriptionRemarks: String?
//}

// MARK: - Target Organ Models
struct TargetOrgan: Identifiable, Codable {
    let id: String
    let targetOrganName: String
    let targetOrganRemark: String?
}

struct Prescription1{
    let prescriptionID :String
    let appointmentID :String
    let prescriptionRemarks :String
}

struct Medicine{
    let medicineID : String
    let medicineName : String
    let medicineRemarks : String
}

struct PrescribedMedicine{
    let prescribedMedicineID: String
    let prescriptionID :String
    let medicineID : String
    let medicineDosage: [String: String]
    let fastingRequired: String
}


// MARK: - Patient Models
struct Patient: Identifiable, Codable {
    let id: String
    let patientName: String
    let patientEmail: String?
    let patientMobile: String
    let patientDob: Date
    let patientGender: String
    let patientBloodGroup: String?
    let patientRemark: String?
}

struct PatientDetails: Identifiable, Codable {
    let id: String
    let patientId: String
    let patientAddress: String
    let patientPhoto: Data?
    let patientRemark: String?
}

struct PatientVitals: Identifiable, Codable {
    var id: String
    var patientId: String
    var patientHeight: Double
    var patientWeight: Double
    var patientHeartrate: Int
    var patientSpo2: Int
    var patientTemperature: Double
    var appointmentId: String
}

// MARK: - Staff Models
struct Staff: Identifiable, Codable {
    let id: String
    let staffName: String
    let roleId: String
    let createdAt: Date
    let staffEmail: String
    let staffMobile: String
    let onLeave: Bool
}

struct StaffDetails: Identifiable, Codable {
    let id: String
    let staffId: String
    let staffDob: Date
    let staffAddress: String
    let staffQualifications: String
    let staffPhoto: Data?
}

struct DoctorDetails: Identifiable, Codable {
    let id: String
    let staffId: String
    let doctorSpecialization: String
    let doctorLicense: String
    let doctorExperienceYears: Int
    let doctorTypeId: String
}

struct DoctorType: Identifiable, Codable {
    let id: String
    let doctorTypeName: String
    let doctorTypeRemark: String?
}

struct LabTechnicianDetails: Identifiable, Codable {
    let id: String
    let staffId: String
    let certificationId: String
    let labExperienceYears: Int
    let assignedLabId: String
}

// MARK: - Role Models
struct Role: Identifiable, Codable {
    let id: String
    let roleName: String
    let rolePermissions: [String: String]
}

// MARK: - Lab Models
struct Lab: Identifiable, Codable {
    let id: String
    let labName: String
    let labTypeId: String
    let functional: Bool
}

struct LabType: Identifiable, Codable {
    let id: String
    let labTypeName: String
    let supportedTests: [String]
}

struct LabTestType: Identifiable, Codable {
    let id: String
    let testName: String
    let testCategoryId: String
    let testTargetOrganId: String
    let testRemark: String?
}

struct LabTestCategory: Identifiable, Codable {
    let id: String
    let testCategoryName: String
    let testCategoryRemark: String?
}

// MARK: - Project Models (from Image 2)
struct Project: Identifiable, Codable {
    let id: String
    // Additional properties would be based on full context
}

struct Transaction: Identifiable, Codable {
    let id: String
    let tranCode: String
    let tranType: String
    let tranAmount: Double
    let tranRemark: String?
}

// MARK: - Utility Extensions
extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "JSONSerialization", code: 0, userInfo: nil)
        }
        return dictionary
    }
}

// MARK: - View Models
class HospitalDataStore: ObservableObject {
    @Published var patients: [Patient] = []
    @Published var appointments: [Appointment] = []
    @Published var staff: [Staff] = []
    @Published var doctors: [DoctorDetails] = []
    @Published var labTests: [LabTest] = []
    @Published var prescriptions: [Prescription1] = []
    
    // CRUD functions would be implemented here
    func fetchPatients() {
        // Implementation would connect to a database or API
    }
    
    func createAppointment(patientId: String, doctorId: String, slotId: String) -> Appointment? {
        // Implementation to create and save a new appointment
        return nil
    }
    
    func updatePatientVitals(patientId: String, vitals: PatientVitals) -> Bool {
        // Implementation to update patient vitals
        return false
    }
}

// MockHospitalDataStore.swift
class MockHospitalDataStore: ObservableObject {
    // MARK: - Mock Data
    @Published var staff: [Staff] = []
    @Published var staffDetails: [StaffDetails] = []
    @Published var doctors: [DoctorDetails] = []
    @Published var labTechnicians: [LabTechnicianDetails] = []
    @Published var labs: [Lab] = []
    @Published var labTestTypes: [LabTestType] = []
    @Published var labTestCategories: [LabTestCategory] = []
    @Published var targetOrgans: [TargetOrgan] = []
    @Published var doctorTypes: [DoctorType] = []
    
    // MARK: - Initializer with Mock Data
    init() {
        loadMockData()
    }
    
    func updateFromAPI(staff: [Staff], doctorDetails: [DoctorDetails]) {
        self.staff = staff
        self.doctors = doctorDetails
    }
    
    private func loadMockData() {
        // Mock Doctor Types
        doctorTypes = [
            DoctorType(id: "1", doctorTypeName: "General Practitioner", doctorTypeRemark: "Primary care physician"),
            DoctorType(id: "2", doctorTypeName: "Specialist", doctorTypeRemark: "Specialized in specific field"),
            DoctorType(id: "3", doctorTypeName: "Surgeon", doctorTypeRemark: "Performs surgical procedures")
        ]
        
        // Mock Staff and Doctors
        let doctorStaff = [
            Staff(id: "d1", staffName: "Dr. Sarah Johnson", roleId: "doctor", createdAt: Date(), staffEmail: "s.johnson@hospital.com", staffMobile: "+15551234567", onLeave: false),
            Staff(id: "d2", staffName: "Dr. Michael Chen", roleId: "doctor", createdAt: Date(), staffEmail: "m.chen@hospital.com", staffMobile: "+15559876543", onLeave: true),
            Staff(id: "d3", staffName: "Dr. Emily Rodriguez", roleId: "doctor", createdAt: Date(), staffEmail: "e.rodriguez@hospital.com", staffMobile: "+15554567890", onLeave: false)
        ]
        
        doctors = [
            DoctorDetails(id: "dd1", staffId: "d1", doctorSpecialization: "Cardiology", doctorLicense: "MD12345", doctorExperienceYears: 12, doctorTypeId: "2"),
            DoctorDetails(id: "dd2", staffId: "d2", doctorSpecialization: "Neurology", doctorLicense: "MD54321", doctorExperienceYears: 8, doctorTypeId: "2"),
            DoctorDetails(id: "dd3", staffId: "d3", doctorSpecialization: "Pediatrics", doctorLicense: "MD67890", doctorExperienceYears: 5, doctorTypeId: "1")
        ]
        
        // Mock Labs
        labs = [
            Lab(id: "l1", labName: "Hematology", labTypeId: "lt1", functional: true),
            Lab(id: "l2", labName: "Microbiology", labTypeId: "lt2", functional: true),
            Lab(id: "l3", labName: "Pathology", labTypeId: "lt3", functional: false)
        ]
        
        // Mock Lab Technicians
        let techStaff = [
            Staff(id: "t1", staffName: "Emily Rodriguez", roleId: "lab_tech", createdAt: Date(), staffEmail: "e.rodriguez@hospital.com", staffMobile: "+15552345678", onLeave: false),
            Staff(id: "t2", staffName: "David Kim", roleId: "lab_tech", createdAt: Date(), staffEmail: "d.kim@hospital.com", staffMobile: "+15553456789", onLeave: false)
        ]
        
        labTechnicians = [
            LabTechnicianDetails(id: "lt1", staffId: "t1", certificationId: "ASCP123", labExperienceYears: 5, assignedLabId: "l1"),
            LabTechnicianDetails(id: "lt2", staffId: "t2", certificationId: "MLT456", labExperienceYears: 3, assignedLabId: "l2")
        ]
        
        // Mock Lab Test Categories
        labTestCategories = [
            LabTestCategory(id: "cat1", testCategoryName: "Blood Tests", testCategoryRemark: "Tests on blood samples"),
            LabTestCategory(id: "cat2", testCategoryName: "Microbiology Tests", testCategoryRemark: "Tests for microorganisms"),
            LabTestCategory(id: "cat3", testCategoryName: "Genetic Tests", testCategoryRemark: "DNA and genetic testing")
        ]
        
        // Mock Target Organs
        targetOrgans = [
            TargetOrgan(id: "o1", targetOrganName: "Heart", targetOrganRemark: "Cardiac system"),
            TargetOrgan(id: "o2", targetOrganName: "Brain", targetOrganRemark: "Nervous system"),
            TargetOrgan(id: "o3", targetOrganName: "Liver", targetOrganRemark: "Digestive system")
        ]
        
        // Mock Lab Test Types
        labTestTypes = [
            LabTestType(id: "test1", testName: "Complete Blood Count", testCategoryId: "cat1", testTargetOrganId: "o1", testRemark: "Measures various blood components"),
            LabTestType(id: "test2", testName: "Basic Metabolic Panel", testCategoryId: "cat1", testTargetOrganId: "o3", testRemark: "Measures glucose and electrolytes"),
            LabTestType(id: "test3", testName: "Culture and Sensitivity", testCategoryId: "cat2", testTargetOrganId: "o2", testRemark: "Identifies bacteria and effective antibiotics")
        ]
        
        // Combine all staff
        staff = doctorStaff + techStaff
    }
    
    // MARK: - CRUD Functions (Mock versions - replace with API calls later)
    
    // Staff CRUD
    func fetchStaff() {
        // In real implementation, this would call your API
        print("Fetching staff from API would happen here")
    }
    
    func createDoctor(staff: Staff, doctorDetails: DoctorDetails, staffDetails: StaffDetails) {
        // In real implementation, this would POST to your API
        self.staff.append(staff)
        self.doctors.append(doctorDetails)
        // You'll need to add a staffDetails array to your data store
        self.staffDetails.append(staffDetails)
        print("Would create doctor via API: \(staff) with details: \(doctorDetails) and \(staffDetails)")
    }
    
    func deleteStaff(ids: [String]) {
        // In real implementation, this would DELETE via your API
        staff.removeAll { ids.contains($0.id) }
        print("Would delete staff via API with IDs: \(ids)")
    }
    
    // Doctor CRUD
    func fetchDoctors() {
        // In real implementation, this would call your API
        print("Fetching doctors from API would happen here")
    }
    
    func createDoctor(staff: Staff, doctorDetails: DoctorDetails) {
        // In real implementation, this would POST to your API
        self.staff.append(staff)
        self.doctors.append(doctorDetails)
        print("Would create doctor via API: \(staff) with details: \(doctorDetails)")
    }
    
    // Lab Technician CRUD
    func fetchLabTechnicians() {
        // In real implementation, this would call your API
        print("Fetching lab technicians from API would happen here")
    }
    
    func createLabTechnician(staff: Staff, techDetails: LabTechnicianDetails) {
        // In real implementation, this would POST to your API
        self.staff.append(staff)
        self.labTechnicians.append(techDetails)
        print("Would create lab tech via API: \(staff) with details: \(techDetails)")
    }
    
    // Lab Test CRUD
    func fetchLabTestTypes() {
        // In real implementation, this would call your API
        print("Fetching lab test types from API would happen here")
    }
    
    func createLabTestType(testType: LabTestType) {
        // In real implementation, this would POST to your API
        self.labTestTypes.append(testType)
        print("Would create lab test type via API: \(testType)")
    }
    
    func deleteLabTestTypes(ids: [String]) {
        // In real implementation, this would DELETE via your API
        labTestTypes.removeAll { ids.contains($0.id) }
        print("Would delete lab test types via API with IDs: \(ids)")
    }
    
    // Other fetches
    func fetchLabs() {
        print("Fetching labs from API would happen here")
    }
    
    func fetchLabTestCategories() {
        print("Fetching lab test categories from API would happen here")
    }
    
    func fetchTargetOrgans() {
        print("Fetching target organs from API would happen here")
    }
    
    func fetchDoctorTypes() {
        print("Fetching doctor types from API would happen here")
    }
}
