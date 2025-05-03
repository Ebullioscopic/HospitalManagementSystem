import Foundation
import SwiftUI

struct RootView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("userType") private var userType = ""
    @AppStorage("userId") private var userId = ""
    @State private var showSplashScreen = true
    
    var body: some View {
        ZStack {
            if showSplashScreen {
                SplashScreen(onComplete: {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplashScreen = false
                    }
                })
            } else {
                Group {
                    if isLoggedIn {
                        switch userType {
                        case "admin":
                            AdminHomeView()
                        case "staff":
                            DoctorDashboardView(doctorId: userId)
                        case "patient":
                            HomePatient()
                        default:
                            Login()
                        }
                    } else {
                        Login()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .logout)) { _ in
                    print("Logout notification received")
                    isLoggedIn = false
                    UserDefaults.clearAuthData()
                }
            }
        }
    }
}
