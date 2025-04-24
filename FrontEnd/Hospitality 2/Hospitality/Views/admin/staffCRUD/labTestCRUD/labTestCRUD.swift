//
//  labTestCRUD.swift
//  Hospitality
//
//  Created by admin@33 on 23/04/25.
//

import SwiftUI

struct LabTestsListView: View {
    @State private var tests: [LabTest] = [
        LabTest(name: "Complete Blood Count (CBC)", description: "Measures various components of the blood", price: "$45", duration: "15 minutes", instructions: "No special preparation required"),
        LabTest(name: "Basic Metabolic Panel", description: "Measures glucose, electrolytes, and kidney function", price: "$65", duration: "20 minutes", instructions: "Fasting for 8-12 hours required"),
        LabTest(name: "Lipid Panel", description: "Measures cholesterol and triglycerides", price: "$55", duration: "20 minutes", instructions: "Fasting for 9-12 hours required")
    ]
    
    @State private var showingAddTest = false
    @State private var searchText = ""
    @State private var editMode: EditMode = .inactive
    @State private var selectedTests = Set<UUID>()
    @State private var showingDeleteConfirmation = false
    
    private var filteredTests: [LabTest] {
        if searchText.isEmpty {
            return tests
        } else {
            return tests.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.price.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            SearchBar(text: $searchText)
                .padding(.horizontal)
                .padding(.top, 8)
                .background(Color(.systemGroupedBackground))
            
            // List
            List(selection: $selectedTests) {
                ForEach(filteredTests) { test in
                    NavigationLink(destination: LabTestDetailView(test: binding(for: test))) {
                        LabTestRow(test: test)
                    }
                    .tag(test.id)
                }
                .onDelete(perform: deleteTest)
            }
            .listStyle(InsetListStyle())
        }
        .navigationTitle("Lab Tests")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if editMode == .active {
                    Button(action: {
                        if !selectedTests.isEmpty {
                            showingDeleteConfirmation = true
                        }
                    }) {
                        Image(systemName: "trash")
                    }
                    .disabled(selectedTests.isEmpty)
                }
                
                Button(action: { showingAddTest = true }) {
                    Image(systemName: "plus")
                }
                
                EditButton()
            }
        }
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $showingAddTest) {
            AddEditLabTestView(test: .constant(nil), onSave: { newTest in
                tests.append(newTest)
                showingAddTest = false
            })
        }
        .actionSheet(isPresented: $showingDeleteConfirmation) {
            ActionSheet(
                title: Text("Delete Tests"),
                message: Text("Are you sure you want to delete \(selectedTests.count) test(s)?"),
                buttons: [
                    .destructive(Text("Delete"), action: deleteSelectedTests),
                    .cancel()
                ]
            )
        }
    }
    
    private func binding(for test: LabTest) -> Binding<LabTest> {
        guard let index = tests.firstIndex(where: { $0.id == test.id }) else {
            fatalError("Test not found")
        }
        return $tests[index]
    }
    
    private func deleteTest(at offsets: IndexSet) {
        tests.remove(atOffsets: offsets)
    }
    
    private func deleteSelectedTests() {
        tests.removeAll { test in
            selectedTests.contains(test.id)
        }
        selectedTests.removeAll()
        editMode = .inactive
    }
}

