//
//  addView.swift
//  Hospitality
//
//  Created by admin@33 on 21/04/25.
//

import Foundation
import SwiftUI

struct AdminDashboardView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Medical Staff").font(.headline)) {
                    NavigationLink(destination: DoctorsListView()) {
                        Label("Doctors", systemImage: "stethoscope")
                    }
                    
                    NavigationLink(destination: LabTechniciansListView()) {
                        Label("Lab Technicians", systemImage: "person.text.rectangle")
                    }
                }
                
                Section(header: Text("Services").font(.headline)) {
                    NavigationLink(destination: LabTestsListView()) {
                        Label("Lab Tests", systemImage: "testtube.2")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Hospital Admin")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
        }
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
