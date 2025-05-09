//
//  HospitalityApp.swift
//  Hospitality
//
//  Created by Ashish Shiv on 16/04/25.
//

import SwiftUI

@main
struct HospitalityApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
            NotificationManager.shared.requestAuthorization()
        }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
