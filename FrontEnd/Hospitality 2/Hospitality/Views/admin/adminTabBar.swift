//
//  adminTabBar.swift
//  Hospitality
//
//  Created by admin@33 on 21/04/25.
//

import SwiftUI

struct adminTabBarView : View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                TabView(selection: $selectedTab) {
                    AdminHomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .tag(0)
                    AdminDashboardView()
                        .tabItem {
                            Image(systemName: "person.3.sequence")
                            Text("Staff")
                        }
                        .tag(1)
                    BillsContent()
                        .tabItem {
                            Image(systemName: "newspaper")
                            Text("Invoice")
                        }
                        .tag(2)
                }
                .accentColor(.main)
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
}
