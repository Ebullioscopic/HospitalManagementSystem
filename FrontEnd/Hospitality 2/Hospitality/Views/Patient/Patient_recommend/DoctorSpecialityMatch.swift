import SwiftUI

struct DoctorSpecialtyMatch {
    static func matchSpecialty(
        bodyPart: String?,
        symptoms: [String]?,
        duration: String?,
        severity: String?
    ) -> [String] {
        // This is simplified logic - would be more comprehensive in production
        guard let bodyPart = bodyPart?.lowercased() else {
            return ["General Practitioner"]
        }
        
        var specialties = [String]()
        
        // Body part based matching
        switch bodyPart {
        case "head":
            if symptoms?.contains("Fever") == true {
                specialties.append("Infectious Disease Specialist")
            } else {
                specialties.append("Neurologist")
            }
        case "chest":
            specialties.append("Cardiologist")
            if symptoms?.contains("Pain") == true {
                specialties.append("Pulmonologist")
            }
        case "abdomen":
            specialties.append("Gastroenterologist")
        case "hand", "arm", "shoulder":
            specialties.append("Orthopedist")
        case "leg", "knee", "foot":
            specialties.append("Orthopedist")
            specialties.append("Podiatrist")
        default:
            specialties.append("General Practitioner")
        }
        
        // Symptom based additions
        if symptoms?.contains("Rash") == true {
            specialties.append("Dermatologist")
        }
        
        if symptoms?.contains("Nausea") == true || symptoms?.contains("Dizziness") == true {
            specialties.append("Internist")
        }
        
        // Duration and severity considerations
        if duration == "Less than 24 hours" && severity?.compare("7") == .orderedDescending {
            specialties.insert("Emergency Medicine", at: 0)
        }
        
        // Remove duplicates and return
        return Array(Set(specialties))
    }
}
