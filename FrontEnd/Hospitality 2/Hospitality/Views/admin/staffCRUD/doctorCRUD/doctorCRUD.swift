//
//  doctorCRUD.swift
//  Hospitality
//
//  Created by admin@33 on 23/04/25.
//

import Foundation
import SwiftUI

struct DoctorsListView: View {
    @ObservedObject private var dataStore = MockHospitalDataStore()
    @State private var showingAddDoctor = false
    @State private var searchText = ""
    @State private var selectedDepartment = "All"
    @State private var selectedShift = "All"
    @State private var editMode: EditMode = .inactive
    @State private var selectedDoctors = Set<String>()
    @State private var showingDeleteConfirmation = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var departments: [String] {
        var depts = ["All"]
        let allDepts = Set(dataStore.doctors.map { $0.doctorSpecialization })
        depts.append(contentsOf: allDepts.sorted())
        return depts
    }
    
    private var shifts: [String] {
        ["All", "Morning", "Afternoon", "Evening", "Night"]
    }
    
    private var filteredDoctors: [Staff] {
        var result = dataStore.staff.filter { staff in
            dataStore.doctors.contains { $0.staffId == staff.id }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.staffName.localizedCaseInsensitiveContains(searchText) ||
                $0.staffEmail.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if selectedDepartment != "All" {
            result = result.filter { staff in
                dataStore.doctors.contains {
                    $0.staffId == staff.id && $0.doctorSpecialization == selectedDepartment
                }
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack {
            // Search and Filter Bar
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .background(Color(.systemGroupedBackground))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(spacing: 12) {
                        HStack {
                            Text("FILTERS")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.leading, 16)
                            Spacer()
                        }
                        
                        HStack(spacing: 16) {
                            FilterPill(
                                title: "Department",
                                selection: $selectedDepartment,
                                options: departments,
                                accentColor: .main
                            )
                            
                            FilterPill(
                                title: "Shift",
                                selection: $selectedShift,
                                options: shifts,
                                accentColor: .main
                            )
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(.vertical, 8)
                }
            }
            .background(Color(.systemGroupedBackground))
            
            // Doctors List
            List(selection: $selectedDoctors) {
                ForEach(filteredDoctors) { staff in
                    NavigationLink(destination: DoctorDetailView(staff: staff, dataStore: dataStore)) {
                        DoctorRow(staff: staff, dataStore: dataStore)
                    }
                    .tag(staff.id)
                }
                .onDelete(perform: deleteDoctor)
            }
        }
        .navigationTitle("Doctors")
        .onAppear {
            fetchDoctors()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if editMode == .active {
                    Button(action: {
                        if !selectedDoctors.isEmpty {
                            showingDeleteConfirmation = true
                        }
                    }) {
                        Image(systemName: "trash")
                            .tint(.red)
                    }
                    .disabled(selectedDoctors.isEmpty)
                }
                
                Button(action: { showingAddDoctor = true }) {
                    Image(systemName: "plus")
                        .tint(.main)
                }
                
                EditButton()
            }
        }
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $showingAddDoctor) {
            AddEditDoctorView(dataStore: dataStore) { staff, doctorDetails, staffDetails in
                dataStore.createDoctor(staff: staff, doctorDetails: doctorDetails, staffDetails: staffDetails)
                showingAddDoctor = false
            }
        }
        .actionSheet(isPresented: $showingDeleteConfirmation) {
            ActionSheet(
                title: Text("Delete Doctors"),
                message: Text("Are you sure you want to delete \(selectedDoctors.count) doctor(s)?"),
                buttons: [
                    .destructive(Text("Delete"), action: { deleteSelectedDoctors() }),
                    .cancel()
                ]
            )
        }
        .onAppear {
            dataStore.fetchStaff()
            dataStore.fetchDoctors()
            dataStore.fetchDoctorTypes()
        }
    }
    
