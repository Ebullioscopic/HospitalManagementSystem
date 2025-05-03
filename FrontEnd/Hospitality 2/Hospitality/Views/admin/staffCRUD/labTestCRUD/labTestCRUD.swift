//
//  labTestCRUD.swift
//  Hospitality
//
//  Created by admin@33 on 23/04/25.
//

import SwiftUI

struct LabTestsListView: View {
    @StateObject private var dataStore = MockHospitalDataStore()
    @State private var showingAddTest = false
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var editMode: EditMode = .inactive
    @State private var selectedTests = Set<String>()
    @State private var showingDeleteConfirmation = false
    
    private var categories: [String] {
        var cats = ["All"]
        let allCats = Set(dataStore.labTestCategories.map { $0.testCategoryName })
        cats.append(contentsOf: allCats.sorted())
        return cats
    }
    
    private var filteredTests: [LabTestType] {
        var result = dataStore.labTestTypes
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.testName.localizedCaseInsensitiveContains(searchText) ||
                ($0.testRemark?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        if selectedCategory != "All" {
            result = result.filter { test in
                if let category = dataStore.labTestCategories.first(where: { $0.id == test.testCategoryId }) {
                    return category.testCategoryName == selectedCategory
                }
                return false
            }
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
            
            // Filter Section
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
                        title: "Category",
                        selection: $selectedCategory,
                        options: categories,
                        accentColor: .main
                    )
                }
                .padding(.horizontal, 8)
            }
            .padding(.vertical, 8)
            .background(Color(.systemGroupedBackground))
            
            // Tests List
            List(selection: $selectedTests) {
                ForEach(filteredTests) { test in
                    NavigationLink(destination: LabTestDetailView(test: test)) {
                        LabTestRow(test: test)
                    }
                    .tag(test.id)
                }
                .onDelete(perform: deleteTest)
            }
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
                            .tint(.red)
                    }
                    .disabled(selectedTests.isEmpty)
                }
                
                Button(action: { showingAddTest = true }) {
                    Image(systemName: "plus")
                        .tint(.main)
                }
                
                EditButton()
            }
        }
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $showingAddTest) {
            AddEditLabTestView(onSave: { test in
                dataStore.createLabTestType(testType: test)
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
        .onAppear {
            dataStore.fetchLabTestTypes()
            dataStore.fetchLabTestCategories()
            dataStore.fetchTargetOrgans()
        }
    }
    
    private func deleteTest(at offsets: IndexSet) {
        let idsToDelete = offsets.map { filteredTests[$0].id }
        dataStore.deleteLabTestTypes(ids: idsToDelete)
    }
    
    private func deleteSelectedTests() {
        dataStore.deleteLabTestTypes(ids: Array(selectedTests))
        selectedTests.removeAll()
        editMode = .inactive
    }
}

struct LabTestRow: View {
    let test: LabTestType
    @EnvironmentObject var dataStore: MockHospitalDataStore
    
    var category: LabTestCategory? {
        dataStore.labTestCategories.first { $0.id == test.testCategoryId }
    }
    
    var targetOrgan: TargetOrgan? {
        dataStore.targetOrgans.first { $0.id == test.testTargetOrganId }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "testtube.2")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(.main)
                .padding(5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(test.testName)
                    .font(.headline)
                
                if let categoryName = category?.testCategoryName {
                    Text(categoryName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let organ = targetOrgan {
                Text(organ.targetOrganName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AddEditLabTestView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataStore: MockHospitalDataStore
    
    var onSave: (LabTestType) -> Void
    
    @State private var testName: String = ""
    @State private var testCategoryId: String = ""
    @State private var testTargetOrganId: String = ""
    @State private var testRemark: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Test Information")) {
                    TextField("Test Name", text: $testName)
                    
                    Picker("Category", selection: $testCategoryId) {
                        ForEach(dataStore.labTestCategories) { category in
                            Text(category.testCategoryName).tag(category.id)
                        }
                    }
                    
                    Picker("Target Organ", selection: $testTargetOrganId) {
                        ForEach(dataStore.targetOrgans) { organ in
                            Text(organ.targetOrganName).tag(organ.id)
                        }
                    }
                }
                
                Section(header: Text("Remarks")) {
                    TextEditor(text: $testRemark)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Lab Test")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let test = LabTestType(
                            id: UUID().uuidString,
                            testName: testName,
                            testCategoryId: testCategoryId,
                            testTargetOrganId: testTargetOrganId,
                            testRemark: testRemark.isEmpty ? nil : testRemark
                        )
                        
                        onSave(test)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(testName.isEmpty || testCategoryId.isEmpty || testTargetOrganId.isEmpty)
                }
            }
        }
    }
}

struct LabTestDetailView: View {
    let test: LabTestType
    @EnvironmentObject var dataStore: MockHospitalDataStore
    
    var category: LabTestCategory? {
        dataStore.labTestCategories.first { $0.id == test.testCategoryId }
    }
    
    var targetOrgan: TargetOrgan? {
        dataStore.targetOrgans.first { $0.id == test.testTargetOrganId }
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Test Name")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(test.testName)
                }
                
                if let categoryName = category?.testCategoryName {
                    HStack {
                        Text("Category")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(categoryName)
                    }
                }
                
                if let organName = targetOrgan?.targetOrganName {
                    HStack {
                        Text("Target Organ")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(organName)
                    }
                }
            }
            
            if let remark = test.testRemark {
                Section(header: Text("Remarks")) {
                    Text(remark)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(test.testName)
    }
}
