//
//  AdminDashboardView.swift
//  Hospitality
//
//  Created by admin@33 on 21/04/25.
//

import SwiftUI

struct AdminDashboardView: View {
    @StateObject private var dataStore = MockHospitalDataStore()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Medical Staff").font(.headline)) {
                    NavigationLink(destination: DoctorsListView().environmentObject(dataStore)) {
                        Label("Doctors", systemImage: "stethoscope")
                    }
                    
                    NavigationLink(destination: LabTechniciansListView().environmentObject(dataStore)) {
                        Label("Lab Technicians", systemImage: "person.text.rectangle")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Hospital Admin")
        }
        .navigationViewStyle(.stack) // Prevents sidebar behavior on iPad
    }
}

// MARK: - Preview
struct AdminDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AdminDashboardView()
                .preferredColorScheme(.light)
            
            AdminDashboardView()
                .preferredColorScheme(.dark)
        }
    }
}
