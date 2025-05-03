//
//  PrescriptionFormView.swift
//  Hospitality
//
//  Created by admin65 on 22/04/25.
//

import SwiftUI

struct PrescriptionFormView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var prescription = Prescription(
        medicines: [],
        suggestedTests: "",
        followUpRequired: false,
        followUpDate: nil,
        doctorNotes: ""
    )
    @State private var doctorNoteInput: String = ""
    @State private var doctorNotePoints: [String] = []
    @State private var editingIndex: Int? = nil
    @State private var isAddingNote = false
    
    @State private var isEditingMedicine = false
    @State private var editingMedicineIndex: Int? = nil
    
    @State private var showSubmissionAlert = false
    
    // Form inputs separately
    @State private var newMedicineName: String = ""
    @State private var newDosage: String = ""
    @State private var newNumberOfDays: Int = 1
    @State private var newTimesPerDay: Int = 1
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case medicineName, dosage, suggestedTests, doctorNotes
    }
    
    let availableOrgans: [TargetOrgan] = [
        TargetOrgan(id: "1", targetOrganName: "Lung", targetOrganRemark: nil),
        TargetOrgan(id: "2", targetOrganName: "Stomach", targetOrganRemark: nil),
        TargetOrgan(id: "3", targetOrganName: "Heart", targetOrganRemark: nil)
    ]
    
    @State private var selectedOrganForNote: [Int: TargetOrgan] = [:] // Mapping note index to selected organ
    @State private var showOrganPickerForNote: NoteIndexWrapper? = nil
    
    private var medicationsSection: some View {
        Section(header: Text("Medications")) {
            ForEach(prescription.medicines.indices, id: \.self) { index in
                medicineRow(for: index)
            }
            .onDelete { indexSet in
                prescription.medicines.remove(atOffsets: indexSet)
            }
            
            VStack {
                TextField("Medicine Name", text: $newMedicineName)
                TextField("Dosage (e.g., 500mg)", text: $newDosage)
                Stepper("Days: \(newNumberOfDays)", value: $newNumberOfDays, in: 1...365)
                Stepper("Times per Day: \(newTimesPerDay)", value: $newTimesPerDay, in: 1...5)
                
                medicineActionButtons
            }
        }
    }
    
    private func medicineRow(for index: Int) -> some View {
        let prescribed = prescription.medicines[index]
        return VStack(alignment: .leading) {
            Text("\(prescribed.medicine.medicineName) - \(prescribed.prescribed.medicineDosage["dosage"] ?? "")")
            Text("Days: \(prescribed.prescribed.medicineDosage["days"] ?? "0"), \(prescribed.prescribed.medicineDosage["timesPerDay"] ?? "0") times a day")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            let med = prescribed
            newMedicineName = med.medicine.medicineName
            newDosage = med.prescribed.medicineDosage["dosage"] ?? ""
            newNumberOfDays = Int(med.prescribed.medicineDosage["days"] ?? "1") ?? 1
            newTimesPerDay = Int(med.prescribed.medicineDosage["timesPerDay"] ?? "1") ?? 1
            editingMedicineIndex = index
            isEditingMedicine = true
        }
    }
    
    private var medicineActionButtons: some View {
        HStack {
            if isEditingMedicine {
                Button {
                    if let index = editingMedicineIndex {
                        prescription.medicines[index] = makePrescribedMedicine()
                    }
                    clearMedicineForm()
                } label: {
                    Text("Update")
                        .foregroundColor(.accentColor)
                        .imageScale(.large)
                }
                
                Button("Cancel") {
                    clearMedicineForm()
                }
                .foregroundColor(.red)
            } else {
                Button("Add Medicine") {
                    prescription.medicines.append(makePrescribedMedicine())
                    clearMedicineForm()
                }
                .disabled(newMedicineName.isEmpty || newDosage.isEmpty)
            }
        }
    }
    
    
    var body: some View {
        
        ZStack {
            backgroundView
            
            Form {
                medicationsSection
                
                Section {
                    Toggle("Follow-up Required", isOn: $prescription.followUpRequired)
                    
                    if prescription.followUpRequired {
                        DatePicker("Follow-up Date", selection: Binding(
                            get: { prescription.followUpDate ?? Date() },
                            set: { prescription.followUpDate = $0 }
                        ), displayedComponents: .date)
                    }
                } header: {
                    Text("Follow-up")
                }
                
                doctorNotesSection
                
                
                
                
                Section {
                    Button("Submit Prescription") {
                        
                        printDoctorEnteredData(prescription: prescription)
                        
                        showSubmissionAlert = true
                        print("Submitted: \(prescription)")
                    }
                    .disabled(!isFormValid)
                }
            }
            .scrollContentBackground(.hidden)
            
            .navigationTitle("Prescription Form")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Prescription Sent", isPresented: $showSubmissionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The prescription has been successfully sent to the patient.")
        }
    }
    
    private var isFormValid: Bool {
        !prescription.medicines.isEmpty
    }
    
    private var doctorNotesSection: some View {
        Section(header: Text("Doctor's Notes")) {
            ForEach(doctorNotePoints.indices, id: \.self) { index in
                doctorNoteRow(for: index)
            }
            .onDelete { indices in
                doctorNotePoints.remove(atOffsets: indices)
                updatePrescriptionNotes()
            }
            
            if isAddingNote {
                HStack {
                    TextField("Enter note", text: $doctorNoteInput)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: {
                        saveDoctorNote()
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .imageScale(.large)
                    }
                }
            } else {
                Button("Add Note") {
                    isAddingNote = true
                }
            }
        }
        .sheet(item: $showOrganPickerForNote) { wrapper in
            let index = wrapper.index
            List {
                ForEach(availableOrgans) { organ in
                    Button(action: {
                        selectedOrganForNote[index] = organ
                        showOrganPickerForNote = nil
                    }) {
                        Text(organ.targetOrganName)
                    }
                }
            }
        }
    }
    
    private func doctorNoteRow(for index: Int) -> some View {
        HStack(alignment: .top) {
            Text("•").bold()
            VStack(alignment: .leading) {
                HStack {
                    Text(doctorNotePoints[index])
                        .onTapGesture {
                            doctorNoteInput = doctorNotePoints[index]
                            editingIndex = index
                            isAddingNote = true
                        }
                        .foregroundColor(editingIndex == index ? .blue : .primary)
                    
                    Spacer()
                    
                    Button(action: {
                        showOrganPickerForNote = NoteIndexWrapper(index: index)
                    }) {
                        Text(selectedOrganForNote[index]?.targetOrganName ?? "Select Organ")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .padding(6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                if let organ = selectedOrganForNote[index] {
                    Text("Organ: \(organ.targetOrganName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    private func organPicker(for index: Int) -> some View {
        List {
            ForEach(availableOrgans) { organ in
                Button(action: {
                    selectedOrganForNote[index] = organ
                    showOrganPickerForNote = nil
                }) {
                    Text(organ.targetOrganName)
                }
            }
        }
    }
    private func saveDoctorNote() {
        let trimmed = doctorNoteInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if let index = editingIndex {
            doctorNotePoints[index] = trimmed
            editingIndex = nil
        } else {
            doctorNotePoints.append(trimmed)
        }
        
        doctorNoteInput = ""
        isAddingNote = false
        updatePrescriptionNotes()
    }
    
    
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                colorScheme == .dark ? Color(hex: "101420") : Color(hex: "E8F5FF"),
                colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private func updatePrescriptionNotes() {
        prescription.doctorNotes = doctorNotePoints.map { "• \($0)" }.joined(separator: "\n")
    }
    
    private func clearMedicineForm() {
        newMedicineName = ""
        newDosage = ""
        newNumberOfDays = 1
        newTimesPerDay = 1
        isEditingMedicine = false
        editingMedicineIndex = nil
    }
    
    private func makePrescribedMedicine() -> PrescribedMedicineWrapper {
        
        
        let medicine = Medicine(
            medicineID: UUID().uuidString,
            medicineName: newMedicineName,
            medicineRemarks: ""
        )
        let prescribed = PrescribedMedicine(
            prescribedMedicineID: UUID().uuidString,
            prescriptionID: UUID().uuidString,
            medicineID: medicine.medicineID,
            medicineDosage: [
                "dosage": newDosage,
                "days": "\(newNumberOfDays)",
                "timesPerDay": "\(newTimesPerDay)"
            ],
            fastingRequired: "No"
        )
        return PrescribedMedicineWrapper(medicine: medicine, prescribed: prescribed)
    }
    
    func printDoctorEnteredData(prescription: Prescription) {
        print("\n=== DOCTOR ENTERED DATA ===")
        
        // Print Medications
        print("\nMEDICATIONS:")
        if prescription.medicines.isEmpty {
            print("No medications prescribed")
        } else {
            for (index, medicine) in prescription.medicines.enumerated() {
                print("\(index + 1). \(medicine.medicine.medicineName)")
                print("   - Dosage: \(medicine.prescribed.medicineDosage["dosage"] ?? "N/A")")
                print("   - Days: \(medicine.prescribed.medicineDosage["days"] ?? "N/A")")
                print("   - Times per day: \(medicine.prescribed.medicineDosage["timesPerDay"] ?? "N/A")")
                print("   - Fasting required: \(medicine.prescribed.fastingRequired)")
            }
        }
        
        // Print Follow-up Information
        print("\nFOLLOW-UP:")
        print("- follow_up_required: \(prescription.followUpRequired)")
        if prescription.followUpRequired, let date = prescription.followUpDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            print("- follow_up_date: \(formatter.string(from: date))")
        }
        
        // Print Doctor's Notes in diagnosis format
        print("\nDIAGNOSIS NOTES:")
        if doctorNotePoints.isEmpty {
            print("No diagnosis notes added")
        } else {
            // Group notes by organ
            var organNotes: [String: [String]] = [:]
            
            for (index, note) in doctorNotePoints.enumerated() {
                let organ = selectedOrganForNote[index]?.targetOrganName ?? "general"
                if organNotes[organ] == nil {
                    organNotes[organ] = []
                }
                organNotes[organ]?.append(note)
            }
            
            // Print in JSON-like format
            print("{")
            for (organ, notes) in organNotes {
                print("    \"\(organ.lowercased())\": \(notes),")
            }
            print("}")
        }
        
        // Print Suggested Tests and lab test requirement
        print("\nTESTS:")
        print("- lab_test_required: \(!prescription.suggestedTests.isEmpty)")
        if !prescription.suggestedTests.isEmpty {
            print("- suggested_tests: \"\(prescription.suggestedTests)\"")
        }
        
        print("\n=== END OF DATA ===")
    }
}

// MARK: - Temporary Wrappers
struct Prescription {
    var medicines: [PrescribedMedicineWrapper]
    var suggestedTests: String
    var followUpRequired: Bool
    var followUpDate: Date?
    var doctorNotes: String
}

struct PrescribedMedicineWrapper: Identifiable {
    var id = UUID()
    var medicine: Medicine
    var prescribed: PrescribedMedicine
}

// Assuming your color hex init
// MARK: - Temporary Models for UI Handling
struct PrescribedMedicineUI: Identifiable {
    var id: String
    var medicine: Medicine
    var dosageText: String
    var numberOfDays: Int
    var timesPerDay: Int
}

// MARK: - Color Extension
struct PrescriptionFormView_Previews: PreviewProvider {
    static var previews: some View {
        PrescriptionFormView()
    }
}
struct NoteIndexWrapper: Identifiable {
    var id: Int { index }
    var index: Int
}




// MARK: - Color Extension
//private extension Color {
//    init(hex: String) {
//        let scanner = Scanner(string: hex)
//        _ = scanner.scanString("#")
//        
//        var rgb: UInt64 = 0
//        scanner.scanHexInt64(&rgb)
//        
//        let r = Double((rgb >> 16) & 0xFF) / 255
//        let g = Double((rgb >> 8) & 0xFF) / 255
//        let b = Double(rgb & 0xFF) / 255
//        
//        self.init(red: r, green: g, blue: b)
//    }
//}

//// MARK: - Preview
//struct PrescriptionFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        PrescriptionFormView()
//    }
//}
