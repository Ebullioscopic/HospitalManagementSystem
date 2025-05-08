//
//  AdminProfileView.swift
//  Hospitality
//
//  Created by admin@33 on 08/05/25.
//

import SwiftUI
import UIKit

struct AdminProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var showLogoutConfirmation = false
    @State private var isLoading = true
    @State private var adminData: AdminProfile?
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isUploadingImage = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showEditView = false
    
    // Color palette
    private let primaryColor = Color(hex: "4A90E2")
    private let secondaryColor = Color(hex: "5B86E5")
    private let accentColor = Color(hex: "3BD1D3")
    private let dangerColor = Color(hex: "E53E3E")
    private let successColor = Color(hex: "38A169")
    private let warningColor = Color(hex: "F6AD55")
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: "EEF6FF"),
            Color(hex: "F8FAFF")
        ]),
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(primaryColor)
                        Text("Loading profile...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 22) {
                            // Profile Header
                            profileHeader
                                .padding(.top, 10)
                            
                            // Profile Card
                            profileDetailsCard
                            
                            // Admin Details Card
                            adminDetailsCard
                            
                            // Permissions Card
                            permissionsCard
                            
                            // Logout Button
                            logoutButton
                                .padding(.vertical, 10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .refreshable {
                        fetchAdminProfile()
                    }
                }
            }
            .navigationTitle("Admin Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(primaryColor)
                    .fontWeight(.medium)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
                    .onDisappear {
                        if selectedImage != nil {
                            uploadProfilePhoto()
                        }
                    }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert("Log Out", isPresented: $showLogoutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .onAppear {
                fetchAdminProfile()
            }
        }
    }
    
    // MARK: - Profile UI Components
    
    private var profileHeader: some View {
        Button(action: {
            showImagePicker = true
        }) {
            ZStack(alignment: .bottomTrailing) {
                if let photo = adminData?.profile_photo,
                   let urlString = photo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                   let url = URL(string: urlString),
                   !photo.isEmpty {
                    
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            profilePlaceholder
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                )
                        case .failure:
                            profilePlaceholder
                        @unknown default:
                            profilePlaceholder
                        }
                    }
                } else {
                    profilePlaceholder
                }
                
                if isUploadingImage {
                    ProgressView()
                        .tint(.white)
                        .frame(width: 120, height: 120)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 10)
    }
    
    private var profilePlaceholder: some View {
        Image(systemName: "person.circle.fill")
            .font(.system(size: 80))
            .foregroundColor(primaryColor.opacity(0.8))
            .frame(width: 120, height: 120)
            .background(Color.white.opacity(0.7))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
    }

    private var profileDetailsCard: some View {
        VStack(spacing: 0) {
            // Name and Email
            HStack {
                VStack(alignment: .center, spacing: 4) {
                    Text(adminData?.staff_name ?? "Name")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C3E50"))
                    
                    Text(adminData?.staff_email ?? "Email")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .padding(.bottom, 16)
            }
            
            Divider()
                .padding(.horizontal, 20)
            
            // Quick Info Pills
            HStack(spacing: 12) {
                InfoPill(
                    title: "ID",
                    value: adminData?.staff_id ?? "N/A",
                    icon: "number",
                    color: primaryColor
                )
                
                InfoPill(
                    title: "Role",
                    value: adminData?.role.role_name ?? "N/A",
                    icon: "person.fill",
                    color: successColor
                )
                
                InfoPill(
                    title: "Admin",
                    value: adminData?.role.permissions.is_admin == true ? "Yes" : "No",
                    icon: "shield.fill",
                    color: adminData?.role.permissions.is_admin == true ? successColor : warningColor
                )
            }
            .padding(.vertical, 20)
            
            Divider()
                .padding(.horizontal, 20)
            
            // Additional Details
            VStack(alignment: .leading, spacing: 16) {
                DetailRow(icon: "calendar", label: "Date of Birth", value: formatDate(adminData?.staff_dob ?? ""))
                DetailRow(icon: "phone.fill", label: "Mobile", value: adminData?.staff_mobile ?? "Not provided")
                DetailRow(icon: "mappin.and.ellipse", label: "Address", value: adminData?.staff_address ?? "Not provided")
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 5)
        )
    }

    private var adminDetailsCard: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "person.badge.key.fill")
                            .font(.system(size: 24))
                            .foregroundColor(primaryColor)
                        
                        Text("Admin Details")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C3E50"))
                    }
                    
                    Text("Administrative information")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Admin Details
            VStack(alignment: .leading, spacing: 16) {
                DetailRow(icon: "graduationcap.fill", label: "Qualification", value: adminData?.staff_qualification ?? "Not provided")
                DetailRow(icon: "calendar.badge.plus", label: "Joined On", value: formatDate(adminData?.created_at ?? ""))
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 5)
        )
    }
    
    private var permissionsCard: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundColor(primaryColor)
                        
                        Text("Permissions")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "2C3E50"))
                    }
                    
                    Text("Administrative permissions")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Permissions
            VStack(spacing: 12) {
                PermissionRow(
                    icon: "person.3.fill",
                    title: "Create Admins",
                    isEnabled: adminData?.role.permissions.can_create_admin == true
                )
                
                PermissionRow(
                    icon: "person.fill.badge.plus",
                    title: "Manage Roles",
                    isEnabled: adminData?.role.permissions.can_manage_roles == true
                )
                
                PermissionRow(
                    icon: "stethoscope",
                    title: "Manage Doctors",
                    isEnabled: adminData?.role.permissions.can_manage_doctors == true
                )
                
                PermissionRow(
                    icon: "testtube.2",
                    title: "Manage Lab Techs",
                    isEnabled: adminData?.role.permissions.can_manage_lab_techs == true
                )
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 5)
        )
    }

    // MARK: - Format Date
    private func formatDate(_ dateString: String) -> String {
        guard !dateString.isEmpty else { return "Not provided" }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = inputFormatter.date(from: dateString) else {
            return "Not provided"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        return outputFormatter.string(from: date)
    }
    
    private var logoutButton: some View {
        Button(action: {
            showLogoutConfirmation = true
        }) {
            HStack {
                Spacer()
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .medium))
                Text("Log Out")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
            }
            .padding(.vertical, 16)
            .foregroundColor(dangerColor)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(dangerColor.opacity(0.1))
            )
        }
    }

    // MARK: - Supporting Views

    struct InfoPill: View {
        let title: String
        let value: String
        let icon: String
        let color: Color

        var body: some View {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(color.opacity(0.12))
                    )
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    struct DetailRow: View {
        let icon: String
        let label: String
        let value: String

        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "4A90E2"))
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text(value)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
        }
    }
    
    struct PermissionRow: View {
        let icon: String
        let title: String
        let isEnabled: Bool
        
        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isEnabled ? Color(hex: "38A169") : Color(hex: "E53E3E"))
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(isEnabled ? Color(hex: "38A169") : Color(hex: "E53E3E"))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? Color(hex: "38A169").opacity(0.1) : Color(hex: "E53E3E").opacity(0.1))
            )
        }
    }

    private func fetchAdminProfile() {
        isLoading = true
        
        guard let url = URL(string: "\(Constants.baseURL)/hospital/admin/profile/") else {
            isLoading = false
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if !UserDefaults.accessToken.isEmpty {
            request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        print("Request URL: \(url.absoluteString)")
        print("Authorization Header: Bearer \(UserDefaults.accessToken)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("Network Error: \(error.localizedDescription)")
                    showAlert(title: "Network Error", message: error.localizedDescription)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    showAlert(title: "Error", message: "Invalid response from server")
                    return
                }
                
                print("Status Code: \(httpResponse.statusCode)")
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response Data: \(responseString)")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    showAlert(title: "Server Error", message: "Server returned status code: \(httpResponse.statusCode)")
                    return
                }
                
                guard let data = data else {
                    showAlert(title: "Error", message: "No data received")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let profile = try decoder.decode(AdminProfile.self, from: data)
                    self.adminData = profile
                } catch {
                    print("Parsing Error: \(error)")
                    showAlert(title: "Parsing Error", message: "Could not parse profile data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    private func uploadProfilePhoto() {
        guard let image = selectedImage else {
            showAlert(title: "Error", message: "No image selected")
            return
        }
        
        isUploadingImage = true
        
        guard let url = URL(string: "\(Constants.baseURL)/hospital/admin/update-photo/") else {
            isUploadingImage = false
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            isUploadingImage = false
            showAlert(title: "Error", message: "Could not process image")
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if !UserDefaults.accessToken.isEmpty {
            request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"profile_photo\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isUploadingImage = false
                
                if let error = error {
                    print("Upload error: \(error.localizedDescription)")
                    self.showAlert(title: "Upload Error", message: error.localizedDescription)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    self.showAlert(title: "Upload Failed", message: "Invalid response from server")
                    return
                }
                
                print("Status code: \(httpResponse.statusCode)")
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Response data: \(responseString)")
                }
                
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    self.showAlert(title: "Success", message: "Profile photo updated successfully")
                    self.fetchAdminProfile()
                } else {
                    self.showAlert(title: "Upload Failed", message: "Server returned status code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    private func logout() {
        UserDefaults.clearAuthData()
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        dismiss()
        NotificationCenter.default.post(name: .logout, object: nil)
    }

    private func showAlert(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.showAlert = true
    }
}

struct AdminProfile: Codable {
    let staff_id: String
    let staff_name: String
    let staff_email: String
    let staff_mobile: String?
    let role: AdminRole
    let created_at: String
    let staff_dob: String?
    let staff_address: String?
    let staff_qualification: String?
    let profile_photo: String?
}

struct AdminRole: Codable {
    let role_id: Int
    let role_name: String
    let permissions: AdminPermissions
}

struct AdminPermissions: Codable {
    let is_admin: Bool
    let can_create_admin: Bool
    let can_manage_roles: Bool
    let can_manage_doctors: Bool
    let can_manage_lab_techs: Bool
    let can_manage_staff: Bool?
    let can_manage_patients: Bool?
}

#Preview {
    AdminProfileView()
}
