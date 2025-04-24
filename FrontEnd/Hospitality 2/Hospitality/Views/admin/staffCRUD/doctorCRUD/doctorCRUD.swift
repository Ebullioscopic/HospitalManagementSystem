//
//  doctorCRUD.swift
//  Hospitality
//
//  Created by admin@33 on 23/04/25.
//

import Foundation
import SwiftUI

struct DoctorsListView: View {
    @State private var doctors: [RegistrationDoctors] = [
        RegistrationDoctors(name: "Dr. Sarah Johnson", email: "s.johnson@hospital.com", phone: "+1 (555) 123-4567",
                department: "Cardiology", specialization: "Interventional Cardiology", qualification: "MD, PhD",
                experience: "12", availability: "Mon-Fri: 9AM-5PM", bio: "Cardiologist with extensive experience in interventional procedures.",
                fees: "$250", shifts: ["Morning", "Afternoon"]),
        
        RegistrationDoctors(name: "Dr. Michael Chen", email: "m.chen@hospital.com", phone: "+1 (555) 987-6543",
                department: "Neurology", specialization: "Neurodegenerative Disorders", qualification: "MD",
                experience: "8", availability: "Mon-Wed-Fri: 10AM-4PM", bio: "Specializes in neurodegenerative disorders.",
                fees: "$200", shifts: ["Afternoon"]),
        
        RegistrationDoctors(name: "Dr. Emily Rodriguez", email: "e.rodriguez@hospital.com", phone: "+1 (555) 456-7890",
                department: "Pediatrics", specialization: "Neonatology", qualification: "MD",
                experience: "5", availability: "Tue-Thu-Sat: 8AM-2PM", bio: "Specializes in newborn care and neonatal intensive care.",
                fees: "$180", shifts: ["Morning"])
    ]
    
    @State private var showingAddDoctor = false
    @State private var searchText = ""
    @State private var selectedDepartment = "All"
    @State private var selectedShift = "All"
    @State private var editMode: EditMode = .inactive
    @State private var selectedDoctors = Set<UUID>()
    @State private var showingDeleteConfirmation = false
    
    private var departments: [String] {
        var depts = ["All"]
        depts.append(contentsOf: Set(doctors.map { $0.department }).sorted())
        return depts
    }
    
    private var shifts: [String] {
        ["All", "Morning", "Afternoon", "Evening", "Night"]
    }
    
    private var filteredDoctors: [RegistrationDoctors] {
        var result = doctors
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.department.localizedCaseInsensitiveContains(searchText) ||
                $0.specialization.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply department filter
        if selectedDepartment != "All" {
            result = result.filter { $0.department == selectedDepartment }
        }
        
        // Apply shift filter
        if selectedShift != "All" {
            result = result.filter { $0.shifts.contains(selectedShift) }
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
                    .background(Color(.systemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
            .background(Color(.systemGroupedBackground))
            
            // Doctors List
            List(selection: $selectedDoctors) {
                ForEach(filteredDoctors) { doctor in
                    NavigationLink(destination: DoctorDetailView(doctor: binding(for: doctor))) {
                        DoctorRow(doctor: doctor)
                    }
                    .tag(doctor.id)
                }
                .onDelete(perform: deleteDoctor)
            }
            .listStyle(InsetListStyle())
        }
        .navigationTitle("Doctors")
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
            AddEditDoctorView(doctor: .constant(nil), onSave: { newDoctor in
                doctors.append(newDoctor)
                showingAddDoctor = false
            })
        }
        .actionSheet(isPresented: $showingDeleteConfirmation) {
            ActionSheet(
                title: Text("Delete Doctors"),
                message: Text("Are you sure you want to delete \(selectedDoctors.count) doctor(s)?"),
                buttons: [
                    .destructive(Text("Delete"), action: deleteSelectedDoctors),
                    .cancel()
                ]
            )
        }
    }
    
    private func binding(for doctor: RegistrationDoctors) -> Binding<RegistrationDoctors> {
        guard let index = doctors.firstIndex(where: { $0.id == doctor.id }) else {
            fatalError("Doctor not found")
        }
        return $doctors[index]
    }
    
    private func deleteDoctor(at offsets: IndexSet) {
        doctors.remove(atOffsets: offsets)
    }
    
    private func deleteSelectedDoctors() {
        doctors.removeAll { doctor in
            selectedDoctors.contains(doctor.id)
        }
        selectedDoctors.removeAll()
        editMode = .inactive
    }
}

struct DoctorRow: View {
    let doctor: RegistrationDoctors
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(colorForDepartment(doctor.department))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(doctor.name)
                    .font(.headline)
                
                Text("\(doctor.department) - \(doctor.specialization)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    ForEach(doctor.shifts, id: \.self) { shift in
                        Text(shift)
                            .font(.caption2)
                            .padding(4)
                            .background(shiftColor(shift))
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            Text(doctor.fees)
                .font(.subheadline)
                .foregroundColor(.main)
        }
        .padding(.vertical, 8)
    }
    