    private func fetchDoctors() {
        isLoading = true
        errorMessage = nil
        
        DoctorService.shared.fetchDoctors { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let doctors):
                    // Convert API response to your local data models
                    let staffList = doctors.map { doctor in
                        Staff(
                            id: doctor.staff_id,
                            staffName: doctor.staff_name,
                            roleId: "doctor_role_id",
                            createdAt: Date(), // You might need to get this from the API
                            staffEmail: doctor.staff_email,
                            staffMobile: doctor.staff_mobile,
                            onLeave: doctor.on_leave
                        )
                    }
                    
                    let doctorDetailsList = doctors.map { doctor in
                        DoctorDetails(
                            id: UUID().uuidString,
                            staffId: doctor.staff_id,
                            doctorSpecialization: doctor.specialization,
                            doctorLicense: doctor.license,
                            doctorExperienceYears: doctor.experience_years,
                            doctorTypeId: "" // You might need to get this from the API
                        )
                    }
                    
                    // Update your data store
                    dataStore.staff = staffList
                    dataStore.doctors = doctorDetailsList
                    
                case .failure(let error):
                    errorMessage = "Failed to load doctors: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func deleteDoctor(at offsets: IndexSet) {
        let idsToDelete = offsets.map { filteredDoctors[$0].id }
        dataStore.deleteStaff(ids: idsToDelete)
    }
    
    private func deleteSelectedDoctors() {
        dataStore.deleteStaff(ids: Array(selectedDoctors))
        selectedDoctors.removeAll()
        editMode = .inactive
    }
}

struct DoctorRow: View {
    let staff: Staff
    @ObservedObject var dataStore: MockHospitalDataStore
    
    var doctorDetails: DoctorDetails? {
        dataStore.doctors.first { $0.staffId == staff.id }
    }
    
    var doctorType: DoctorType? {
        guard let doctor = doctorDetails else { return nil }
        return dataStore.doctorTypes.first { $0.id == doctor.doctorTypeId }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.main)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(staff.staffName)
                    .font(.headline)
                
