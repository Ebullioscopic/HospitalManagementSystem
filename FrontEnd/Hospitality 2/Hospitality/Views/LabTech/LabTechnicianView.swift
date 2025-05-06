import SwiftUI
import Foundation


// Extension for Hex Color Support in UIColor
extension UIColor {
    convenience init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased().replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1.0)
            return
        }
        let r, g, b: CGFloat
        if hexSanitized.count == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else {
            r = 0
            g = 0
            b = 0
        }
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

// Updated Color Palette
struct ColorSet {
    static let primaryBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "101420") : UIColor(hex: "E8F5FF")
    })
    static let secondaryBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "1A202C") : UIColor(hex: "F0F8FF")
    })
    static let cardBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "1E2533") : UIColor.white
    })
    static let primaryText = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor.white : UIColor(hex: "2C5282")
    })
    static let secondaryText = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(hex: "718096") : UIColor(hex: "4A5568")
    })
    static let accentBlue = Color(hex: "4A90E2")
    static let accentGreen = Color(hex: "38A169")
    static let accentRed = Color(hex: "E53E3E")
    static let borderGradient = LinearGradient(
        gradient: Gradient(colors: [accentBlue.opacity(0.5), accentBlue.opacity(0.3)]),
        startPoint: .top,
        endPoint: .bottom
    )
}

// View Modifier for Button Styling
struct CustomButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "4A90E2"),
                                Color(hex: "5E5CE6")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: Color(hex: "4A90E2").opacity(0.2), radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorSet.borderGradient, lineWidth: 1)
            )
    }
}

// Lab and Test Mapping
struct LabInfo {
    static let labTests: [String: [String]] = [
        "Pathology Lab": [
            "Complete Blood Count (CBC)",
            "Blood Sugar (Fasting/PP)",
            "ESR",
            "Urinalysis",
            "Stool Examination",
            "Blood Grouping & Rh Typing"
        ],
        "Biochemistry Lab": [
            "Liver Function Test (LFT)",
            "Kidney Function Test (KFT)",
            "Lipid Profile",
            "Blood Glucose (Fasting, PP)",
            "HbA1c",
            "Serum Electrolytes"
        ],
        "Microbiology Lab": [
            "Culture & Sensitivity (Urine, Blood, Sputum, Wound)",
            "Throat Swab Culture",
            "Stool for Ova & Parasites",
            "Sputum AFB",
            "COVID-19 RT-PCR"
        ],
        "Histopathology Lab": [
            "Biopsy Analysis",
            "Fine Needle Aspiration Cytology (FNAC)",
            "PAP Smear",
            "Immunohistochemistry"
        ],
        "Radiology Lab": [
            "X-Ray",
            "Ultrasound (USG)",
            "CT Scan",
            "MRI",
            "Mammography"
        ]
    ]
    
    static func getLabForTest(_ test: String) -> String? {
        for (lab, tests) in labTests {
            if tests.contains(test) {
                return lab
            }
        }
        return nil
    }
}

// Lab Technician Model
struct LabTechnician {
    let id: UUID = UUID()
    let name: String
    let email: String
    let lab: String
}

// LabPatient Model (Renamed from Patient to avoid conflict)
struct LabPatient: Identifiable {
    let id = UUID()
    let name: String
    let test: String
    let date: String
    let time: String
    let details: String
    var status: String
    let priority: String
    let contact: String
    let lab: String
}

// JSON Data Models
struct TestFieldsData: Codable {
    var testFields: [String: [String]]
}

struct LabTestResultsData: Codable {
    var tests: [LabResult]
}

struct LabResult: Codable {
    let patientID: String
    let test: String
    let parameters: [String: String]
    let notes: String
    let uploadedFile: String?
    let timestamp: String
}

// File Manager Helper
class FileManagerHelper {
    static let shared = FileManagerHelper()
    
    private let testFieldsFileName = "test_fields.json"
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    private var testFieldsFileURL: URL {
        documentsURL.appendingPathComponent(testFieldsFileName)
    }
    
    private func testResultsFileURL(for test: String) -> URL {
        let fileName = sanitizeFileName(test) + ".json"
        return documentsURL.appendingPathComponent(fileName)
    }
    
