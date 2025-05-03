

import Foundation

struct DoctorEndpoints {
    struct DoctorShift {
        static func shifts(doctorId: String) -> String {
            // Add "api/" prefix to the URL
            return "api/hospital/general/doctors/\(doctorId)/shifts/"
        }
    }
    
    struct Appointment {
        // Fix the history endpoint with the correct path
        static let history = "api/hospital/general/appointments/history/"
        
        static func vitals(appointmentId: String) -> String {
            return "api/hospital/general/appointments/\(appointmentId)/vitals/"
        }
        
        static func diagnosis(appointmentId: String) -> String {
            return "api/hospital/general/appointments/\(appointmentId)/diagnosis/"
        }
        
        static func prescription(appointmentId: String) -> String {
            return "api/hospital/general/appointments/\(appointmentId)/prescription/"
        }
    }
    
    struct Patient {
        static func profile(patientId: String) -> String {
            return "api/hospital/general/patients/\(patientId)/"
        }
        
        static func latestVitals(patientId: String) -> String {
            return "api/hospital/general/patients/\(patientId)/latest-vitals/"
        }
    }
    
    struct DoctorSlots {
        static func slots(doctorId: String, date: String) -> String {
            return "api/hospital/general/doctors/\(doctorId)/slots/?date=\(date)"
        }
    }
}