                if let specialization = doctorDetails?.doctorSpecialization {
                    Text(specialization)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let type = doctorType {
                    Text(type.doctorTypeName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if staff.onLeave {
                Text("On Leave")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
}

struct AddEditDoctorView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var dataStore: MockHospitalDataStore
    
    var onSave: (Staff, DoctorDetails, StaffDetails) -> Void
    
    // Staff fields
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var mobile: String = ""
    @State private var onLeave: Bool = false
    @State private var joiningDate: Date = Date()
    
    // Doctor fields
    @State private var specialization: String = ""
    @State private var license: String = ""
    @State private var experience: String = ""
    @State private var doctorTypeId: String = ""
    
    // StaffDetails fields
    @State private var dob: Date = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    @State private var address: String = ""
    @State private var qualifications: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Mobile", text: $mobile)
                        .keyboardType(.phonePad)
                    DatePicker("Date of Birth", selection: $dob, displayedComponents: .date)
                }
                
                Section(header: Text("Address")) {
                    TextField("Address", text: $address)
                }
                
                Section(header: Text("Professional Information")) {
                    TextField("Specialization", text: $specialization)
                    TextField("Qualifications", text: $qualifications)
                    TextField("License Number", text: $license)
                    TextField("Experience (Years)", text: $experience)
                        .keyboardType(.numberPad)
                    
                    Picker("Doctor Type", selection: $doctorTypeId) {
                        ForEach(dataStore.doctorTypes) { type in
                            Text(type.doctorTypeName).tag(String(type.id))
                        }
                    }
                    
                    DatePicker("Joining Date", selection: $joiningDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Doctor")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveDoctor()
                    }
                    .disabled(name.isEmpty || email.isEmpty || mobile.isEmpty ||
                             specialization.isEmpty || qualifications.isEmpty ||
                             license.isEmpty || experience.isEmpty ||
                             doctorTypeId.isEmpty || address.isEmpty)
                }
            }
        }
    }
    
    private func saveDoctor() {
        // Validate inputs
        guard !name.isEmpty,
              !email.isEmpty,
              !mobile.isEmpty,
              !specialization.isEmpty,
              !license.isEmpty,
              !experience.isEmpty,
              !doctorTypeId.isEmpty,
              !qualifications.isEmpty,
              !address.isEmpty else {
            // Show error to user
            return
        }
        
        // Convert experience to Int
        guard let experienceYears = Int(experience) else {
            // Show error to user
            return
        }
        
        // Convert doctorTypeId to Int
        guard let doctorTypeID = Int(doctorTypeId) else {
            // Show error to user
            return
        }
        
        // Format dates
//        let joiningDateString = CreateDoctorRequest.formattedDate(from: joiningDate)
        let dobString = CreateDoctorRequest.formattedDate(from: dob)
        
        // Call the service
        DoctorService.shared.createDoctor(
            name: name,
            email: email,
            mobile: mobile,
            specialization: specialization,
            license: license,
            experienceYears: experienceYears,
            doctorTypeId: doctorTypeID,
            joiningDate: joiningDate,
            dob: dobString,
            address: address,
            qualifications: qualifications
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Doctor created successfully with ID: \(response.staff_id)")
                    
                    // Create local objects
                    let staff = Staff(
                        id: response.staff_id,
                        staffName: self.name,
                        roleId: "doctor_role_id",
                        createdAt: self.joiningDate,
                        staffEmail: self.email,
                        staffMobile: self.mobile,
                        onLeave: self.onLeave
                    )
                    
                    let doctorDetails = DoctorDetails(
                        id: UUID().uuidString,
                        staffId: response.staff_id,
                        doctorSpecialization: self.specialization,
                        doctorLicense: self.license,
                        doctorExperienceYears: experienceYears,
                        doctorTypeId: self.doctorTypeId
                    )
                    
                    let staffDetails = StaffDetails(
                        id: UUID().uuidString,
                        staffId: response.staff_id,
                        staffDob: self.dob,
                        staffAddress: self.address,
                        staffQualifications: self.qualifications,
                        staffPhoto: nil
                    )
                    
                    // Save to local data store
                    self.dataStore.createDoctor(
                        staff: staff,
                        doctorDetails: doctorDetails,
                        staffDetails: staffDetails
                    )
                    
                    // Call the completion handler
                    self.onSave(staff, doctorDetails, staffDetails)
                    
                    // Dismiss the view
                    self.presentationMode.wrappedValue.dismiss()
                    
                case .failure(let error):
                    print("Failed to create doctor: \(error)")
                    // Handle error - show error message to user
                }
            }
        }
    }
}

struct DoctorDetailView: View {
    let staff: Staff
    @ObservedObject var dataStore: MockHospitalDataStore
    
    var doctorDetails: DoctorDetails? {
        dataStore.doctors.first { $0.staffId == staff.id }
    }
    
    var doctorType: DoctorType? {
        guard let doctor = doctorDetails else { return nil }
        return dataStore.doctorTypes.first { $0.id == doctor.doctorTypeId }
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.main)
                    Spacer()
                }
                
                HStack {
                    Text("Name")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(staff.staffName)
                }
                
                if let specialization = doctorDetails?.doctorSpecialization {
                    HStack {
                        Text("Specialization")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(specialization)
                    }
                }
                
                if let experience = doctorDetails?.doctorExperienceYears {
                    HStack {
                        Text("Experience")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(experience) years")
                    }
                }
                
                if let type = doctorType {
                    HStack {
                        Text("Type")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(type.doctorTypeName)
                    }
                }
                
                if let license = doctorDetails?.doctorLicense {
                    HStack {
                        Text("License")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(license)
                    }
                }
            }
            
            Section(header: Text("Contact")) {
                HStack {
                    Text("Email")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(staff.staffEmail)
                }
                
                HStack {
                    Text("Mobile")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(staff.staffMobile)
                }
            }
            
            if staff.onLeave {
                Section {
                    Text("Currently on leave")
                        .foregroundColor(.orange)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(staff.staffName)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search...", text: $text)
                    .foregroundColor(.primary)
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}