    private func sanitizeFileName(_ test: String) -> String {
        return test.replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "&", with: "And")
    }
    
    func initializeJSONFiles() {
        if !FileManager.default.fileExists(atPath: testFieldsFileURL.path()) {
            let initialTestFields = TestFieldsData(
                testFields: [
                    "Complete Blood Count (CBC)": ["Hemoglobin (g/dL)", "WBC Count (cells/µL)", "Platelet Count (cells/µL)", "RBC Count (cells/µL)"],
                    "Blood Sugar (Fasting/PP)": ["Glucose (mg/dL)", "Fasting Glucose (mg/dL)", "Postprandial Glucose (mg/dL)"],
                    "ESR": ["Sedimentation Rate (mm/hr)"],
                    "Urinalysis": ["pH Level", "Protein (mg/dL)", "Glucose (mg/dL)", "Ketones", "Specific Gravity"],
                    "Stool Examination": ["Occult Blood", "Parasites", "Consistency"],
                    "Blood Grouping & Rh Typing": ["Blood Group", "Rh Factor"],
                    "Liver Function Test (LFT)": ["ALT (U/L)", "AST (U/L)", "Bilirubin (mg/dL)", "Albumin (g/dL)"],
                    "Kidney Function Test (KFT)": ["Creatinine (mg/dL)", "Urea (mg/dL)", "GFR (mL/min)"],
                    "Lipid Profile": ["Total Cholesterol (mg/dL)", "HDL (mg/dL)", "LDL (mg/dL)", "Triglycerides (mg/dL)"],
                    "Blood Glucose (Fasting, PP)": ["Fasting Glucose (mg/dL)", "Postprandial Glucose (mg/dL)"],
                    "HbA1c": ["HbA1c (%)"],
                    "Serum Electrolytes": ["Sodium (mmol/L)", "Potassium (mmol/L)", "Chloride (mmol/L)"],
                    "Culture & Sensitivity (Urine, Blood, Sputum, Wound)": ["Pathogen Identified", "Antibiotic Sensitivity"],
                    "Throat Swab Culture": ["Pathogen Identified", "Antibiotic Sensitivity"],
                    "Stool for Ova & Parasites": ["Parasites Detected", "Ova Count"],
                    "Sputum AFB": ["AFB Presence", "Stain Intensity"],
                    "COVID-19 RT-PCR": ["Ct Value", "Result (Positive/Negative)"],
                    "Biopsy Analysis": ["Tissue Type", "Cell Morphology", "Malignancy", "Pathologist Notes"],
                    "Fine Needle Aspiration Cytology (FNAC)": ["Cell Type", "Malignancy", "Cytologist Notes"],
                    "PAP Smear": ["Cell Abnormalities", "HPV Status", "Cervical Health"],
                    "Immunohistochemistry": ["Marker Expression", "Staining Intensity"],
                    "X-Ray": ["Findings", "Fracture Details", "Bone Alignment"],
                    "Ultrasound (USG)": ["Image Findings", "Measurements (cm)", "Doppler Flow"],
                    "CT Scan": ["Scan Results", "Lesion Details", "Contrast Usage"],
                    "MRI": ["Scan Results", "Abnormalities", "Tissue Density"],
                    "Mammography": ["Breast Density", "Calcifications", "Mass Detection", "BI-RADS Score"]
                ]
            )
            
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(initialTestFields)
                try data.write(to: testFieldsFileURL, options: [.atomic])
                print("Initialized test fields JSON file at: \(testFieldsFileURL.path())")
            } catch {
                print("Failed to initialize test fields JSON file: \(error.localizedDescription)")
            }
        }
        
        for (_, tests) in LabInfo.labTests {
            for test in tests {
                let fileURL = testResultsFileURL(for: test)
                if !FileManager.default.fileExists(atPath: fileURL.path()) {
                    let initialTestResults = LabTestResultsData(tests: [])
                    do {
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        let data = try encoder.encode(initialTestResults)
                        try data.write(to: fileURL, options: [.atomic])
                        print("Initialized test results JSON file for \(test) at: \(fileURL.path())")
                    } catch {
                        print("Failed to initialize test results JSON file for \(test): \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func loadTestFields() -> [String: [String]]? {
        do {
            let data = try Data(contentsOf: testFieldsFileURL)
            let decoder = JSONDecoder()
            let testFieldsData = try decoder.decode(TestFieldsData.self, from: data)
            return testFieldsData.testFields
        } catch {
            print("Failed to load test fields: \(error.localizedDescription)")
            return nil
        }
    }
    
    func loadLabTestResults(for test: String) -> LabTestResultsData? {
        let fileURL = testResultsFileURL(for: test)
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let testResults = try decoder.decode(LabTestResultsData.self, from: data)
            return testResults
        } catch {
            print("Failed to load test results for \(test): \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveLabTestResults(_ results: LabTestResultsData, for test: String) -> Bool {
        let fileURL = testResultsFileURL(for: test)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(results)
            try data.write(to: fileURL, options: [.atomic])
            print("Saved test results for \(test) to JSON file at: \(fileURL.path())")
            return true
        } catch {
            print("Failed to save test results for \(test): \(error.localizedDescription)")
            return false
        }
    }
    
    func fetchLabResult(patientID: String, test: String) -> LabResult? {
        guard let testResultsData = loadLabTestResults(for: test) else {
            return nil
        }
        return testResultsData.tests.first { $0.patientID == patientID && $0.test == test }
    }
    
    func saveLabResult(_ result: LabResult, completion: (Bool) -> Void) {
        guard let testResultsData = loadLabTestResults(for: result.test) else {
            var newResults = LabTestResultsData(tests: [result])
            let success = saveLabTestResults(newResults, for: result.test)
            completion(success)
            return
        }
        
        var updatedResults = testResultsData
        updatedResults.tests.append(result)
        
        let success = saveLabTestResults(updatedResults, for: result.test)
        completion(success)
    }
    
    func loadAllResultsForPatient(patientID: String) -> [LabResult] {
        var allResults: [LabResult] = []
        for (_, tests) in LabInfo.labTests {
            for test in tests {
                if let testResultsData = loadLabTestResults(for: test) {
                    let patientResults = testResultsData.tests.filter { $0.patientID == patientID }
                    allResults.append(contentsOf: patientResults)
                }
            }
        }
        return allResults
    }
}

// Patient Login Model (Simulated)
struct PatientUser {
    let id: String
    let name: String
    let email: String
}

// Main Lab Technician View
struct LabTechnicianView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText = ""
    @State private var selectedTestType = "All Tests"
    @State private var currentTechnician: LabTechnician
    @State private var opacity: Double = 0.0
    @State private var iconScale: CGFloat = 0.8
    @State private var showProfile = false
    @State private var testFilter: String = "Upcoming"
    @State private var patients: [LabPatient] = [
        LabPatient(name: "John Doe", test: "Complete Blood Count (CBC)", date: "2025-05-01", time: "10:00 AM", details: "Male, 35 years, ID: P123", status: "Pending", priority: "Normal", contact: "john.doe@email.com", lab: "Pathology Lab"),
        LabPatient(name: "Jane Smith", test: "MRI", date: "2025-05-01", time: "11:30 AM", details: "Female, 28 years, ID: P124", status: "Completed", priority: "High", contact: "jane.smith@email.com", lab: "Radiology Lab"),
        LabPatient(name: "Alice Brown", test: "Urinalysis", date: "2025-05-02", time: "09:15 AM", details: "Female, 42 years, ID: P125", status: "Pending", priority: "Low", contact: "alice.brown@email.com", lab: "Pathology Lab"),
        LabPatient(name: "Bob Johnson", test: "X-Ray", date: "2025-05-02", time: "02:00 PM", details: "Male, 50 years, ID: P126", status: "In Progress", priority: "Normal", contact: "bob.johnson@email.com", lab: "Radiology Lab"),
        LabPatient(name: "Emily Davis", test: "CT Scan", date: "2025-05-03", time: "01:00 PM", details: "Female, 19 years, ID: P127", status: "Pending", priority: "High", contact: "emily.davis@email.com", lab: "Radiology Lab"),
        LabPatient(name: "Michael Lee", test: "Ultrasound (USG)", date: "2025-05-03", time: "03:30 PM", details: "Male, 29 years, ID: P128", status: "Pending", priority: "Normal", contact: "michael.lee@email.com", lab: "Radiology Lab"),
        LabPatient(name: "Sarah Wilson", test: "Blood Glucose (Fasting, PP)", date: "2025-05-04", time: "08:45 AM", details: "Female, 37 years, ID: P129", status: "Completed", priority: "Low", contact: "sarah.wilson@email.com", lab: "Biochemistry Lab"),
        LabPatient(name: "David Kim", test: "Sputum AFB", date: "2025-05-04", time: "10:15 AM", details: "Male, 45 years, ID: P130", status: "In Progress", priority: "High", contact: "david.kim@email.com", lab: "Microbiology Lab"),
        LabPatient(name: "Laura Adams", test: "Biopsy Analysis", date: "2025-05-05", time: "09:00 AM", details: "Female, 52 years, ID: P131", status: "Pending", priority: "Normal", contact: "laura.adams@email.com", lab: "Histopathology Lab"),
        LabPatient(name: "Tom Clark", test: "Fine Needle Aspiration Cytology (FNAC)", date: "2025-05-05", time: "11:00 AM", details: "Male, 60 years, ID: P132", status: "Pending", priority: "High", contact: "tom.clark@email.com", lab: "Histopathology Lab")
    ]
    
    var testTypes: [String] {
        ["All Tests"] + (LabInfo.labTests[currentTechnician.lab] ?? [])
    }
    
    var filteredPatients: [LabPatient] {
        patients.filter { patient in
            patient.lab == currentTechnician.lab &&
            (selectedTestType == "All Tests" || patient.test == selectedTestType) &&
            (searchText.isEmpty || patient.name.lowercased().contains(searchText.lowercased())) &&
            (testFilter == "Upcoming" ? ["Pending", "In Progress"].contains(patient.status) : patient.status == "Completed")
        }
    }
    
    init() {
        _currentTechnician = State(initialValue: LabTechnician(name: "Dr. Sarah Wilson", email: "sarah.wilson@hospital.com", lab: "Radiology Lab"))
        FileManagerHelper.shared.initializeJSONFiles()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [ColorSet.primaryBackground, ColorSet.secondaryBackground]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ForEach(0..<6) { _ in
                    Circle()
                        .fill(ColorSet.accentBlue.opacity(colorScheme == .dark ? 0.04 : 0.02))
                        .frame(width: CGFloat.random(in: 60...180))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                        .blur(radius: 4)
                }
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(currentTechnician.lab) Dashboard")
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(ColorSet.primaryText)
                                Text(currentTechnician.name)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(ColorSet.secondaryText)
                            }
                            Spacer()
                            Button(action: {
                                triggerHaptic()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    showProfile = true
                                }
                            }) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(ColorSet.accentBlue)
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .fill(ColorSet.cardBackground.opacity(0.8))
                                            .shadow(radius: 2)
                                    )
                                    .scaleEffect(iconScale)
                            }
                            .accessibilityLabel("Profile")
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        
                        // Search and Filter
                        HStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(ColorSet.secondaryText)
                                    .frame(width: 20)
                                TextField("Search Patients", text: $searchText)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(ColorSet.primaryText)
                                if !searchText.isEmpty {
                                    Button(action: { searchText = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(ColorSet.secondaryText)
                                    }
                                    .accessibilityLabel("Clear Search")
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(ColorSet.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(ColorSet.borderGradient, lineWidth: 1)
                            )
                            
                            Picker("Test Type", selection: $selectedTestType) {
                                ForEach(testTypes, id: \.self) { type in
                                    Text(type).tag(type)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(ColorSet.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(ColorSet.borderGradient, lineWidth: 1)
                            )
                            .frame(maxWidth: 160)
                        }
                        .padding(.horizontal, 16)
                        
                        // Status Filter
                        Picker("Test Filter", selection: $testFilter) {
                            Text("Upcoming").tag("Upcoming")
                            Text("Completed").tag("Completed")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(ColorSet.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ColorSet.borderGradient, lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        // Patient List
                        LazyVStack(spacing: 12) {
                            ForEach(filteredPatients) { patient in
                                NavigationLink(
                                    destination: PatientDetailView(
                                        patient: patient,
                                        onSubmit: { updatedPatient in
                                            if let index = patients.firstIndex(where: { $0.id == updatedPatient.id }) {
                                                patients[index] = updatedPatient
                                            }
                                        }
                                    )
                                ) {
                                    PatientCardView(patient: patient)
                                        .padding(.horizontal, 16)
                                }
                                .simultaneousGesture(TapGesture().onEnded {
                                    triggerHaptic()
                                })
                            }
                        }
                        .padding(.top, 12)
                    }
                    .padding(.bottom, 24)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            opacity = 1.0
                        }
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                            iconScale = 1.0
                        }
                    }
                }
            }
            .sheet(isPresented: $showProfile) {
                LabTechProfileView(technician: currentTechnician)
            }
            .navigationBarHidden(true)
        }
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// Patient Card View
struct PatientCardView: View {
    let patient: LabPatient
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(patient.name)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(ColorSet.accentBlue)
            Text(patient.test)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(ColorSet.secondaryText)
            Text("\(patient.date) • \(patient.time)")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(ColorSet.secondaryText)
            HStack(spacing: 8) {
                Text(patient.status)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(statusColor(for: patient.status).opacity(0.15))
                    .foregroundColor(statusColor(for: patient.status))
                    .clipShape(Capsule())
                Text(patient.priority)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(priorityColor(for: patient.priority).opacity(0.15))
                    .foregroundColor(priorityColor(for: patient.priority))
                    .clipShape(Capsule())
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(ColorSet.accentBlue.opacity(0.7))
                    .font(.system(size: 14, weight: .medium))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ColorSet.cardBackground)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.15), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ColorSet.borderGradient, lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            TapGesture().onEnded {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPressed = false
                    }
                }
            }
        )
    }
    
    func statusColor(for status: String) -> Color {
        switch status {
        case "Completed": return ColorSet.accentGreen
        case "In Progress": return .orange
        default: return ColorSet.accentBlue
        }
    }
    
    func priorityColor(for priority: String) -> Color {
        switch priority {
        case "High": return ColorSet.accentRed
        case "Normal": return ColorSet.accentBlue
        default: return ColorSet.secondaryText
        }
    }
}

