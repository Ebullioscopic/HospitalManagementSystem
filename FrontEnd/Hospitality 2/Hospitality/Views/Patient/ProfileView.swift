import SwiftUI
import UIKit // For haptic feedback

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color(hex: "4A90E2"))
                            .padding(.bottom, 10)
                        
                        Text(UserDefaults.email)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(UserDefaults.userType)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 30)
                    
                    // Account Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("ACCOUNT")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: Text("Edit Profile")) {
                            ProfileRow(icon: "person.fill", title: "Edit Profile")
                        }
                        
                        NavigationLink(destination: Text("Change Password")) {
                            ProfileRow(icon: "lock.fill", title: "Change Password")
                        }
                        
                        NavigationLink(destination: HealthMetricsView()
                            .navigationBarBackButtonHidden(false)) {
                            ProfileRow(icon: "heart.fill", title: "Health Metrics")
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    // Settings Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("SETTINGS")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: Text("Notifications")) {
                            ProfileRow(icon: "bell.fill", title: "Notifications")
                        }
                        
                        NavigationLink(destination: Text("Privacy")) {
                            ProfileRow(icon: "hand.raised.fill", title: "Privacy")
                        }
                    }
                    
                    Spacer()
                    
                    // Logout Button
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.left.square.fill")
                                .foregroundColor(.red)
                            Text("Log Out")
                                .foregroundColor(.red)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.1))
                        )
                    }
                    .padding(.top, 30)
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Log Out", isPresented: $showLogoutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
    
    private func logout() {
        // Clear all user defaults
        UserDefaults.clearAuthData()
        
        // Dismiss the profile view
        dismiss()
        
        // Post notification to trigger root view change
        NotificationCenter.default.post(name: .logout, object: nil)
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
                .foregroundColor(Color(hex: "4A90E2"))
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.05))
        .padding(.horizontal)
            )
    }
}
            
extension Notification.Name {
        static let logout = Notification.Name("logout")
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            // Menu item action
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(colorScheme == .dark ? Color(hex: "1E88E5").opacity(0.2) : Color(hex: "4A90E2").opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? Color(hex: "1E88E5") : Color(hex: "4A90E2"))
                }
                
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C5282"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(hex: "4A5568"))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
        }
        .background(
            colorScheme == .dark ? Color(hex: "1E2533") : .white
        )
        
        Divider()
            .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.2))
            .padding(.horizontal, 20)
    }
}



#Preview {
    ProfileView()
        .preferredColorScheme(.dark) // Preview in dark mode
}
