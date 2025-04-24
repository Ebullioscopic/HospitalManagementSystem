//
//  labTechnicianCRUD.swift
//  Hospitality
//
//  Created by admin@33 on 23/04/25.
//

import SwiftUI

struct LabTechniciansListView: View {
    @State private var technicians: [LabTechnician] = [
        LabTechnician(name: "Emily Rodriguez", email: "e.rodriguez@hospital.com", phone: "+1 (555) 234-5678", qualification: "MLT, ASCP", experience: "5", certifications: "ASCP Certified, Phlebotomy Certified", shift: "Morning", specialty: "Blood Work"),
        LabTechnician(name: "David Kim", email: "d.kim@hospital.com", phone: "+1 (555) 345-6789", qualification: "BS in Medical Technology", experience: "3", certifications: "Molecular Biology Specialist", shift: "Afternoon", specialty: "Molecular Diagnostics")
    ]
    
    @State private var showingAddTechnician = false
    @State private var searchText = ""
    @State private var selectedSpecialty = "All"
    @State private var selectedShift = "All"
    @State private var editMode: EditMode = .inactive
    @State private var selectedTechnicians = Set<UUID>()
    @State private var showingDeleteConfirmation = false
    
    private var specialties: [String] {
        var specs = ["All"]
        specs.append(contentsOf: Set(technicians.map { $0.specialty }).sorted())
        return specs
    }
    
    private var shifts: [String] {
        var shiftList = ["All"]
        shiftList.append(contentsOf: Set(technicians.map { $0.shift }).sorted())
        return shiftList
    }
    
    private var filteredTechnicians: [LabTechnician] {
        var result = technicians
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.specialty.localizedCaseInsensitiveContains(searchText) ||
                $0.qualification.localizedCaseInsensitiveContains(searchText) ||
                $0.certifications.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply specialty filter
        if selectedSpecialty != "All" {
            result = result.filter { $0.specialty == selectedSpecialty }
        }
        
        // Apply shift filter
        if selectedShift != "All" {
            result = result.filter { $0.shift == selectedShift }
        }
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            SearchBar(text: $searchText)
                .padding(.horizontal)
                .padding(.top, 8)
                .background(Color(.systemGroupedBackground))
            
            // Filter Section - Now more prominent
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
                        title: "Specialty",
                        selection: $selectedSpecialty,
                        options: specialties,
                        accentColor: .green
                    )
                    
                    FilterPill(
                        title: "Shift",
                        selection: $selectedShift,
                        options: shifts,
                        accentColor: .blue
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
            
            // Technicians List
            List(selection: $selectedTechnicians) {
                ForEach(filteredTechnicians) { technician in
                    NavigationLink(destination: LabTechnicianDetailView(technician: binding(for: technician))) {
                        LabTechnicianRow(technician: technician)
                    }
                    .tag(technician.id)
                }
                .onDelete(perform: deleteTechnician)
            }
            .listStyle(InsetListStyle())
        }
        .navigationTitle("Lab Technicians")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if editMode == .active {
                    Button(action: {
                        if !selectedTechnicians.isEmpty {
                            showingDeleteConfirmation = true
                        }
                    }) {
                        Image(systemName: "trash")
                    }
                    .disabled(selectedTechnicians.isEmpty)
                }
                
                Button(action: { showingAddTechnician = true }) {
                    Image(systemName: "plus")
                }
                
                EditButton()
            }
        }
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $showingAddTechnician) {
            AddEditLabTechnicianView(technician: .constant(nil), onSave: { newTechnician in
                technicians.append(newTechnician)
                showingAddTechnician = false
            })
        }
        .actionSheet(isPresented: $showingDeleteConfirmation) {
            ActionSheet(
                title: Text("Delete Technicians"),
                message: Text("Are you sure you want to delete \(selectedTechnicians.count) technician(s)?"),
                buttons: [
                    .destructive(Text("Delete"), action: deleteSelectedTechnicians),
                    .cancel()
                ]
            )
        }
    }
    
    private func binding(for technician: LabTechnician) -> Binding<LabTechnician> {
        guard let index = technicians.firstIndex(where: { $0.id == technician.id }) else {
            fatalError("Technician not found")
        }
        return $technicians[index]
    }
    
    private func deleteTechnician(at offsets: IndexSet) {
        technicians.remove(atOffsets: offsets)
    }
    
    private func deleteSelectedTechnicians() {
        technicians.removeAll { technician in
            selectedTechnicians.contains(technician.id)
        }
        selectedTechnicians.removeAll()
        editMode = .inactive
    }
}

