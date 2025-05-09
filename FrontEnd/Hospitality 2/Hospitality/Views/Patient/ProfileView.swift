import SwiftUI
import UIKit
import Foundation

class UserProfileCache {
    static let shared = UserProfileCache()
    
    let imageCache = NSCache<NSString, UIImage>()
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let profilePhotoURL = "cached_profile_photo_url"
    }
    
    var profilePhotoURL: String? {
        get { defaults.string(forKey: Keys.profilePhotoURL) }
        set { defaults.set(newValue, forKey: Keys.profilePhotoURL) }
    }
    
    func cacheImage(_ image: UIImage, forURL url: URL) {
        imageCache.setObject(image, forKey: url.absoluteString as NSString)
    }
    
    func getCachedImage(forURL url: URL) -> UIImage? {
        return imageCache.object(forKey: url.absoluteString as NSString)
    }
}

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var showLogoutConfirmation = false
    @State private var isLoading = true
    @State private var patientData: PatientProfile?
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isUploadingImage = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showEditView = false
    @State private var animationOpacity: Double = 0.0
    @State private var profilePhotoOpacity: Double = 0.0
    
    // Color palette
    private let primaryColor = Color(hex: "4A90E2")
    private let secondaryColor = Color(hex: "5B86E5")
    private let accentColor = Color(hex: "3BD1D3")
    private let dangerColor = Color(hex: "E53E3E")
    private let successColor = Color(hex: "38A169")
    private let warningColor = Color(hex: "F6AD55")
    
    // Dynamic colors and gradients
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "1A202C") : .white
    }
    
    private var textPrimaryColor: Color {
        colorScheme == .dark ? .white : Color(hex: "2C3E50")
    }
    
    private var textSecondaryColor: Color {
        colorScheme == .dark ? Color(hex: "A0AEC0") : .secondary
    }
    
    private var dividerColor: Color {
        colorScheme == .dark ? Color(hex: "2D3748").opacity(0.6) : Color(hex: "E2E8F0")
    }
    
    private var backgroundGradient: LinearGradient {
        colorScheme == .dark ?
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "0F172A"),
                    Color(hex: "1E293B")
                ]),
                startPoint: .top,
                endPoint: .bottom
            ) :
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "EEF6FF"),
                    Color(hex: "F8FAFF")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
    }
    
    private var cardShadowColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.06)
    }
    
    private var healthCardGradient: LinearGradient {
        colorScheme == .dark ?
            LinearGradient(
                gradient: Gradient(colors: [
                    primaryColor.opacity(0.9),
                    secondaryColor.opacity(0.9),
                    Color(hex: "6A6AE2").opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) :
            LinearGradient(
                gradient: Gradient(colors: [
                    primaryColor,
                    secondaryColor,
                    Color(hex: "6A6AE2")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
    }

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
                            .animation(.easeInOut(duration: 0.5), value: isLoading)
                        Text("Loading profile...")
                            .font(.subheadline)
                            .foregroundColor(textSecondaryColor)
                            .padding(.top, 12)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            profileHeader
                                .padding(.top, 12)
                            profileDetailsCard
                            healthInsightsCard
                            logoutButton
                                .padding(.vertical, 12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                        .opacity(animationOpacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 0.5)) {
                                animationOpacity = 1.0
                            }
                        }
                    }
                    .refreshable {
                        fetchPatientProfile()
                    }
                }
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Edit") {
                        showEditView = true
                    }
                    .foregroundColor(primaryColor)
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(primaryColor)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showEditView) {
                if let patient = patientData {
                    ProfileEditView(patient: patient)
                        .onDisappear {
                            fetchPatientProfile()
                        }
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
                fetchPatientProfile()
            }
        }
    }
    
    private var profileHeader: some View {
        Button(action: {
            showImagePicker = true
        }) {
            ZStack(alignment: .bottomTrailing) {
                profilePlaceholder
                profileImage
                
                if isUploadingImage {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                        .frame(width: 130, height: 130)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                        .animation(.easeInOut(duration: 0.5), value: isUploadingImage)
                }
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(primaryColor)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(colorScheme == .dark ? Color(hex: "1A202C") : .white, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .offset(x: 8, y: 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 12)
        .scaleEffect(showImagePicker ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showImagePicker)
    }
    
    private var profileImage: some View {
        Group {
            if let photo = patientData?.profile_photo,
               !photo.isEmpty,
               let urlString = photo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: urlString) {
                
                CachedAsyncImage(url: url, cache: UserProfileCache.shared.imageCache) { phase in
                    switch phase {
                    case .loading:
                        ProgressView()
                            .tint(primaryColor)
                            .frame(width: 130, height: 130)
                            .background(Color.black.opacity(0.2))
                            .clipShape(Circle())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 130, height: 130)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(colorScheme == .dark ? Color(hex: "2D3748") : .white, lineWidth: 2)
                                    .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
                            )
                            .opacity(profilePhotoOpacity)
                            .onAppear {
                                withAnimation(.easeIn(duration: 0.5)) {
                                    profilePhotoOpacity = 1.0
                                }
                            }
                    case .failure:
                        EmptyView()
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var profilePlaceholder: some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? Color(hex: "2D3748").opacity(0.7) : Color.white.opacity(0.9))
                .frame(width: 130, height: 130)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            
            Image(systemName: "person.circle.fill")
                .font(.system(size: 90))
                .foregroundColor(primaryColor.opacity(0.7))
        }
        .overlay(
            Circle()
                .stroke(colorScheme == .dark ? Color(hex: "2D3748") : .white, lineWidth: 4)
        )
    }

    private var profileDetailsCard: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .center, spacing: 6) {
                    Text(patientData?.patient_name ?? "Name")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(textPrimaryColor)
                    
                    Text(patientData?.patient_email ?? "Email")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(textSecondaryColor)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 28)
                .padding(.bottom, 20)
            }
            
            Divider()
                .background(dividerColor)
                .padding(.horizontal, 24)
            
            HStack(spacing: 16) {
                InfoPill(
                    title: "Blood",
                    value: patientData?.patient_blood_group ?? "N/A",
                    icon: "drop.fill",
                    color: dangerColor,
                    colorScheme: colorScheme
                )
                
                InfoPill(
                    title: "Gender",
                    value: patientData?.patient_gender == true ? "Male" : "Female",
                    icon: "person.fill",
                    color: primaryColor,
                    colorScheme: colorScheme
                )
                
                InfoPill(
                    title: "ID",
                    value: "\(patientData?.patient_id ?? 0)",
                    icon: "number",
                    color: successColor,
                    colorScheme: colorScheme
                )
            }
            .padding(.vertical, 24)
            
            Divider()
                .background(dividerColor)
                .padding(.horizontal, 24)
            
            VStack(alignment: .leading, spacing: 18) {
                DetailRow(
                    icon: "calendar",
                    label: "Date of Birth",
                    value: formatDate(patientData?.patient_dob ?? ""),
                    colorScheme: colorScheme
                )
                DetailRow(
                    icon: "phone.fill",
                    label: "Mobile",
                    value: patientData?.patient_mobile ?? "Not provided",
                    colorScheme: colorScheme
                )
                DetailRow(
                    icon: "mappin.and.ellipse",
                    label: "Address",
                    value: patientData?.patient_address ?? "Not provided",
                    colorScheme: colorScheme
                )
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 28)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(cardBackgroundColor)
        )
        .padding(.horizontal, 4)
    }

    private var healthInsightsCard: some View {
        NavigationLink(destination: HealthMetricsView().navigationBarBackButtonHidden(false)) {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                            
                            Text("Health Insights")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Text("View your health metrics and vitals")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 20)
            }
            .frame(height: 110)
            .background(healthCardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: primaryColor.opacity(colorScheme == .dark ? 0.25 : 0.35), radius: 12, x: 0, y: 6)
            .padding(.horizontal, 4)
        }
        .scaleEffect(1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: UUID())
    }
    
    private var logoutButton: some View {
        Button(action: {
            showLogoutConfirmation = true
        }) {
            HStack {
                Spacer()
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 18, weight: .medium))
                Text("Log Out")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Spacer()
            }
            .padding(.vertical, 18)
            .foregroundColor(dangerColor)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? dangerColor.opacity(0.12) : dangerColor.opacity(0.08))
                    .shadow(color: dangerColor.opacity(0.15), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 4)
        }
        .scaleEffect(showLogoutConfirmation ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showLogoutConfirmation)
    }

    // MARK: - Supporting Views

    struct InfoPill: View {
        let title: String
        let value: String
        let icon: String
        let color: Color
        let colorScheme: ColorScheme
        
        private var pillBackgroundColor: Color {
            colorScheme == .dark ? color.opacity(0.15) : color.opacity(0.1)
        }
        
        private var textColor: Color {
            colorScheme == .dark ? .white : .primary
        }
        
        private var subtitleColor: Color {
            colorScheme == .dark ? Color(hex: "A0AEC0") : .secondary
        }

        var body: some View {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(pillBackgroundColor)
                            .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 2)
                    )
                
                Text(value)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(textColor)
                
                Text(title)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(subtitleColor)
            }
            .frame(maxWidth: .infinity)
        }
    }

    struct MetricCard: View {
        let icon: String
        let title: String
        let value: String
        let unit: String
        let trend: String
        let trendUp: Bool?
        let colorScheme: ColorScheme

        var body: some View {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                HStack(alignment: .firstTextBaseline) {
                    Text(value)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(unit)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.leading, -2)
                    
                    Spacer()
                    
                    Text(trend)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(trendColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(trendColor.opacity(0.25))
                        )
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(colorScheme == .dark ? 0.12 : 0.18))
            )
            .frame(maxWidth: .infinity)
        }
        
        private var trendColor: Color {
            guard let up = trendUp else {
                return .white
            }
            return up ? Color(hex: "4ADE80") : Color(hex: "F87171")
        }
    }

    struct DetailRow: View {
        let icon: String
        let label: String
        let value: String
        let colorScheme: ColorScheme
        
        private var iconColor: Color {
            Color(hex: "4A90E2")
        }
        
        private var labelColor: Color {
            colorScheme == .dark ? Color(hex: "A0AEC0") : .secondary
        }
        
        private var valueColor: Color {
            colorScheme == .dark ? .white : .primary
        }

        var body: some View {
            HStack(spacing: 18) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(labelColor)
                    
                    Text(value)
                        .font(.system(size: 17, design: .rounded))
                        .foregroundColor(valueColor)
                }
                
                Spacer()
            }
        }
    }

    // MARK: - Functions

    private func fetchPatientProfile() {
        isLoading = true
        animationOpacity = 0.0
        
        guard let url = URL(string: "\(Constants.baseURL)/accounts/patient/profile/") else {
            isLoading = false
            showAlert(title: "Error", message: "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if !UserDefaults.accessToken.isEmpty {
            request.addValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                withAnimation(.easeIn(duration: 0.5)) {
                    animationOpacity = 1.0
                }
                
                if let error = error {
                    print("Profile fetch error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No profile data received")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let profile = try decoder.decode(PatientProfile.self, from: data)
                    print("Fetched profile data: \(profile)")
                    self.patientData = profile
                    UserProfileCache.shared.profilePhotoURL = profile.profile_photo
                } catch {
                    print("Profile parsing error: \(error.localizedDescription)")
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
        
        guard let url = URL(string: "\(Constants.baseURL)/accounts/patient/update-photo/") else {
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
                    self.showAlert(title: "Upload Error", message: error.localizedDescription)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.showAlert(title: "Upload Failed", message: "Invalid response from server")
                    return
                }
                
                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                    self.showAlert(title: "Success", message: "Profile photo updated successfully")
                    self.fetchPatientProfile()
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

    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        return outputFormatter.string(from: date)
    }
}

// MARK: - Models and Extensions

struct PatientProfile: Codable {
    let patient_id: Int
    let patient_name: String
    let patient_email: String
    let patient_mobile: String?
    let patient_remark: String?
    let patient_dob: String
    let patient_gender: Bool
    let patient_blood_group: String
    let patient_address: String?
    let profile_photo: String?
}

extension Notification.Name {
    static let logout = Notification.Name("logout")
}

struct PatientProfileMenuItem: View {
    let icon: String
    let title: String
    @Environment(\.colorScheme) var colorScheme
    
    private var textColor: Color {
        colorScheme == .dark ? .white : Color(hex: "2C5282")
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(hex: "4A90E2"))
                .frame(width: 26)
            
            Text(title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(textColor)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color.gray.opacity(0.7))
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
    }
}

// MARK: - Cached Async Image

enum CachedAsyncImagePhase {
    case loading
    case success(Image)
    case failure
}

struct CachedAsyncImage<Content: View>: View {
    private let url: URL
    private let cache: NSCache<NSString, UIImage>
    private let content: (CachedAsyncImagePhase) -> Content
    @State private var phase: CachedAsyncImagePhase = .loading
    
    init(url: URL, cache: NSCache<NSString, UIImage>, @ViewBuilder content: @escaping (CachedAsyncImagePhase) -> Content) {
        self.url = url
        self.cache = cache
        self.content = content
    }
    
    var body: some View {
        content(phase)
            .onAppear {
                loadImage()
            }
    }
    
    private func loadImage() {
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            phase = .success(Image(uiImage: cachedImage))
            return
        }
        
        phase = .loading
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Image fetch error: \(error.localizedDescription)")
                    phase = .failure
                    return
                }
                
                guard let data = data, let uiImage = UIImage(data: data) else {
                    phase = .failure
                    return
                }
                
                cache.setObject(uiImage, forKey: url.absoluteString as NSString)
                phase = .success(Image(uiImage: uiImage))
            }
        }.resume()
    }
}

#Preview {
    ProfileView()
}
