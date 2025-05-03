import Foundation
import Combine

class DoctorViewModel: ObservableObject {
    
    // Published properties to bind data to the View
    @Published var doctorShifts: [DoctorResponse.PatientDoctorSlotResponse] = []
    @Published var doctorAppointments: [DoctorResponse.DocAppointment] = []
    @Published var patientProfile: DoctorResponse.PatientProfile?
    @Published var patientVitals: DoctorResponse.DocGetLatestPatientVitals?
    @Published var enterVitalsMessage: String = ""
    @Published var diagnosisMessage: String = ""
    @Published var prescriptionMessage: String = ""
    
    // State for loading and error handling
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var doctorService = DoctorServices()
    
    // Fetch Doctor Shifts
    func fetchDoctorShifts(doctorId: String) {
        self.isLoading = true
        
        // Get today's date in the required format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        Task {
            do {
                // Use fetchDoctorSlots instead of fetchDoctorShifts
                let slots = try await doctorService.fetchDoctorSlots(doctorId: doctorId, date: today)
                DispatchQueue.main.async {
                    self.doctorShifts = slots
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("[SwatiSwapna] Error fetching shifts: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Fetch Doctor's Appointment History
    func fetchDoctorAppointments() {
        self.isLoading = true
        Task {
            do {
                let appointments = try await doctorService.fetchDoctorAppointmentHistory()
                DispatchQueue.main.async {
                    self.doctorAppointments = appointments
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("[SwatiSwapna] Error fetching appointments: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Fetch Patient Profile
    func fetchPatientProfile(patientId: String) {
        self.isLoading = true
        Task {
            do {
                let profile = try await doctorService.fetchPatientProfile(patientId: patientId)
                DispatchQueue.main.async {
                    self.patientProfile = profile
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("[SwatiSwapna] Error fetching patient profile: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Fetch Latest Vitals for Patient
    func fetchPatientVitals(patientId: String) {
        self.isLoading = true
        Task {
            do {
                let vitals = try await doctorService.fetchPatientLatestVitals(patientId: patientId)
                DispatchQueue.main.async {
                    self.patientVitals = vitals
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("[SwatiSwapna] Error fetching vitals: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Enter Patient Vitals - FIXED: now uses PostVitals struct
    func enterVitals(appointmentId: Int, height: Double, weight: Double, heartrate: Int, spo2: Double, temperature: Double) {
        self.isLoading = true
        
        // Create the PostVitals object
        let vitalsData = PostVitals(
            height: height,
            weight: weight,
            heartrate: heartrate,
            spo2: spo2,
            temperature: temperature
        )
        
        Task {
            do {
                let response = try await doctorService.enterVitals(appointmentId: appointmentId, vitals: vitalsData)
                DispatchQueue.main.async {
                    self.enterVitalsMessage = response.message
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("[SwatiSwapna] Error entering vitals: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Enter Diagnosis - FIXED: added missing function
    func enterDiagnosis(appointmentId: String, organ: String, notes: String, symptoms: [String], labTestRequired: Bool, followUpRequired: Bool) {
        self.isLoading = true
        
        let diagnosisData = DiagnosisData(
            organ: organ,
            notes: notes,
            symptoms: symptoms
        )
        
        let diagnosisRequest = EnterDiagnosisRequest(
            diagnosis_data: diagnosisData,
            lab_test_required: labTestRequired,
            follow_up_required: followUpRequired
        )
        
        Task {
            do {
                let response = try await doctorService.enterDiagnosis(appointmentId: appointmentId, diagnosisData: diagnosisRequest)
                DispatchQueue.main.async {
                    self.diagnosisMessage = response.message
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("[SwatiSwapna] Error entering diagnosis: \(error.localizedDescription)")
                }
            }
        }
    }
  
    func handleDiagnosis(diagnosisId: Int) {
        self.isLoading = true
        Task {
            do {
                let response = try await doctorService.handleDiagnosis(diagnosisId: diagnosisId)
                DispatchQueue.main.async {
                    self.diagnosisMessage = response.message
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("[SwatiSwapna] Error handling diagnosis: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Enter Prescription - NEW: Added missing function
    func enterPrescription(appointmentId: String, remarks: String, medicines: [PrescriptionRequest.Medicine]) {
        self.isLoading = true
        
        let prescriptionRequest = PrescriptionRequest(
            remarks: remarks,
            medicines: medicines
        )
        
        Task {
            do {
                let response = try await doctorService.enterPrescription(appointmentId: appointmentId, prescription: prescriptionRequest)
                DispatchQueue.main.async {
                    self.prescriptionMessage = response.message
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("[SwatiSwapna] Error entering prescription: \(error.localizedDescription)")
                }
            }
        }
    }
}