struct FilterPill<Selection: Hashable>: View {
    let title: String
    @Binding var selection: Selection
    let options: [Selection]
    let accentColor: Color
    
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(action: { selection = option }) {
                    HStack {
                        Text(String(describing: option))
                        if selection == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selection as! String == "All" ? title : String(describing: selection))
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(selection as! String == "All" ? .gray : .white)
                
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundColor(selection as! String == "All" ? .gray : .white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(selection as! String == "All" ? Color(.systemGray5) : accentColor)
            )
            .animation(.easeOut, value: selection)
        }
    }
}

struct LabTechnicianRow: View {
    let technician: LabTechnician
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(technician.name)
                    .font(.headline)
                
                Text(technician.specialty)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(technician.shift)
                    .font(.subheadline)
                    .foregroundColor(.green)
                
                Text("\(technician.experience) yrs")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct LabTechnicianDetailView: View {
    @Binding var technician: LabTechnician
    @State private var isEditing = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)
                        .padding(.bottom, 8)
                    Spacer()
                }
                
                HStack {
                    Text("Name")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(technician.name)
                }
                
                HStack {
                    Text("Specialty")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(technician.specialty)
                }
                
                HStack {
                    Text("Qualification")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(technician.qualification)
                }
                
                HStack {
                    Text("Experience")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(technician.experience) years")
                }
                
                HStack {
                    Text("Shift")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(technician.shift)
                }
            }
            
            Section(header: Text("Contact")) {
                HStack {
                    Text("Email")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(technician.email)
                }
                
                HStack {
                    Text("Phone")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(technician.phone)
                }
            }
            
            Section(header: Text("Certifications")) {
                Text(technician.certifications)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(technician.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditing = true }) {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            AddEditLabTechnicianView(technician: .constant(technician), onSave: { updatedTechnician in
                technician = updatedTechnician
                isEditing = false
            })
        }
    }
}

struct AddEditLabTechnicianView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var technician: LabTechnician?
    var onSave: (LabTechnician) -> Void
    
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var qualification: String
    @State private var experience: String
    @State private var certifications: String
    @State private var shift: String
    @State private var specialty: String
    
    private var shifts = ["Morning", "Afternoon", "Evening", "Night", "Rotating"]
    private var specialties = ["Blood Work", "Imaging", "Pathology", "Microbiology", "Biochemistry", "Molecular Diagnostics", "Cytology"]
    
    init(technician: Binding<LabTechnician?>, onSave: @escaping (LabTechnician) -> Void) {
        self._technician = technician
        self.onSave = onSave
        
        if let technician = technician.wrappedValue {
            _name = State(initialValue: technician.name)
            _email = State(initialValue: technician.email)
            _phone = State(initialValue: technician.phone)
            _qualification = State(initialValue: technician.qualification)
            _experience = State(initialValue: technician.experience)
            _certifications = State(initialValue: technician.certifications)
            _shift = State(initialValue: technician.shift)
            _specialty = State(initialValue: technician.specialty)
        } else {
            _name = State(initialValue: "")
            _email = State(initialValue: "")
            _phone = State(initialValue: "")
            _qualification = State(initialValue: "")
            _experience = State(initialValue: "")
            _certifications = State(initialValue: "")
            _shift = State(initialValue: shifts[0])
            _specialty = State(initialValue: specialties[0])
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
                    Picker("Specialty", selection: $specialty) {
                        ForEach(specialties, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    TextField("Qualification", text: $qualification)
                    TextField("Experience (Years)", text: $experience)
                        .keyboardType(.numberPad)
                    
                    Picker("Shift", selection: $shift) {
                        ForEach(shifts, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                Section(header: Text("Certifications")) {
                    TextEditor(text: $certifications)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle(technician == nil ? "Add Technician" : "Edit Technician")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newTechnician = LabTechnician(
                            name: name,
                            email: email,
                            phone: phone,
                            qualification: qualification,
                            experience: experience,
                            certifications: certifications,
                            shift: shift,
                            specialty: specialty
                        )
                        onSave(newTechnician)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || email.isEmpty || specialty.isEmpty)
                }
            }
        }
    }
}