// Patient Detail View
struct PatientDetailView: View {
    let patient: LabPatient
    let onSubmit: (LabPatient) -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var opacity: Double = 0.0
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [ColorSet.primaryBackground, ColorSet.secondaryBackground]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ForEach(0..<6) { _ in
                Circle()
                    .fill(ColorSet.accentBlue.opacity(colorScheme == .dark ? 0.04 : 0.02))
                    .frame(width: CGFloat.random(in: 60...180))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: 4)
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(patient.name)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(ColorSet.primaryText)
                        Text(patient.details)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(ColorSet.secondaryText)
                        Divider()
                            .background(ColorSet.secondaryText.opacity(0.3))
                        HStack(alignment: .top, spacing: 24) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Test: \(patient.test)")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(ColorSet.accentBlue)
                                Text("Date: \(patient.date)")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(ColorSet.secondaryText)
                                Text("Time: \(patient.time)")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(ColorSet.secondaryText)
                            }
                            Spacer()
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Status: \(patient.status)")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(ColorSet.secondaryText)
                                Text("Priority: \(patient.priority)")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(ColorSet.secondaryText)
                                Text("Contact: \(patient.contact)")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(ColorSet.secondaryText)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(ColorSet.cardBackground)
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.15), radius: 6, x: 0, y: 3)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ColorSet.borderGradient, lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    
                    NavigationLink(
                        destination: LabReportView(
                            patient: patient,
                            onSubmit: { updatedPatient in
                                onSubmit(updatedPatient)
                            }
                        )
                    ) {
                        Text("Mark Test as Done")
                            .modifier(CustomButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            triggerHaptic()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isPressed = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isPressed = false
                                }
                            }
                        }
                    )
                    .accessibilityLabel("Mark Test as Done")
                    
                    Button(action: {
                        triggerHaptic()
                        print("Contacting \(patient.contact)")
                    }) {
                        Text("Contact Patient")
                            .modifier(CustomButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isPressed = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isPressed = false
                                }
                            }
                        }
                    )
                    .accessibilityLabel("Contact Patient")
                    
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 24)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        opacity = 1.0
                    }
                }
            }
        }
        .navigationTitle("Patient Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// Lab Report View
struct LabReportView: View {
    let patient: LabPatient
    let onSubmit: (LabPatient) -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var reportDetails = ""
    @State private var additionalFields: [String: String] = [:]
    @State private var uploadedFileName: String? = nil
    @State private var testFields: [String] = []
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var opacity: Double = 0.0
    @State private var isPressed = false
    @State private var labResult: LabResult? = nil
    
    var isCompleted: Bool {
        patient.status == "Completed"
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [ColorSet.primaryBackground, ColorSet.secondaryBackground]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ForEach(0..<6) { _ in
                Circle()
                    .fill(ColorSet.accentBlue.opacity(colorScheme == .dark ? 0.04 : 0.02))
                    .frame(width: CGFloat.random(in: 60...180))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: 4)
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lab Report for \(patient.name)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(ColorSet.primaryText)
                        Text("Test: \(patient.test)")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(ColorSet.secondaryText)
                        Text("Status: \(patient.status)")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(ColorSet.secondaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    
                    if isCompleted, let result = labResult {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Test Parameters")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(ColorSet.accentBlue)
                            ForEach(result.parameters.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                if !value.isEmpty {
                                    HStack {
                                        Text(key)
                                            .font(.system(size: 14, weight: .regular, design: .rounded))
                                            .foregroundColor(ColorSet.secondaryText)
                                        Spacer()
                                        Text(value)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(ColorSet.primaryText)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ColorSet.cardBackground)
                                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.15), radius: 6, x: 0, y: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ColorSet.borderGradient, lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        if let file = result.uploadedFile, !file.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Uploaded Image")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(ColorSet.accentBlue)
                                HStack {
                                    Image(systemName: "photo")
                                        .foregroundColor(.white)
                                    Text(file)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(18)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hex: "4A90E2"),
                                                    Color(hex: "5E5CE6")
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ColorSet.borderGradient, lineWidth: 1)
                                )
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(ColorSet.cardBackground)
                                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.15), radius: 6, x: 0, y: 3)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(ColorSet.borderGradient, lineWidth: 1)
                            )
                            .padding(.horizontal, 16)
                        }
                        
                        if !result.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Additional Notes")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(ColorSet.accentBlue)
                                Text(result.notes)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(ColorSet.primaryText)
                                    .padding(12)
                                    .background(ColorSet.cardBackground.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(ColorSet.borderGradient, lineWidth: 1)
                                    )
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(ColorSet.cardBackground)
                                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.15), radius: 6, x: 0, y: 3)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(ColorSet.borderGradient, lineWidth: 1)
                            )
                            .padding(.horizontal, 16)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Test Parameters")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(ColorSet.accentBlue)
                            ForEach(testFields, id: \.self) { field in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(field)
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(ColorSet.secondaryText)
                                    TextField("Enter \(field)", text: Binding(
                                        get: { additionalFields[field] ?? "" },
                                        set: { additionalFields[field] = $0 }
                                    ))
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(ColorSet.primaryText)
                                    .padding(12)
                                    .background(ColorSet.cardBackground.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(ColorSet.borderGradient, lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ColorSet.cardBackground)
                                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.15), radius: 6, x: 0, y: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ColorSet.borderGradient, lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        if ["X-Ray", "Ultrasound (USG)", "CT Scan", "MRI", "Mammography"].contains(patient.test) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Upload Image")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(ColorSet.accentBlue)
                                Button(action: {
                                    triggerHaptic()
                                    uploadedFileName = "Sample_\(patient.test)_Image.jpg"
                                }) {
                                    HStack {
                                        Image(systemName: "photo")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .padding(.trailing, 8)
                                        Text(uploadedFileName ?? "Choose File")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .modifier(CustomButtonStyle())
                                }
                                .accessibilityLabel("Upload Image")
                            }
                            .padding(.top, 12)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(ColorSet.cardBackground)
                                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.15), radius: 6, x: 0, y: 3)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(ColorSet.borderGradient, lineWidth: 1)
                            )
                            .padding(.horizontal, 16)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Additional Notes")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(ColorSet.accentBlue)
                            TextEditor(text: $reportDetails)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.primaryText)
                                .frame(height: 120)
                                .padding(12)
                                .background(ColorSet.cardBackground.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ColorSet.borderGradient, lineWidth: 1)
                                )
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ColorSet.cardBackground)
                                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.15), radius: 6, x: 0, y: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(ColorSet.borderGradient, lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        Button(action: {
                            triggerHaptic()
                            let patientID = patient.details.components(separatedBy: "ID: ").last ?? "Unknown"
                            let result = LabResult(
                                patientID: patientID,
                                test: patient.test,
                                parameters: additionalFields,
                                notes: reportDetails,
                                uploadedFile: uploadedFileName,
                                timestamp: ISO8601DateFormatter().string(from: Date())
                            )
                            
                            FileManagerHelper.shared.saveLabResult(result) { success in
                                if success {
                                    var updatedPatient = patient
                                    updatedPatient.status = "Completed"
                                    onSubmit(updatedPatient)
                                    
                                    reportDetails = ""
                                    additionalFields = [:]
                                    uploadedFileName = nil
                                } else {
                                    errorMessage = "Failed to save lab result."
                                    showErrorAlert = true
                                }
                            }
                        }) {
                            Text("Submit Report")
                                .modifier(CustomButtonStyle())
                        }
                        .padding(.horizontal, 16)
                        .simultaneousGesture(
                            TapGesture().onEnded {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isPressed = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        isPressed = false
                                    }
                                }
                            }
                        )
                        .accessibilityLabel("Submit Report")
                        .alert(isPresented: $showErrorAlert) {
                            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 24)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        opacity = 1.0
                    }
                    if let testFieldsData = FileManagerHelper.shared.loadTestFields() {
                        testFields = testFieldsData[patient.test] ?? []
                    } else {
                        errorMessage = "Failed to load test fields."
                        showErrorAlert = true
                    }
                    let patientID = patient.details.components(separatedBy: "ID: ").last ?? "Unknown"
                    labResult = FileManagerHelper.shared.fetchLabResult(patientID: patientID, test: patient.test)
                    if labResult == nil && isCompleted {
                        errorMessage = "No lab result found for this completed test."
                        showErrorAlert = true
                    }
                }
            }
        }
        .navigationTitle("Lab Report")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// Profile View for Lab Technician