struct LabTestRow: View {
    let test: LabTest
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "testtube.2")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.orange)
                .padding(5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(test.name)
                    .font(.headline)
                
                Text(test.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(test.price)
                    .font(.subheadline)
                    .foregroundColor(.orange)
                Text(test.duration)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

struct AddEditLabTestView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var test: LabTest?
    var onSave: (LabTest) -> Void
    
    @State private var name: String
    @State private var description: String
    @State private var price: String
    @State private var duration: String
    @State private var instructions: String
    @State private var showingCommonTests = false
    
    private let commonTests = [
        ("Complete Blood Count (CBC)", "$45", "15 minutes", "Measures various components of blood", "No special preparation required"),
        ("Basic Metabolic Panel", "$65", "20 minutes", "Measures glucose, electrolytes, and kidney function", "Fasting for 8-12 hours required"),
        ("Lipid Panel", "$55", "20 minutes", "Measures cholesterol and triglycerides", "Fasting for 9-12 hours required"),
        ("Thyroid Stimulating Hormone (TSH)", "$75", "15 minutes", "Measures thyroid function", "No special preparation required"),
        ("Hemoglobin A1C", "$60", "15 minutes", "Measures average blood glucose levels", "No fasting required"),
        ("Liver Function Test", "$85", "20 minutes", "Measures liver enzymes and proteins", "Fasting for 8-12 hours recommended")
    ]
    
    init(test: Binding<LabTest?>, onSave: @escaping (LabTest) -> Void) {
        self._test = test
        self.onSave = onSave
        
        if let test = test.wrappedValue {
            _name = State(initialValue: test.name)
            _description = State(initialValue: test.description)
            _price = State(initialValue: test.price)
            _duration = State(initialValue: test.duration)
            _instructions = State(initialValue: test.instructions)
        } else {
            _name = State(initialValue: "")
            _description = State(initialValue: "")
            _price = State(initialValue: "")
            _duration = State(initialValue: "")
            _instructions = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Test Information")) {
                    HStack {
                        TextField("Test Name", text: $name)
                        Button(action: { showingCommonTests = true }) {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                    TextField("Duration", text: $duration)
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Patient Instructions")) {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle(test == nil ? "Add Test" : "Edit Test")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newTest = LabTest(
                            name: name,
                            description: description,
                            price: price,
                            duration: duration,
                            instructions: instructions
                        )
                        onSave(newTest)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || price.isEmpty)
                }
            }
            .sheet(isPresented: $showingCommonTests) {
                CommonTestsView { selectedTest in
                    name = selectedTest.0
                    price = selectedTest.1
                    duration = selectedTest.2
                    description = selectedTest.3
                    instructions = selectedTest.4
                    showingCommonTests = false
                }
            }
        }
    }
}

struct CommonTestsView: View {
    var onSelect: ((String, String, String, String, String)) -> Void
    
    private let commonTests = [
        ("Complete Blood Count (CBC)", "$45", "15 minutes", "Measures various components of blood", "No special preparation required"),
        ("Basic Metabolic Panel", "$65", "20 minutes", "Measures glucose, electrolytes, and kidney function", "Fasting for 8-12 hours required"),
        ("Lipid Panel", "$55", "20 minutes", "Measures cholesterol and triglycerides", "Fasting for 9-12 hours required"),
        ("Thyroid Stimulating Hormone (TSH)", "$75", "15 minutes", "Measures thyroid function", "No special preparation required"),
        ("Hemoglobin A1C", "$60", "15 minutes", "Measures average blood glucose levels", "No fasting required"),
        ("Liver Function Test", "$85", "20 minutes", "Measures liver enzymes and proteins", "Fasting for 8-12 hours recommended")
    ]
    
    var body: some View {
        NavigationView {
            List(commonTests, id: \.0) { test in
                Button(action: { onSelect(test) }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(test.0)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(test.3)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack {
                            Text(test.1)
                                .foregroundColor(.orange)
                            Spacer()
                            Text(test.2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Common Tests")
            .navigationBarItems(trailing: Button("Cancel") { onSelect(("", "", "", "", "")) })
        }
    }
}

struct LabTestDetailView: View {
    @Binding var test: LabTest
    @State private var isEditing = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Test Name")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(test.name)
                }
                
                HStack {
                    Text("Price")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(test.price)
                }
                
                HStack {
                    Text("Duration")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(test.duration)
                }
            }
            
            Section(header: Text("Description")) {
                Text(test.description)
            }
            
            Section(header: Text("Patient Instructions")) {
                Text(test.instructions)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(test.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditing = true }) {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            AddEditLabTestView(test: .constant(test), onSave: { updatedTest in
                test = updatedTest
                isEditing = false
            })
        }
    }
}
