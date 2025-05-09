import SwiftUI

struct DoctorConsultationView: View {
    @StateObject private var viewModel: DoctorPrescriptionViewModel
    @State private var activeTab = 0
    @State private var showSuccess = false
    @State private var labTestSearchText = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    init(appointmentId: Int) {
        print("[swatiswapna] 2025-05-07 01:21:00: Initializing consultation view with appointment ID: \(appointmentId)")
        _viewModel = StateObject(wrappedValue: DoctorPrescriptionViewModel(appointmentId: appointmentId))
    }
    
    // MARK: - Color Scheme
    private let primaryColor = Color(hex: "0077CC")
    private let secondaryColor = Color(hex: "00A3A3")
    private let accentColor = Color(hex: "F5A623")
    private let backgroundColor = Color(hex: "F7FAFF")
    private let cardColor = Color(hex: "FFFFFF")
    private let darkCardColor = Color(hex: "1A2234")
    
    private var shouldDisableSubmitButton: Bool {
        viewModel.isLoading ||
        viewModel.selectedOrgans.isEmpty ||
        viewModel.prescriptionMedicines.isEmpty ||
        (viewModel.labTestRequired && viewModel.selectedLabTests.isEmpty)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color(hex: "101420") : Color(hex: "E8F5FF"),
                        colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "F0F8FF")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tab selector
                    Picker("Consultation Section", selection: $activeTab) {
                        Text("Diagnosis").tag(0)
                        Text("Prescription").tag(1)
                        if viewModel.labTestRequired {
                            Text("Lab Tests").tag(2)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    // Content tabs
                    TabView(selection: $activeTab) {
                        diagnosisFormView
                            .tag(0)
                        
                        prescriptionFormView
                            .tag(1)
                        
                        if viewModel.labTestRequired {
                            labTestsFormView
                                .tag(2)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Submit button
                    Button(action: {
                        viewModel.submitAll()
                    }) {
                        HStack {
                            Text("Submit All")
                                .fontWeight(.semibold)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.leading, 5)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(shouldDisableSubmitButton ? Color.gray : primaryColor)
                                .shadow(color: shouldDisableSubmitButton ? Color.gray.opacity(0.3) : primaryColor.opacity(0.3), radius: 4, y: 2)
                        )
                        .foregroundColor(.white)
                    }
                    .padding(16)
                    .disabled(shouldDisableSubmitButton)
                }
            }
            .navigationTitle("Patient Consultation")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text(viewModel.successMessage ?? "Consultation completed successfully.")
            }
            .onChange(of: viewModel.successMessage) { newValue in
                if newValue != nil {
                    showSuccess = true
                }
            }
        }
        .onAppear {
            viewModel.fetchAllData()
        }
        .accentColor(primaryColor)
    }
    
    // MARK: - Diagnosis Form
    private var diagnosisFormView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ConsultationCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Diagnosis")
                            .font(.headline)
                            .foregroundColor(primaryColor)
                        
                        if viewModel.selectedOrgans.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "heart.circle")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("No diagnosis added")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 24)
                                Spacer()
                            }
                        } else {
                            ForEach(viewModel.selectedOrgans.indices, id: \.self) { index in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(viewModel.selectedOrgans[index].organ)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            viewModel.removeDiagnosisItem(at: index)
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .padding(8)
                                                .background(Circle().fill(Color.red.opacity(0.1)))
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    // Symptoms tags
                                    Text("Symptoms:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 6) {
                                            ForEach(viewModel.selectedOrgans[index].symptoms, id: \.self) { symptom in
                                                Text(symptom)
                                                    .font(.caption)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 5)
                                                    .background(
                                                        Capsule()
                                                            .fill(primaryColor.opacity(0.15))
                                                    )
                                                    .foregroundColor(primaryColor)
                                            }
                                        }
                                    }
                                    
                                    if !viewModel.selectedOrgans[index].notes.isEmpty {
                                        Text("Notes: \(viewModel.selectedOrgans[index].notes)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.top, 5)
                                    }
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.tertiarySystemBackground))
                                )
                                
                                if index < viewModel.selectedOrgans.count - 1 {
                                    Spacer().frame(height: 8)
                                }
                            }
                        }
                        
                        Button(action: {
                            showingOrganSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Diagnosis")
                            }
                            .foregroundColor(primaryColor)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(primaryColor, lineWidth: 1)
                            )
                        }
                        .padding(.top, 8)
                    }
                }
                
                // Additional options card
                ConsultationCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Additional Options")
                            .font(.headline)
                            .foregroundColor(primaryColor)
                        
                        Toggle("Lab Test Required", isOn: $viewModel.labTestRequired)
                            .tint(primaryColor)
                            .padding(.vertical, 4)
                        
                        Divider()
                        
                        Toggle("Follow-up Required", isOn: $viewModel.followUpRequired)
                            .tint(primaryColor)
                            .padding(.vertical, 4)
                        
                        if viewModel.followUpRequired {
                            DatePicker("Follow-up Date", selection: Binding(
                                get: { viewModel.followUpDate ?? Date().addingTimeInterval(86400 * 7) },
                                set: { viewModel.followUpDate = $0 }
                            ), displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .padding(16)
        }
        .sheet(isPresented: $showingOrganSheet) {
            organSelectionSheet
        }
    }
    
    // MARK: - Organ Selection Sheet
    @State private var showingOrganSheet = false
    @State private var selectedOrgan: String = ""
    @State private var organSymptoms: String = ""
    @State private var organNotes: String = ""
    
    private var organSelectionSheet: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Grid-based organ picker layout
                        ConsultationCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Organs Affected")
                                    .font(.headline)
                                    .foregroundColor(primaryColor)
                                
                                
                                let organsPerRow = 10
                              
                                let rows = stride(from: 0, to: viewModel.targetOrgans.count, by: organsPerRow).map {
                                    Array(viewModel.targetOrgans[$0..<min($0 + organsPerRow, viewModel.targetOrgans.count)])
                                }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(0..<rows.count, id: \.self) { rowIndex in
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 8) {
                                                ForEach(rows[rowIndex]) { organ in
                                                    Button(action: {
                                                        selectedOrgan = organ.targetOrganName
                                                    }) {
                                                        Text(organ.targetOrganName)
                                                            .font(.footnote)
                                                            .fontWeight(selectedOrgan == organ.targetOrganName ? .semibold : .regular)
                                                            .lineLimit(1)
                                                            .padding(.vertical, 8)
                                                            .padding(.horizontal, 12)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                    .fill(selectedOrgan == organ.targetOrganName ?
                                                                          primaryColor :
                                                                            (colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color(UIColor.secondarySystemBackground)))
                                                            )
                                                            .foregroundColor(selectedOrgan == organ.targetOrganName ? .white : .primary)
                                                    }
                                                    .frame(height: 36)
                                                }
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                    }
                                }
                                
                                // Selected organ indicator
                                if !selectedOrgan.isEmpty {
                                    HStack {
                                        Text("Selected: ")
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                        
                                        Text(selectedOrgan)
                                            .fontWeight(.medium)
                                            .foregroundColor(primaryColor)
                                            .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            selectedOrgan = ""
                                        }) {
                                            Text("Clear")
                                                .font(.subheadline)
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding(.top, 8)
                                }
                            }
                        }
                    
                        // Symptoms input
                        ConsultationCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Symptoms")
                                    .font(.headline)
                                    .foregroundColor(primaryColor)
                                
                                TextField("Put comma between two symptoms"
                                          , text: $organSymptoms)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color(UIColor.secondarySystemBackground))
                                    )
                                
                                // Notes input
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notes")
                                        .font(.headline)
                                        .foregroundColor(primaryColor)
                                    
                                    TextEditor(text: $organNotes)
                                        .frame(minHeight: 100)
                                        .padding(4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color(UIColor.secondarySystemBackground))
                                        )
                                }
                            }
                        }
                        
                        // Add button
                        Button(action: {
                            let symptoms = organSymptoms
                                .split(separator: ",")
                                .map { String($0.trimmingCharacters(in: .whitespaces)) }
                                .filter { !$0.isEmpty }
                            
                            viewModel.addDiagnosisItem(
                                organ: selectedOrgan,
                                symptoms: symptoms,
                                notes: organNotes
                            )
                            
                            // Reset fields
                            selectedOrgan = ""
                            organSymptoms = ""
                            organNotes = ""
                            
                            showingOrganSheet = false
                        }) {
                            Text("Add Diagnosis")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedOrgan.isEmpty ? Color.gray : primaryColor)
                                        .shadow(color: selectedOrgan.isEmpty ? Color.gray.opacity(0.2) : primaryColor.opacity(0.3), radius: 4, y: 2)
                                )
                                .foregroundColor(.white)
                        }
                        .disabled(selectedOrgan.isEmpty)
                        .padding(16)
                    }
                    .navigationTitle("Add Diagnosis")
                    .navigationBarItems(trailing: Button("Cancel") {
                        showingOrganSheet = false
                    })
                    .background(colorScheme == .dark ? Color(hex: "101420") : Color(hex: "F7FAFF"))
                }
            }
        }
    }
    
    // MARK: - Prescription Form
    private var prescriptionFormView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Existing prescriptions
                ConsultationCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Medications")
                            .font(.headline)
                            .foregroundColor(primaryColor)
                        
                        if viewModel.prescriptionMedicines.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "pills.circle")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("No medications added")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 24)
                                Spacer()
                            }
                        } else {
                            ForEach(viewModel.prescriptionMedicines) { medicine in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(medicine.name)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 10) {
                                            Button(action: {
                                                if let index = viewModel.prescriptionMedicines.firstIndex(where: { $0.id == medicine.id }) {
                                                    viewModel.startEditingMedicine(at: index)
                                                }
                                            }) {
                                                Image(systemName: "pencil")
                                                    .foregroundColor(primaryColor)
                                                    .padding(6)
                                                    .background(Circle().fill(primaryColor.opacity(0.1)))
                                            }
                                            
                                            Button(action: {
                                                if let index = viewModel.prescriptionMedicines.firstIndex(where: { $0.id == medicine.id }) {
                                                    viewModel.deleteMedicine(at: index)
                                                }
                                            }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                                    .padding(6)
                                                    .background(Circle().fill(Color.red.opacity(0.1)))
                                            }
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    // Dosage info with icons
                                    HStack(spacing: 15) {
                                        dosageLabel(value: medicine.dosage.morning, time: "Morning", icon: "sunrise.fill", color: accentColor)
                                        dosageLabel(value: medicine.dosage.afternoon, time: "Noon", icon: "sun.max.fill", color: accentColor)
                                        dosageLabel(value: medicine.dosage.evening, time: "Night", icon: "moon.fill", color: accentColor)
                                    }
                                    
                                    if medicine.fastingRequired {
                                        HStack(spacing: 6) {
//                                            Image(systemName: "exclamationmark.triangle.fill")
//                                                .foregroundColor(Color(hex: "F5A623"))
                                            Text("Take on empty stomach")
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                        }
                                        .padding(.top, 4)
                                    }
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.tertiarySystemBackground))
                                )
                                
                                if medicine.id != viewModel.prescriptionMedicines.last?.id {
                                    Spacer().frame(height: 8)
                                }
                            }
                        }
                    }
                }
                
                // Medicine entry form
                ConsultationCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(viewModel.isEditingMedicine ? "Edit Medicine" : "Add New Medicine")
                            .font(.headline)
                            .foregroundColor(primaryColor)
                        
                        // Medicine name with autocomplete
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Medicine Name")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Start typing...", text: $viewModel.newMedicine.name)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color(UIColor.secondarySystemBackground))
                                )
                                .onChange(of: viewModel.newMedicine.name) { newValue in
                                    viewModel.searchMedicines(query: newValue)
                                }
                        }
                        
                        if !viewModel.medicineSuggestions.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(viewModel.medicineSuggestions) { medicine in
                                        Button(action: {
                                            viewModel.newMedicine.name = medicine.medicineName
                                            viewModel.newMedicine.medicineId = String(medicine.medicineId)
                                            viewModel.medicineSuggestions = []
                                        }) {
                                            HStack {
                                                Text(medicine.medicineName)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                            }
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)
                                        }
                                        
                                        if medicine.id != viewModel.medicineSuggestions.last?.id {
                                            Divider()
                                        }
                                    }
                                }
                            }
                            .frame(height: min(CGFloat(viewModel.medicineSuggestions.count * 44), 180))
                            .background(colorScheme == .dark ? darkCardColor : cardColor)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                        }
                        
                        // Dosage with custom controls
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dosage")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 10) {
                                dosagePicker(label: "Morning", value: $viewModel.newMedicine.dosage.morning)
                                dosagePicker(label: "Afternoon", value: $viewModel.newMedicine.dosage.afternoon)
                                dosagePicker(label: "Evening", value: $viewModel.newMedicine.dosage.evening)
                            }
                        }
                        
                        // Fasting toggle
                        Toggle(isOn: $viewModel.newMedicine.fastingRequired) {
                            HStack {
//                                Image(systemName: "exclamationmark.triangle.fill")
//                                    .foregroundColor(accentColor)
                                Text("Fasting Required")
                                    .foregroundColor(.primary)
                            }
                        }
                        .tint(primaryColor)
                        .padding(.vertical, 4)
                        
                        // Add/Update button
                        Button(action: {
                            viewModel.addMedicine()
                        }) {
                            Text(viewModel.isEditingMedicine ? "Update Medicine" : "Add Medicine")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(viewModel.newMedicine.name.isEmpty ? Color.gray : primaryColor)
                                        .shadow(color: viewModel.newMedicine.name.isEmpty ? Color.gray.opacity(0.2) : primaryColor.opacity(0.3), radius: 4, y: 2)
                                )
                                .foregroundColor(.white)
                        }
                        .disabled(viewModel.newMedicine.name.isEmpty || viewModel.newMedicine.medicineId.isEmpty)
                    }
                }
                
                // Doctor's Notes
                ConsultationCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Doctor's Notes")
                            .font(.headline)
                            .foregroundColor(primaryColor)
                        
                        TextEditor(text: $viewModel.doctorNotes)
                            .frame(minHeight: 120)
                            .padding(4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color(UIColor.secondarySystemBackground))
                            )
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Lab Tests Form
private var labTestsFormView: some View {
    ScrollView {
        VStack(spacing: 16) {
            // Simple search bar for lab tests
            ConsultationCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Search Lab Tests")
                        .font(.headline)
                        .foregroundColor(primaryColor)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search by test name", text: $labTestSearchText)
                            .autocapitalization(.none)
                        
                        if !labTestSearchText.isEmpty {
                            Button(action: {
                                labTestSearchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color(UIColor.secondarySystemBackground))
                    )
                }
            }
            
            // Selected tests
            ConsultationCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Lab Tests")
                            .font(.headline)
                            .foregroundColor(primaryColor)
                        
                        Spacer()
                        
                        Text("\(viewModel.selectedLabTests.count) selected")
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(primaryColor.opacity(0.15))
                            )
                            .foregroundColor(primaryColor)
                    }
                    
                    // New scrollable tests container
                    VStack(spacing: 0) {
                        // Filter tests based on search text
                        let filteredTests = viewModel.labTestTypes.filter {
                            labTestSearchText.isEmpty ? true :
                            $0.testName.localizedCaseInsensitiveContains(labTestSearchText)
                        }
                        
                        // Scrollable list for all tests
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(filteredTests, id: \.id) { testType in
                                    Button(action: {
                                        let testId = testType.testTypeId
                                        if viewModel.selectedLabTests.contains(testId) {
                                            viewModel.selectedLabTests.removeAll { $0 == testId }
                                        } else {
                                            viewModel.selectedLabTests.append(testId)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: viewModel.selectedLabTests.contains(testType.testTypeId) ? "checkmark.square.fill" : "square")
                                                .foregroundColor(viewModel.selectedLabTests.contains(testType.testTypeId) ? primaryColor : .gray)
                                                .font(.system(size: 20))
                                            
                                            Text(testType.testName)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                        }
                                        .contentShape(Rectangle())
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 8)
                                    }
                                    
                                    if testType.id != filteredTests.last?.id {
                                        Divider().padding(.leading, 36)
                                    }
                                }
                            }
                        }
                        // Fixed height to show approximately 5 items
                        .frame(height: 270)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.tertiarySystemBackground))
                    )
                }
            }
            
            // Improved Lab test details
            ConsultationCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Lab Test Details")
                        .font(.headline)
                        .foregroundColor(primaryColor)
                    
                    // Priority selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Priority")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            priorityButton(title: "Low", value: "low", selectedValue: viewModel.labPriority)
                            priorityButton(title: "Medium", value: "medium", selectedValue: viewModel.labPriority)
                            priorityButton(title: "High", value: "high", selectedValue: viewModel.labPriority)
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Date & Time")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(primaryColor)
                                
                                // Restrict past dates
                                DatePicker(
                                    "Test Date",
                                    selection: $viewModel.labTestDateTime,
                                    in: Date()..., // Restrict past dates
                                    displayedComponents: .date
                                )
                                .labelsHidden()
                                .datePickerStyle(.compact)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color(UIColor.secondarySystemBackground))
                            )
                            
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(primaryColor)
                                
                                DatePicker(
                                    "Test Time",
                                    selection: $viewModel.labTestDateTime,
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                                .datePickerStyle(.compact)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color(UIColor.secondarySystemBackground))
                            )
                        }
                    }
                }
            }
        }
        .padding(16)
    }
}
    // MARK: - Helper Views
    
 
   struct ConsultationCard<Content: View>: View {
        @Environment(\.colorScheme) var colorScheme
        let content: Content
        
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        
        var body: some View {
            content
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color(hex: "1A2234") : Color.white.opacity(0.8))
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 8, y: 2)
                )
        }
    }
    
    // Dosage label with icon
    func dosageLabel(value: Int, time: String, icon: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("\(value)")
                    .font(.subheadline)
                    .fontWeight(value > 0 ? .medium : .regular)
                    .foregroundColor(value > 0 ? .primary : .secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Dosage picker for adding/editing medicines
    private func dosagePicker(label: String, value: Binding<Int>) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Stepper controls
            HStack(spacing: 0) {
                // Minus button
                Button(action: {
                    if value.wrappedValue > 0 {
                        value.wrappedValue -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(value.wrappedValue > 0 ? primaryColor : Color.gray)
                        .cornerRadius(6)
                }
                
                // Value display
                Text("\(value.wrappedValue)")
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 36, height: 28)
                    .background(colorScheme == .dark ? Color(UIColor.tertiarySystemBackground).opacity(0.5) : Color(UIColor.secondarySystemBackground).opacity(0.5))
                
                // Plus button
                Button(action: {
                    if value.wrappedValue < 5 {
                        value.wrappedValue += 1
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(value.wrappedValue < 5 ? primaryColor : Color.gray)
                        .cornerRadius(6)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color(UIColor.secondarySystemBackground))
        )
    }
    
    // Priority button for lab tests
    private func priorityButton(title: String, value: String, selectedValue: String) -> some View {
        Button(action: {
            viewModel.labPriority = value
        }) {
            Text(title)
                .font(.subheadline)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedValue == value ?
                              (value == "high" ? Color.red.opacity(0.2) :
                                value == "medium" ? primaryColor.opacity(0.2) :
                                secondaryColor.opacity(0.2)) :
                                (colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color(UIColor.secondarySystemBackground)))
                )
                .foregroundColor(selectedValue == value ?
                                 (value == "high" ? Color.red :
                                    value == "normal" ? primaryColor :
                                    secondaryColor) : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedValue == value ?
                                (value == "high" ? Color.red :
                                    value == "normal" ? primaryColor :
                                    secondaryColor) : Color.clear, lineWidth: 1)
                )
        }
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                colorScheme == .dark ? Color(hex: "101420") : Color(hex: "F7FAFF"),
                colorScheme == .dark ? Color(hex: "1A202C") : Color(hex: "ECF3FF")
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Preview Provider
struct DoctorConsultationView_Previews: PreviewProvider {
    static var previews: some View {
        // Pass a sample appointment ID for previews
        DoctorConsultationView(appointmentId: 1)
    }
}