struct LabTechProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var technician: LabTechnician
    @State private var name: String
    @State private var email: String
    @State private var role = "Senior Lab Technician"
    @State private var phone = "+1 (555) 123-4567"
    @State private var qualifications = "BSc Medical Laboratory Science, ASCP Certified"
    @State private var licenseNumber = "MLT-789012"
    @State private var department: String
    @State private var yearsOfExperience = "12"
    @State private var hospitalID = "HOSP-45678"
    @State private var opacity: Double = 0.0
    @State private var isPressed = false
    
    init(technician: LabTechnician) {
        self.technician = technician
        _name = State(initialValue: technician.name)
        _email = State(initialValue: technician.email)
        _department = State(initialValue: technician.lab)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [ColorSet.primaryBackground, ColorSet.secondaryBackground]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ForEach(0..<6) { _ in
                Circle()
                    .fill(ColorSet.accentBlue.opacity(colorScheme == .dark ? 0.04 : 0.02))
                    .frame(width: CGFloat.random(in: 60...180))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: 4)
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(ColorSet.accentBlue)
                        Text(name)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(ColorSet.primaryText)
                        Text(role)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(ColorSet.secondaryText)
                        Text(department)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(ColorSet.secondaryText)
                        Text(hospitalID)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(ColorSet.secondaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Profile Details")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(ColorSet.accentBlue)
                            .padding(.bottom, 4)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Name")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.secondaryText)
                            TextField("Enter name", text: $name)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.primaryText)
                                .padding(12)
                                .background(ColorSet.cardBackground.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ColorSet.borderGradient, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.secondaryText)
                            TextField("Enter email", text: $email)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.primaryText)
                                .padding(12)
                                .background(ColorSet.cardBackground.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ColorSet.borderGradient, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Phone")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.secondaryText)
                            TextField("Enter phone", text: $phone)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.primaryText)
                                .padding(12)
                                .background(ColorSet.cardBackground.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ColorSet.borderGradient, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Qualifications")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.secondaryText)
                            TextField("Enter qualifications", text: $qualifications)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.primaryText)
                                .padding(12)
                                .background(ColorSet.cardBackground.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ColorSet.borderGradient, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("License Number")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.secondaryText)
                            TextField("Enter license number", text: $licenseNumber)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.primaryText)
                                .padding(12)
                                .background(ColorSet.cardBackground.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ColorSet.borderGradient, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Department")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.secondaryText)
                            TextField("Enter department", text: $department)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.primaryText)
                                .padding(12)
                                .background(ColorSet.cardBackground.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ColorSet.borderGradient, lineWidth: 1)
                                )
                                .disabled(true)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Years of Experience")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.secondaryText)
                            TextField("Enter years of experience", text: $yearsOfExperience)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.primaryText)
                                .padding(12)
                                .background(ColorSet.cardBackground.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(ColorSet.borderGradient, lineWidth: 1)
                                )
                                .keyboardType(.numberPad)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(ColorSet.cardBackground)
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.15), radius: 6, x: 0, y: 3)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ColorSet.borderGradient, lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    
                    Button(action: {
                        triggerHaptic()
                        print("Profile changes saved: \(name), \(email), \(phone), \(qualifications), \(licenseNumber), \(department), \(yearsOfExperience)")
                    }) {
                        Text("Save Changes")
                            .modifier(CustomButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isPressed = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isPressed = false
                                }
                            }
                        }
                    )
                    .accessibilityLabel("Save Profile Changes")
                    
                    Button(action: {
                        triggerHaptic()
                        print("Logged out")
                    }) {
                        Text("Log Out")
                            .modifier(CustomButtonStyle())
                    }
                    .padding(.horizontal, 16)
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isPressed = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isPressed = false
                                }
                            }
                        }
                    )
                    .accessibilityLabel("Log Out")
                    
                    Spacer()
                }
                .padding(.bottom, 24)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        opacity = 1.0
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// Patient Results View
struct PatientResultsView: View {
    let patientUser: PatientUser
    @Environment(\.colorScheme) var colorScheme
    @State private var results: [LabResult] = []
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var opacity: Double = 0.0
    @State private var iconScale: CGFloat = 0.8
    @State private var showProfile = false
    