    private func colorForDepartment(_ department: String) -> Color {
        switch department {
        case "Cardiology": return .main
        case "Neurology": return .main
        case "Pediatrics": return .main
        default: return .gray
        }
    }
    
    private func shiftColor(_ shift: String) -> Color {
        switch shift {
        case "Morning": return Color.blue.opacity(0.2)
        case "Afternoon": return Color.orange.opacity(0.2)
        case "Evening": return Color.purple.opacity(0.2)
        case "Night": return Color.black.opacity(0.2)
        default: return Color.gray.opacity(0.2)
        }
    }
}

struct AddEditDoctorView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var doctor: RegistrationDoctors?
    var onSave: (RegistrationDoctors) -> Void
    
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var department: String
    @State private var specialization: String
    @State private var qualification: String
    @State private var experience: String
    @State private var availability: String
    @State private var bio: String
    @State private var fees: String
    @State private var selectedShifts: Set<String>
    
    private var departments = ["Cardiology", "Neurology", "Pediatrics", "Orthopedics", "Dermatology", "Oncology"]
    private var shifts = ["Morning", "Afternoon", "Evening", "Night"]
    
    init(doctor: Binding<RegistrationDoctors?>, onSave: @escaping (RegistrationDoctors) -> Void) {
        self._doctor = doctor
        self.onSave = onSave
        
        if let doctor = doctor.wrappedValue {
            _name = State(initialValue: doctor.name)
            _email = State(initialValue: doctor.email)
            _phone = State(initialValue: doctor.phone)
            _department = State(initialValue: doctor.department)
            _specialization = State(initialValue: doctor.specialization)
            _qualification = State(initialValue: doctor.qualification)
            _experience = State(initialValue: doctor.experience)
            _availability = State(initialValue: doctor.availability)
            _bio = State(initialValue: doctor.bio)
            _fees = State(initialValue: doctor.fees)
            _selectedShifts = State(initialValue: Set(doctor.shifts))
        } else {
            _name = State(initialValue: "")
            _email = State(initialValue: "")
            _phone = State(initialValue: "")
            _department = State(initialValue: departments[0])
            _specialization = State(initialValue: "")
            _qualification = State(initialValue: "")
            _experience = State(initialValue: "")
            _availability = State(initialValue: "")
            _bio = State(initialValue: "")
            _fees = State(initialValue: "")
            _selectedShifts = State(initialValue: [])
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Professional Information")) {
                    Picker("Department", selection: $department) {
                        ForEach(departments, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    TextField("Specialization", text: $specialization)
                    TextField("Qualification", text: $qualification)
                    TextField("Experience (Years)", text: $experience)
                        .keyboardType(.numberPad)
                    TextField("Consultation Fees", text: $fees)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Shifts")) {
                    ForEach(shifts, id: \.self) { shift in
                        MultipleSelectionRow(title: shift, isSelected: selectedShifts.contains(shift)) {
                            if selectedShifts.contains(shift) {
                                selectedShifts.remove(shift)
                            } else {
                                selectedShifts.insert(shift)
                            }
                        }
                    }
                }
                
                Section(header: Text("Availability")) {
                    TextEditor(text: $availability)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Bio")) {
                    TextEditor(text: $bio)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle(doctor == nil ? "Add Doctor" : "Edit Doctor")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newDoctor = RegistrationDoctors(
                            name: name,
                            email: email,
                            phone: phone,
                            department: department,
                            specialization: specialization,
                            qualification: qualification,
                            experience: experience,
                            availability: availability,
                            bio: bio,
                            fees: fees,
                            shifts: Array(selectedShifts)
                        )
                        onSave(newDoctor)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || email.isEmpty || department.isEmpty || selectedShifts.isEmpty)
                }
            }
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.main)
                }
            }
        }
        .foregroundColor(.primary)
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

struct DoctorDetailView: View {
    @Binding var doctor: RegistrationDoctors
    @State private var isEditing = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.main)
                        .padding(.bottom, 8)
                    Spacer()
                }
                
                HStack {
                    Text("Name")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(doctor.name)
                }
                
                HStack {
                    Text("Specialization")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(doctor.specialization)
                }
                
                HStack {
                    Text("Qualification")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(doctor.qualification)
                }
                
                HStack {
                    Text("Experience")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(doctor.experience) years")
                }
                
                HStack {
                    Text("Fees")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(doctor.fees)
                }
            }
            
            Section(header: Text("Contact")) {
                HStack {
                    Text("Email")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(doctor.email)
                }
                
                HStack {
                    Text("Phone")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(doctor.phone)
                }
            }
            
            Section(header: Text("Availability")) {
                Text(doctor.availability)
            }
            
            Section(header: Text("Bio")) {
                Text(doctor.bio)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(doctor.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditing = true }) {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            AddEditDoctorView(doctor: .constant(doctor), onSave: { updatedDoctor in
                doctor = updatedDoctor
                isEditing = false
            })
        }
    }
}