    var filteredResults: [LabResult] {
        results.filter { $0.patientID == patientUser.id }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [ColorSet.primaryBackground, ColorSet.secondaryBackground]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ForEach(0..<6) { _ in
                    Circle()
                        .fill(ColorSet.accentBlue.opacity(colorScheme == .dark ? 0.04 : 0.02))
                        .frame(width: CGFloat.random(in: 60...180))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                        .blur(radius: 4)
                }
                
                ScrollView {
                    VStack(spacing: 16) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Your Lab Results")
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(ColorSet.primaryText)
                                Text(patientUser.name)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(ColorSet.secondaryText)
                            }
                            Spacer()
                            Button(action: {
                                triggerHaptic()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    showProfile = true
                                }
                            }) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(ColorSet.accentBlue)
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .fill(ColorSet.cardBackground.opacity(0.8))
                                            .shadow(radius: 2)
                                    )
                                    .scaleEffect(iconScale)
                            }
                            .accessibilityLabel("Profile")
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        
                        if filteredResults.isEmpty {
                            Text("No results available.")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(ColorSet.secondaryText)
                                .padding(.vertical, 24)
                        } else {
                            ForEach(filteredResults, id: \.timestamp) { result in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(result.test)
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .foregroundColor(ColorSet.accentBlue)
                                    Text("Date: \(formatTimestamp(result.timestamp))")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(ColorSet.secondaryText)
                                    
                                    ForEach(result.parameters.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                        if !value.isEmpty {
                                            HStack {
                                                Text(key)
                                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                                    .foregroundColor(ColorSet.secondaryText)
                                                Spacer()
                                                Text(value)
                                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                                    .foregroundColor(ColorSet.primaryText)
                                            }
                                        }
                                    }
                                    
                                    if !result.notes.isEmpty {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("Notes")
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                .foregroundColor(ColorSet.accentBlue)
                                            Text(result.notes)
                                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                                .foregroundColor(ColorSet.secondaryText)
                                        }
                                    }
                                    
                                    if let file = result.uploadedFile {
                                        Button(action: {
                                            triggerHaptic()
                                            print("Opening file: \(file)")
                                        }) {
                                            HStack {
                                                Image(systemName: "photo")
                                                    .foregroundColor(.white)
                                                Text(file)
                                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                                    .foregroundColor(.white)
                                            }
                                            .modifier(CustomButtonStyle())
                                        }
                                        .accessibilityLabel("View Uploaded File")
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(ColorSet.cardBackground)
                                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.15), radius: 6, x: 0, y: 3)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(ColorSet.borderGradient, lineWidth: 1)
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 24)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            opacity = 1.0
                        }
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                            iconScale = 1.0
                        }
                        results = FileManagerHelper.shared.loadAllResultsForPatient(patientID: patientUser.id)
                        if results.isEmpty && !filteredResults.isEmpty {
                            errorMessage = "Failed to load lab results."
                            showErrorAlert = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showProfile) {
                LabTechProfileView(technician: LabTechnician(name: patientUser.name, email: patientUser.email, lab: "Patient"))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Lab Results")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(ColorSet.primaryText)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        triggerHaptic()
                        print("Patient logged out")
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "4A90E2"),
                                                Color(hex: "5E5CE6")
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: Color(hex: "4A90E2").opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .accessibilityLabel("Log Out")
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func formatTimestamp(_ timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return timestamp
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// Main App View
struct ContentView: View {
    @State private var isPatientLoggedIn = false
    @State private var patientUser: PatientUser? = PatientUser(id: "P123", name: "John Doe", email: "john.doe@email.com")
    
    var body: some View {
        if isPatientLoggedIn, let patientUser = patientUser {
            PatientResultsView(patientUser: patientUser)
        } else {
            LabTechnicianView()
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
